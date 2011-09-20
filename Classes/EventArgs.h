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


/* ======================== EventArgs ========================*/
@interface EventArgs : NSObject {
@protected
	NSString* phrase;
	short sipCode;
	NSMutableDictionary* extras;
}

-(EventArgs*)initWithCode: (short)code andPhrase: (NSString*)_phrase;
-(void)putExtraWithKey: (NSString*)key andValue:(NSString*)value;
-(NSString*)extraValueForKey: (NSString*)key;

@property(readonly) NSString* phrase;
@property(readonly) short sipCode;
@end


/* ======================== RegistrationEventArgs ========================*/
typedef enum RegistrationEventTypes_e {
	REGISTRATION_OK,
	REGISTRATION_NOK,
	REGISTRATION_INPROGRESS,
	UNREGISTRATION_OK,
	UNREGISTRATION_NOK,
	UNREGISTRATION_INPROGRESS
}
RegistrationEventTypes_t;

@interface RegistrationEventArgs : EventArgs {
	RegistrationEventTypes_t type;
}

-(RegistrationEventArgs*)initWithType: (RegistrationEventTypes_t)type andSipCode: (short)sipCode andPhrase: (NSString*)phrase;
+(NSString* const) eventName;


@property(readonly) RegistrationEventTypes_t type;
@end


/* ======================== InviteEventArgs ========================*/
typedef enum InviteEventTypes_e {
	INVITE_INCOMING,
	INVITE_INPROGRESS,
	INVITE_RINGING,
	INVITE_EARLY_MEDIA,
	INVITE_CONNECTED,
	INVITE_TERMWAIT,
	INVITE_DISCONNECTED,
	INVITE_LOCAL_HOLD_OK,
	INVITE_LOCAL_HOLD_NOK,
	INVITE_LOCAL_RESUME_OK,
	INVITE_LOCAL_RESUME_NOK,
	INVITE_REMOTE_HOLD,
	INVITE_REMOTE_RESUME
}
InviteEventTypes_t;

@interface InviteEventArgs : EventArgs {
	InviteEventTypes_t type;
}

-(InviteEventArgs*)initWithType: (InviteEventTypes_t)type andSipCode: (short)sipCode andPhrase: (NSString*)phrase;
+(NSString* const) eventName;


@property(readonly) InviteEventTypes_t type;

@end


