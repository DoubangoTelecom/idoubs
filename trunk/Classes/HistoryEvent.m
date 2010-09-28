//
//  HistoryEvent.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/25/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "HistoryEvent.h"


/*================= HistoryEvent ======================*/

@implementation HistoryEvent

@synthesize type;
@synthesize seen;
@synthesize status;
@synthesize remoteParty;
@synthesize start;
@synthesize end;


-(HistoryEvent*)initWithType: (HistoryEventType_t)_type andRemoteParty: (NSString*)_remoteParty{
	if((self = [super init])){
		self->type = _type;
		self->remoteParty = [_remoteParty retain];
		
		self->start = [[NSDate date] timeIntervalSince1970];
		self->end = self->start;
		self->status = HistoryEventStatus_Missed;
	}
	return self;
}

@end






/*================= HistoryEvent ======================*/
@implementation HistoryAVCallEvent

-(HistoryAVCallEvent*)initAudioCallEvent: (NSString*)_remoteParty{
	if((self = (HistoryAVCallEvent*)[super initWithType:HistoryEventType_Audio andRemoteParty:_remoteParty])){
	}
	return self;
}

-(HistoryAVCallEvent*)initAudioVideoCallEvent: (NSString*)_remoteParty{
	if((self = (HistoryAVCallEvent*)[super initWithType:HistoryEventType_AudioVideo andRemoteParty:_remoteParty])){
	}
	return self;
}

@end