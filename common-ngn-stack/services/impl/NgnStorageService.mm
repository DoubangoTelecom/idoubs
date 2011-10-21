/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
#import "NgnStorageService.h"
#import "NgnStringUtils.h"
#import "NgnFavoriteEventArgs.h"
#import "NgnNotificationCenter.h"

#undef TAG
#define kTAG @"NgnStorageService///: "
#define TAG kTAG

#undef kDataBaseName
#define kDataBaseName @"NgnDataBase.db"

// 'kDataBaseVersion' defines the current version of the database on the source code (objective-c) view.
// The database itself contains this reference. Each time the storage service is loaded we check that these
// two values are identical. If these two values are different then, we delete the data base stored in the device
// and replace it with the new one.
// You should increment this value if you change the database version and don't forget to do the same in the .sql file.
// If you are not using iDoubs test project then, please provide your own version id by subclassing '-databaseVersion'
#define kDataBaseVersion 0

#define kFavoritesTableName @"favorites"
#define kFavoritesColIdName @"id"
#define kFavoritesColMediaTypeName @"mediaType"
#define kFavoritesColNumberName @"number"

@interface NgnStorageService (DataBase)
+(BOOL) databaseCheckAndCopy:(NgnBaseService<INgnStorageService>*) service;
+(int) databaseVersion: (sqlite3 *)db;
-(BOOL) databaseOpen;
-(BOOL) databaseLoadData;
-(BOOL) databaseExecSQL: (NSString*)sqlQuery;
-(BOOL) databaseClose;
@end

@implementation NgnStorageService (DataBase)

static NSString* sDataBasePath = nil;
static BOOL sDataBaseInitialized = NO;

+(BOOL) databaseCheckAndCopy:(NgnBaseService<INgnStorageService>*) service{
	if(sDataBaseInitialized){
		return YES;
	}
// For backward compatibility, we have to continue to use diff folders
#if TARGET_OS_IPHONE
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
#elif TARGET_OS_MAC
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"iDoubs"];
#endif
	sDataBasePath = [documentsDir stringByAppendingPathComponent:kDataBaseName];

	sqlite3 *db = nil;
	NSError* error = nil;
	
	NgnNSLog(TAG, @"databasePath:%@", sDataBasePath);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
	// create the folder if it doesn't exist
	BOOL isDirectory = NO;
	BOOL exists = [fileManager fileExistsAtPath:documentsDir isDirectory:&isDirectory];
	if(!exists){
		BOOL created = [fileManager createDirectoryAtPath:documentsDir withIntermediateDirectories:YES attributes:nil error:&error];
		if(!created){
			NgnNSLog(TAG, @"Failed to create folder (%@) to the file system: %@", documentsDir, error);
			return NO;
		}
	}
#endif
	
	
	if([fileManager fileExistsAtPath: sDataBasePath]){
		// query for the database version
		
		if(sqlite3_open([sDataBasePath UTF8String], &db) != SQLITE_OK){
			NgnNSLog(TAG,@"Failed to open database from: %@", sDataBasePath);
			return NO;
		}
		int storedVersion = [NgnStorageService databaseVersion:db];
		int sourceCodeVersion = [service databaseVersion];
		sqlite3_close(db), db = nil;
		if(storedVersion != sourceCodeVersion){
			NgnNSLog(TAG,@"database changed v-stored=%i and database v-code=%i", storedVersion, sourceCodeVersion);
			// remove the file (database already closed)
			[fileManager removeItemAtPath:sDataBasePath error:nil];
		}
		else {
			NgnNSLog(TAG,@"No changes: database v-current=%i", storedVersion);
			sDataBaseInitialized = YES;
			// database already closed
			return YES;
		}
	}
	
	//
	// if we are here this means that the database has been upgraded/downgraded or this is a new installation
	//
	
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDataBaseName];
	NgnNSLog(TAG, @"creating (copy) new database from:%@", databasePathFromApp);
	
	if(![fileManager copyItemAtPath:databasePathFromApp toPath:sDataBasePath error:&error]){
		[fileManager release];
		NgnNSLog(TAG, @"Failed to copy database to the file system: %@", error);
		return NO;
	}
	
	[fileManager release];
	
	sDataBaseInitialized = YES;
	return YES;
}

