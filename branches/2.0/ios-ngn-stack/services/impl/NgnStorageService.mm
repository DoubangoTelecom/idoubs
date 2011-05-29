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

#if TARGET_OS_IPHONE

#undef kDataBaseName
#define kDataBaseName @"NgnDataBase.db"

#define kFavoritesTableName @"favorites"
#define kFavoritesColIdName @"id"
#define kFavoritesColMediaTypeName @"mediaType"
#define kFavoritesColNumberName @"number"

static BOOL sDataBaseInitialized = NO;
static NSString* sDataBasePath = nil;

@interface NgnStorageService (DataBase)
+(BOOL) databaseCheckAndCopy;
-(BOOL) databaseOpen;
-(BOOL) databaseLoadData;
-(BOOL) databaseExecSQL: (NSString*)sqlQuery;
-(BOOL) databaseClose;
@end

@implementation NgnStorageService (DataBase)

+(BOOL) databaseCheckAndCopy{
	if(sDataBaseInitialized){
		return YES;
	}
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	sDataBasePath = [documentsDir stringByAppendingPathComponent: kDataBaseName];
	NgnNSLog(TAG, @"datasePath:%@", sDataBasePath);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath: sDataBasePath]){
		//[fileManager removeItemAtPath:sDataBasePath error:nil];
		// for example you can remove the database if the "app_database_version" is different
		sDataBaseInitialized = YES;
		return YES;
	}
	
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: kDataBaseName];
	NgnNSLog(TAG, @"databasePathFromApp:%@", databasePathFromApp);
	
	NSError* error = nil;
	if(![fileManager copyItemAtPath:databasePathFromApp toPath: sDataBasePath error:&error]){
		[fileManager release];
		NgnNSLog(TAG, @"Failed to copy database to the file system: %@", error);
		return NO;
	}
	
	[fileManager release];
	
	sDataBaseInitialized = YES;
	return YES;
}

-(BOOL) databaseOpen{
	if(!self->database && sqlite3_open([sDataBasePath UTF8String], &self->database) != SQLITE_OK){
		NgnNSLog(TAG,@"Failed to open history database from: %@", sDataBasePath);
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
	NSLog(@"sql=%@",sqlQueryFavorites);
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
	if(self->database){
		sqlite3_close(self->database);
		self->database = nil;
	}
	return YES;
}


-(BOOL) databaseExecSQL: (NSString*)sqlQuery{
	BOOL ok = YES;
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
		ok = NO;
	}

	sqlite3_finalize(compiledStatement);
	
done:
	return ok;
}

@end

#endif /* #if TARGET_OS_IPHONE */


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

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	BOOL ok = YES;
	
#if TARGET_OS_IPHONE
	if([NgnStorageService databaseCheckAndCopy]){
		if((ok = [self databaseOpen])){
			ok &= [self databaseLoadData];
		}
	}
#endif
	return ok;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	BOOL ok = YES;
	
#if TARGET_OS_IPHONE
	ok = [self databaseClose];
#endif
	
	return ok;
}

//
// INgnStorageService
//

#if TARGET_OS_IPHONE
-(sqlite3 *) database{
	return self->database;
}

-(BOOL) execSQL: (NSString*)sqlQuery{
	return [self databaseExecSQL: sqlQuery];
}	

-(NSMutableDictionary*) favorites{
	return self->favorites;
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

#endif /* TARGET_OS_IPHONE */

@end
