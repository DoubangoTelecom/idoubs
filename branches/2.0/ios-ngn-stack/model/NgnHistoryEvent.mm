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
#import "NgnHistoryEvent.h"
#import "NgnHistoryAVCallEvent.h"
#import "NgnHistorySMSEvent.h"

@implementation NgnHistoryEvent

@synthesize id;
@synthesize mediaType;
@synthesize start;
@synthesize end;
@synthesize remoteParty;
@synthesize seen;
@synthesize status;

-(NgnHistoryEvent*) initWithMediaType: (NgnMediaType_t)_mediaType andRemoteParty: (NSString*)_remoteParty{
	if((self = [super init])){
		self.mediaType = _mediaType;
		self.remoteParty = [_remoteParty retain];
		
		self.start = [[NSDate date] timeIntervalSince1970];
		self.end = self.start;
		self.status = HistoryEventStatus_Missed;
	}
	return self;
}

+(NgnHistoryAVCallEvent*) createAudioVideoEventWithRemoteParty: (NSString*)_remoteParty andVideo: (BOOL)video{
	NgnHistoryAVCallEvent* event = [[[NgnHistoryAVCallEvent alloc] init: video withRemoteParty: _remoteParty] autorelease];
	return event;
}

+(NgnHistorySMSEvent*) createSMSEventWithStatus: (HistoryEventStatus_t) _status andRemoteParty:(NSString*)_remoteParty{
	return [NgnHistoryEvent createSMSEventWithStatus: _status andRemoteParty: _remoteParty andContent: nil];
}

+(NgnHistorySMSEvent*) createSMSEventWithStatus: (HistoryEventStatus_t) _status andRemoteParty:(NSString*)_remoteParty andContent: (NSData*)_content{
	NgnHistorySMSEvent* event = [[[NgnHistorySMSEvent alloc] initWithStatus: _status andRemoteParty:_remoteParty andContent: _content] autorelease];
	return event;
}

-(void)dealloc{
	[remoteParty release];
	
	[super dealloc];
}

@end
