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

#undef TAG
#define kTAG @"NgnStorageService///: "
#define TAG kTAG

#if TARGET_OS_IPHONE

#undef kDataBaseName
#define kDataBaseName @"NgnDataBase.db"

static BOOL sDataBaseInitialized = NO;
static NSString* sDataBasePath = nil;

@interface NgnStorageService (DataBase)
+(BOOL) databaseCheckAndCopy;
-(BOOL) databaseOpen;
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
		//[fileManager removeItemAtPath:self->databasePath error:nil];
		// for example you can remove the database if the app_database_version is different
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
	if(!mDatabase && sqlite3_open([sDataBasePath UTF8String], &mDatabase) != SQLITE_OK){
		NgnNSLog(TAG,@"Failed to open history database from: %@", sDataBasePath);
		return NO;
	}
	return YES;
}

-(BOOL) databaseClose{
	if(mDatabase){
		sqlite3_close(mDatabase);
		mDatabase = nil;
	}
	return YES;
}

@end

#endif /* #if TARGET_OS_IPHONE */


@implementation NgnStorageService

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	BOOL ok = YES;
	
#if TARGET_OS_IPHONE
	if([NgnStorageService databaseCheckAndCopy]){
		ok = [self databaseOpen];
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
	return mDatabase;
}
#endif

@end