+(int) databaseVersion: (sqlite3 *)db {
    static sqlite3_stmt *compiledStatement = nil;
    int databaseVersion = -1;
	
    if(sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &compiledStatement, NULL) == SQLITE_OK) {
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            databaseVersion = sqlite3_column_int(compiledStatement, 0);
            NgnNSLog(TAG,@"found databaseVersion=%d", databaseVersion);
        }
        NgnNSLog(TAG,@"used databaseVersion=%d", databaseVersion);
    } else {
        NgnNSLog(TAG,@"Failed to get databaseVersion %s", sqlite3_errmsg(db) );
    }
    sqlite3_finalize(compiledStatement);
	
    return databaseVersion;
}

-(BOOL) databaseOpen{
	if(!self->database && sqlite3_open([sDataBasePath UTF8String], &self->database) != SQLITE_OK){
		NgnNSLog(TAG,@"Failed to open database from: %@", sDataBasePath);
		return NO;
	}
	return YES;
}

-(BOOL) databaseLoadData{
	BOOL ok = YES;
	int ret;
	sqlite3_stmt *compiledStatement = nil;
	NSString* sqlQueryFavorites = [@"select " stringByAppendingFormat:@"%@,%@,%@ from %@", 
								   kFavoritesColIdName, kFavoritesColNumberName, kFavoritesColMediaTypeName, kFavoritesTableName];
	
	/* === Load favorites === */
	[self->favorites removeAllObjects];
	if((ret = sqlite3_prepare_v2(self->database, [NgnStringUtils toCString:sqlQueryFavorites], -1, &compiledStatement, NULL)) == SQLITE_OK) {
		long long id_;
		NSString* number;
		NgnMediaType_t mediaType;
		while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
			id_ = sqlite3_column_int(compiledStatement, 0);
			number = [NgnStringUtils toNSString: (char *)sqlite3_column_text(compiledStatement, 1)];
			mediaType = (NgnMediaType_t)sqlite3_column_int(compiledStatement, 2);
			NgnFavorite* favorite = [[NgnFavorite alloc] initWithId:id_ 
														  andNumber:number
													   andMediaType:mediaType];
			if(favorite){
				[self->favorites setObject:favorite forKey:[NSNumber numberWithLongLong: favorite.id]];
				[favorite release];
			}
		}
	}
	sqlite3_finalize(compiledStatement), compiledStatement = nil;
	
	return ok;
}

-(BOOL) databaseClose{
	@synchronized(self){
		if(self->database){
			sqlite3_close(self->database);
			self->database = nil;
		}
	}
	return YES;
}


-(BOOL) databaseExecSQL: (NSString*)sqlQuery{
	BOOL ok = YES;
	@synchronized(self){
		int ret;
		sqlite3_stmt *compiledStatement;
		
		if(!self->database){
			NgnNSLog(TAG, @"Invalid database");
			ok = NO;
			goto done;
		}
		
		if((ret = sqlite3_prepare_v2(self->database, [sqlQuery UTF8String], -1, &compiledStatement, NULL)) == SQLITE_OK) {
			ok = (SQLITE_DONE == sqlite3_step(compiledStatement));
		}
		else {
			NgnNSLog(TAG, @"error: %s", sqlite3_errmsg(self->database));
			ok = NO;
		}
		
		sqlite3_finalize(compiledStatement);
	}
done:
	return ok;
}

@end


@implementation NgnStorageService

-(NgnStorageService*) init{
	if((self = [super init])){
		self-> favorites = [[NSMutableDictionary alloc] init]; 
	}
	return self;
}

-(void) dealloc{
	[self->favorites release];
	
	[super dealloc];
}

