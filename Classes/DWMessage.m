//
//  DWSipMessage.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/30/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "DWMessage.h"


/* ======================== DWSdpMessage ========================*/
@implementation DWSdpMessage

-(id) initWithMessage: (tsdp_message_t*)_message{
	self = [super init];
	if(self){
		self->message = tsk_object_ref(_message);
	}
	return self;
}

-(void) dealloc{
	TSK_OBJECT_SAFE_FREE(self->message);
	[super dealloc];
}

@end


/* ======================== DWSipMessage ========================*/
@implementation DWSipMessage

-(DWSipMessage*) initWithMessage: (tsip_message_t*)_message{
	self = [super init];
	if(self){
		self->message = tsk_object_ref(_message);
		self->sdpMessage = nil;
	}
	return self;
}

-(void) dealloc{
	TSK_OBJECT_SAFE_FREE(self->message);
	[self->sdpMessage release];
	[super dealloc];
}

@end