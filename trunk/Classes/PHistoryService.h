//
//  PHistoryService.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/29/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HistoryEvent.h"
#import "PService.h"

@protocol PHistoryService  <PService>

-(BOOL) isLoadingHistory;
-(BOOL) addEvent: (HistoryEvent*)event;
-(BOOL) updateEvent: (HistoryEvent*)event;
-(BOOL) deleteEvent: (HistoryEvent*)event;
-(BOOL) clear;
-(NSMutableArray*)events;

@end
