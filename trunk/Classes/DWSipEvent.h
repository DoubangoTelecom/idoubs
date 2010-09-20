//
//  DWSipEvent.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/30/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DWSipStack;

@class DWSipSession;
@class DWInviteSession;
@class DWCallSession;
@class DWMsrpSession;
@class DWMessagingSession;
@class DWOptionsSession;
@class DWPublicationSession;
@class DWRegistrationSession;
@class DWSubscriptionSession;

@class DWSipMessage;


#import "tinysip.h"

/* ======================== DWSipEvent ========================*/
@interface DWSipEvent : NSObject {

	tsip_event_type_t baseType;
	short code;
	NSString* phrase;
	DWSipSession* baseSession;
	DWSipMessage* message;
	
@protected
	tsip_event_t* event;
}

-(DWSipEvent*) initWithEvent: (tsip_event_t*) event;

@property(readonly) tsip_event_type_t baseType;
@property(readonly) short code;
@property(readonly) NSString* phrase;
@property(readonly) DWSipSession* baseSession;
@property(readonly) DWSipMessage* message;

@end


/* ======================== DWDialogEvent ========================*/
@interface DWDialogEvent : DWSipEvent
{
}

-(DWDialogEvent*) initWithEvent: (tsip_event_t*) event;

@end


/* ======================== DWStackEvent ========================*/
@interface DWStackEvent : DWSipEvent
{
}

-(DWStackEvent*) initWithEvent: (tsip_event_t*) event;

@end



/* ======================== InviteEvent ========================*/
@interface DWInviteEvent : DWSipEvent
{
	
}

-(DWInviteEvent*) initWithEvent: (tsip_event_t*) event;

-(DWCallSession*) takeCallSessionOwnership;
-(DWMsrpSession*) takeMsrpSessionOwnership;

@property(readonly, assign) tsip_invite_event_type_t type;
@property(readonly, assign) DWInviteSession* session;

@end



/* ======================== DWMessagingEvent ========================*/
@interface DWMessagingEvent : DWSipEvent
{
}

-(DWMessagingEvent*) initWithEvent: (tsip_event_t*) event;

@property(readonly, assign) tsip_message_event_type_t type;
@property(readonly, assign) DWMessagingSession* session;

-(DWMessagingSession*) takeSessionOwnership;

@end



/* ======================== DWOptionsEvent ========================*/
@interface DWOptionsEvent : DWSipEvent
{
}

-(DWOptionsEvent*) initWithEvent: (tsip_event_t*) event;

@property(readonly, assign) tsip_options_event_type_t type;
@property(readonly, assign) DWOptionsSession* session;

@end


/* ======================== DWPublicationEvent ========================*/
@interface DWPublicationEvent : DWSipEvent
{
}

-(DWPublicationEvent*) initWithEvent: (tsip_event_t*) event;

@property(readonly, assign) tsip_publish_event_type_t type;
@property(readonly, assign) DWPublicationSession* session;

@end



/* ======================== DWRegistrationEvent ========================*/
@interface DWRegistrationEvent : DWSipEvent
{
}

-(DWRegistrationEvent*) initWithEvent: (tsip_event_t*) event;

@property(readonly, assign) tsip_register_event_type_t type;
@property(readonly) DWRegistrationSession* session;

+(NSString*) name;

@end


/* ======================== DWSubscriptionEvent ========================*/
@interface DWSubscriptionEvent : DWSipEvent
{
}

@property(readonly, assign) tsip_subscribe_event_type_t type;
@property(readonly, assign) DWSubscriptionSession* session;

@end
