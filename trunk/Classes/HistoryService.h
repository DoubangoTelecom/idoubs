//
//  HistoryService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/26/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "PHistoryService.h"
#import "HistoryEvent.h"

@interface HistoryService :  NSObject<PHistoryService> {
	BOOL loading;
	NSString* databasePath;
	sqlite3 *database;
	
	NSMutableArray *events;
}

@end
