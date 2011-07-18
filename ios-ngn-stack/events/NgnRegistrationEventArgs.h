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

#define kNgnRegistrationEventArgs_Name @"NgnRegistrationEventArgs_Name"

#define kExtraRegistrationEventArgsRetryAfter @"retry-after"

typedef enum NgnRegistrationEventTypes_e {
	REGISTRATION_OK,
    REGISTRATION_NOK,
    REGISTRATION_INPROGRESS,
    UNREGISTRATION_OK,
    UNREGISTRATION_NOK,
    UNREGISTRATION_INPROGRESS
}
NgnRegistrationEventTypes_t;

@interface NgnRegistrationEventArgs : NgnEventArgs {
	long sessionId;
	NgnRegistrationEventTypes_t eventType;
	short sipCode;
	NSString* sipPhrase;
}

-(NgnRegistrationEventArgs*)initWithSessionId: (long)sessionId andEventType: (NgnRegistrationEventTypes_t)type andSipCode: (short)sipCode andSipPhrase: (NSString*)phrase;

@property(readonly) long sessionId;
@property(readonly) NgnRegistrationEventTypes_t eventType;
@property(readonly) short sipCode;
@property(readonly,retain) NSString* sipPhrase;

@end
