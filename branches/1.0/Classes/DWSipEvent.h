/*
 * Copyright (C) 2010 Mamadou Diop.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango.org>
 *       
 * This file is part of idoubs Project (http://code.google.com/p/idoubs)
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
	
	tsip_event_t* event;
}

-(DWSipEvent*) initWithEvent: (tsip_event_t*) event;

@property(readonly) tsip_event_type_t baseType;
@property(readonly) short code;
@property(readonly) NSString* phrase;
@property(readonly) DWSipSession* baseSession;
@property(readonly) DWSipMessage* message;
@property(readonly) DWSipStack* stack;
@property(readonly) tsip_event_t* event;

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



/* ======================== DWInviteEvent ========================*/
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
