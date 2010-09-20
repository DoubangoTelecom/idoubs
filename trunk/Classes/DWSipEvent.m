//
//  DWSipEvent.m
//  iDoubs
//
//  Created by Mamadou DIOP on 8/30/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "DWSipEvent.h"

#import "DWMessage.h"
#import "DWSipSession.h"

/* ======================== DWSipEvent ========================*/
@implementation DWSipEvent

@synthesize baseType;
@synthesize code;
//@synthesize baseSession;
//@synthesize message;
//@synthesize phrase;

-(DWSipEvent*) initWithEvent: (tsip_event_t*) _event{
	self = [super init];
	if(self){
		self->event = tsk_object_ref(_event);
		self->baseType = self->event->type;
		self->code = self->event->code;	
	}
	
	return self;
}


-(NSString*) phrase{
	if(self->phrase == nil){
		self->phrase = [[NSString alloc] initWithCString:event->phrase];
	}
	return self->phrase;
}


-(DWSipSession*) baseSession{
	return (DWSipSession*)(tsip_ssession_get_userdata(self->event->ss));
}

-(DWSipMessage*) message{
	if(self->message == nil){
		self->message = [[DWSipMessage alloc] initWithMessage:self->event->sipmessage];
	}
	return self->message;
}


-(void) dealloc{
	TSK_OBJECT_SAFE_FREE(self->event);
	[self->message release];
	[self->phrase release];
	
	[super dealloc];
}

@end



/* ======================== DWDialogEvent ========================*/
@implementation DWDialogEvent

-(DWDialogEvent*) initWithEvent: (tsip_event_t*) _event{
	self = (DWDialogEvent*)[super initWithEvent:_event];
	return self;
}

-(void) dealloc{	
	[super dealloc];
}

@end

/* ======================== DWStackEvent ========================*/
@implementation DWStackEvent

-(DWStackEvent*) initWithEvent: (tsip_event_t*) _event{
	self = (DWStackEvent*)[super initWithEvent:_event];
	return self;
}

-(void) dealloc{	
	[super dealloc];
}

@end



/* ======================== DWRegistrationEvent ========================*/
@implementation DWRegistrationEvent

@synthesize type;
@synthesize session;

-(DWRegistrationEvent*) initWithEvent: (tsip_event_t*) _event{
	self = (DWRegistrationEvent*)[super initWithEvent:_event];
	if(self){
		self->type = TSIP_REGISTER_EVENT(self->event)->type;
		self->session = [[self.baseSession isMemberOfClass:[DWRegistrationSession class]] ? ((DWRegistrationSession*)self.baseSession) : nil retain];
	}
	return self;
}

+(NSString*) name{
	return @"RegistrationEvent";
}

-(void) dealloc{
	[self->session release];
	[super dealloc];
}

@end