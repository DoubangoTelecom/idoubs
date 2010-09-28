//
//  HistoryService.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/26/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "HistoryService.h"

#define HISTORY_DATABASE_NAME @"HistoryDatabase.sql"


/* ================== HistoryService (DataBase) ================= */
@interface HistoryService (DataBase)
-(BOOL) databaseCheckAndCopy;
-(BOOL) databaseLoadAVCalls;
-(BOOL) databaseOpen;
-(BOOL) databaseClose;
-(BOOL) databaseAddAVCall:(HistoryAVCallEvent*)event;
-(BOOL) databaseRemoveEvent:(HistoryEvent*)event;
@end


@implementation HistoryService(DataBase)

-(BOOL) databaseCheckAndCopy{
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	self->databasePath = [documentsDir stringByAppendingPathComponent:HISTORY_DATABASE_NAME];
	
	NSLog(@"History database path:%@", self->databasePath);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:self->databasePath]){
		//[fileManager removeItemAtPath:self->databasePath error:nil];
		return YES;
	}
	
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:HISTORY_DATABASE_NAME];
	
	NSError* error = nil;
	if(![fileManager copyItemAtPath:databasePathFromApp toPath:self->databasePath error:&error]){
		[fileManager release];
		NSLog(@"Failed to copy database to the file system: %@", error);
		return NO;
	}
	
	[fileManager release];
	
	return YES;
}

-(BOOL) databaseLoadAVCalls{
	if(!self->database){
		NSLog(@"Invalid database");
		return NO;
	}
	
	const char *sqlStatement = "select id,seen,status,type,remoteParty,start,end from hist_av order by start desc";
	sqlite3_stmt *compiledStatement;
	HistoryAVCallEvent* avCallEvent;
	int ret;
	if((ret = sqlite3_prepare_v2(self->database, sqlStatement, -1, &compiledStatement, NULL)) == SQLITE_OK) {
		while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
			
			//long long _id = sqlite3_column_int64(compiledStatement, 0);
			BOOL seen = sqlite3_column_int(compiledStatement, 1);
			HistoryEventStatus_t status = (HistoryEventStatus_t)sqlite3_column_int(compiledStatement, 2);
			HistoryEventType_t type = (HistoryEventType_t)sqlite3_column_int(compiledStatement, 3);
			NSString *remoteParty = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
			double start = sqlite3_column_double(compiledStatement, 5);
			double end = sqlite3_column_double(compiledStatement, 6);
			
			switch (type) {
				case HistoryEventType_AudioVideo:
					avCallEvent = [[HistoryAVCallEvent alloc]initAudioVideoCallEvent:remoteParty];
					break;
				default:
					avCallEvent = [[HistoryAVCallEvent alloc]initAudioCallEvent:remoteParty];
					break;
			}
			
			avCallEvent.seen = seen;
			avCallEvent.status = status;
			avCallEvent.start = start;
			avCallEvent.end = end;
			
			[self->events addObject:avCallEvent];
		}
	}
	sqlite3_finalize(compiledStatement);
	
	return YES;
}

-(BOOL) databaseOpen{	
	if(!self->database && sqlite3_open([self->databasePath UTF8String], &self->database) != SQLITE_OK){
		NSLog(@"Failed to open history database from: %@", self->databasePath);
		return NO;
	}
	return YES;
}

-(BOOL) databaseClose{
	if(self->database){
		sqlite3_close(self->database);
		self->database = nil;
	}
	
	return YES;
}


-(BOOL) databaseAddAVCall:(HistoryAVCallEvent*)event{
	if(!self->database){
		NSLog(@"Invalid database");
		return NO;
	}
	
	BOOL success = NO;
	NSString* sqlStatement = [@"insert into hist_av (seen,status,type,remoteParty,start,end) values" 
					 stringByAppendingFormat:@"(%d,%d,%d,'%@',%lld,%lld)",
					 event.seen ? 1 : 0,
					 (int)event.status,
					 (int)event.type,
					 event.remoteParty,
					 event.start,
					 event.end
					 ];
	
	sqlite3_stmt *compiledStatement;
	int ret;
	
	if((ret = sqlite3_prepare_v2(self->database, [sqlStatement UTF8String], -1, &compiledStatement, NULL)) == SQLITE_OK) {
		success = ((ret = sqlite3_step(compiledStatement))==SQLITE_DONE);
	}
	sqlite3_finalize(compiledStatement);
	
	if(success){
		[self->events insertObject:event atIndex:0];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HistoryChanged" object:self];
	}
	
	return success;
}

-(BOOL) databaseRemoveEvent:(HistoryEvent*)event{
	if(!self->database){
		NSLog(@"Invalid database");
		return NO;
	}
	
	return NO;
}

@end

@implementation HistoryService

-(id)init{
	if((self = [super init])){
		self->events = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc{
	[self->events dealloc];
	
	[super dealloc];
}

/* ================== PService ================= */
-(BOOL) start{
	if(![self databaseCheckAndCopy]){
		NSLog(@"Failed to copy history dataBase");
		return NO;
	}
	
	if(![self databaseOpen]){
		NSLog(@"Failed to open history dataBase");
		return NO;
	}
	
	if(![self databaseLoadAVCalls]){
		NSLog(@"Failed to load history dataBase values (AV Calls)");
		return NO;
	}
	
	return YES;
}

-(BOOL) stop{
	if(![self databaseClose]){
		return NO;
	}
	return YES;
}




/* ================== PHistoryService ================= */
-(BOOL) isLoadingHistory{
	return self->loading;
}

-(BOOL) addEvent: (HistoryEvent*)event{
	switch (event.type) {
		case HistoryEventType_Audio:
		case HistoryEventType_AudioVideo:
			return [self databaseAddAVCall: (HistoryAVCallEvent*)event];
			break;
		default:
			return NO;
	}
}

-(BOOL) updateEvent: (HistoryEvent*)event{
	return NO;
}

-(BOOL) deleteEvent: (HistoryEvent*)event{
	return NO;
}

-(BOOL) clear{
	return NO;
}

-(NSMutableArray*)events{
	return self->events;
}


@end
