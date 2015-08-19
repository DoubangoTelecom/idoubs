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
#import "NgnHistoryEventArgs.h"


@implementation NgnHistoryEventArgs

@synthesize eventId;
@synthesize eventType;
@synthesize mediaType;

-(NgnHistoryEventArgs*)initWithEventId: (long long)_eventId andEventType: (NgnHistoryEventTypes_t)_eventType{
	if((self = [super init])){
		self->eventId = _eventId;
		self->eventType = _eventType;
		self->mediaType = MediaType_None;
	}
	
	return self;
}

-(NgnHistoryEventArgs*)initWithEventType: (NgnHistoryEventTypes_t)_eventType{
	return [self initWithEventId: 0 andEventType: _eventType];
}

-(void)dealloc{
	[super dealloc];
}

@end
