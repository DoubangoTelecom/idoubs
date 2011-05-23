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
#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"
#import "media/NgnMediaType.h"

typedef enum NgnHistoryEventTypes_e {
	HISTORY_EVENT_ITEM_ADDED,
	HISTORY_EVENT_ITEM_REMOVED,
	HISTORY_EVENT_ITEM_UPDATED,
	HISTORY_EVENT_ITEM_MOVED,
	
	HISTORY_EVENT_RESET,
}
NgnHistoryEventTypes_t;

#define kNgnHistoryEventArgs_Name @"NgnHistoryEventArgs_Name"

@interface NgnHistoryEventArgs : NgnEventArgs {
	long long eventId;
	NgnHistoryEventTypes_t eventType;
	NgnMediaType_t mediaType;
}

@property(readonly) long long eventId;
@property(readonly) NgnHistoryEventTypes_t eventType;
@property(readwrite) NgnMediaType_t mediaType;

-(NgnHistoryEventArgs*)initWithEventId: (long long)eventId andEventType: (NgnHistoryEventTypes_t)eventType;
-(NgnHistoryEventArgs*)initWithEventType: (NgnHistoryEventTypes_t)eventType;

@end