// to be overrided: used by Telekom, Tiscali and Alcated-Lucent
-(BOOL) load{
	return [self databaseLoadData];
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	BOOL ok = YES;
	
	if([NgnStorageService databaseCheckAndCopy:self]){
		if((ok = [self databaseOpen])){
			ok &= [self load];
		}
	}
	return ok;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	BOOL ok = YES;
	
	ok = [self databaseClose];
	
	return ok;
}

//
// INgnStorageService
//

-(int) databaseVersion{
	return kDataBaseVersion;
}

-(sqlite3 *) database{
	return self->database;
}

-(BOOL) execSQL: (NSString*)sqlQuery{
	return [self databaseExecSQL: sqlQuery];
}	

-(NSDictionary*) favorites{
	return self->favorites;
}

-(NgnFavorite*) favoriteWithNumber:(NSString*)number andMediaType:(NgnMediaType_t)mediaType{
	for (NgnFavorite *favorite in [self->favorites allValues]) {
		if([favorite.number isEqualToString:number] && favorite.mediaType == mediaType){
			return favorite;
		}
	}
	return nil;
}

-(NgnFavorite*) favoriteWithNumber:(NSString*)number{
	for (NgnFavorite *favorite in [self->favorites allValues]) {
		if([favorite.number isEqualToString:number]){
			return favorite;
		}
	}
	return nil;
}

-(BOOL) addFavorite: (NgnFavorite*) favorite{
	if(favorite){
		NSString* sqlStatement = [[@"insert into " stringByAppendingFormat:@"%@ (%@,%@) values", kFavoritesTableName, kFavoritesColNumberName, kFavoritesColMediaTypeName]
								  stringByAppendingFormat:@"('%@',%d)", favorite.number, (int)favorite.mediaType
								  ];
        if([self databaseExecSQL:sqlStatement]){
			favorite.id = (long long)sqlite3_last_insert_rowid(self->database);
			[self->favorites setObject:favorite forKey: [NSNumber numberWithLongLong: favorite.id]];
			
			NgnFavoriteEventArgs *eargs = [[[NgnFavoriteEventArgs alloc] initWithFavoriteId:favorite.id andEventType:FAVORITE_ITEM_ADDED andMediaType:favorite.mediaType] autorelease];
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnFavoriteEventArgs_Name object:eargs];
			
			return YES;
		}
	}
	return NO;
}

-(BOOL) deleteFavorite: (NgnFavorite*) favorite{
	if(favorite){
		NSString* sqlStatement = [[@"delete from " stringByAppendingFormat:@"%@", kFavoritesTableName]
								  stringByAppendingFormat:@" where %@=%lld", kFavoritesColIdName, favorite.id];
		if([self databaseExecSQL:sqlStatement]){
			[self->favorites removeObjectForKey:[NSNumber numberWithLongLong:favorite.id]];
			
			NgnFavoriteEventArgs *eargs = [[[NgnFavoriteEventArgs alloc] initWithFavoriteId:favorite.id andEventType:FAVORITE_ITEM_REMOVED andMediaType:favorite.mediaType] autorelease];
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnFavoriteEventArgs_Name object:eargs];
			
			return YES;
		}
	}
	return NO;
}

-(BOOL) deleteFavoriteWithId: (long long) id_{
	NgnFavorite* favorite = [self->favorites objectForKey:[NSNumber numberWithLongLong:id_]];
	return [self deleteFavorite:favorite];
}

-(BOOL) clearFavorites{
	NSString* sqlStatement = [@"delete from " stringByAppendingFormat:@"%@", kFavoritesTableName];
	if([self databaseExecSQL:sqlStatement]){
		[self->favorites removeAllObjects];
		
		NgnFavoriteEventArgs *eargs = [[[NgnFavoriteEventArgs alloc] initWithType:FAVORITE_RESET andMediaType: MediaType_All] autorelease];
		[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnFavoriteEventArgs_Name object:eargs];
		
		return YES;
	}
	return NO;
}

@end
