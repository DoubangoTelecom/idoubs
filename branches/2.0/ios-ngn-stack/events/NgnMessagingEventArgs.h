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

typedef enum NgnMessagingEventTypes_e {
	MESSAGING_EVENT_CONNECTING,
	MESSAGING_EVENT_CONNECTED,
	MESSAGING_EVENT_TERMINATING,
	MESSAGING_EVENT_TERMINATED,
	
	MESSAGING_EVENT_INCOMING,
    MESSAGING_EVENT_OUTGOING,
    MESSAGING_EVENT_SUCCESS,
    MESSAGING_EVENT_FAILURE
}
NgnMessagingEventTypes_t;

#define kNgnMessagingEventArgs_Name @"NgnMessagingEventArgs_Name"

#define kExtraMessagingEventArgsCode @"code"
#define kExtraMessagingEventArgsFrom @"from" // For backward compatibility do not remove
#define kExtraMessagingEventArgsFromUri kExtraMessagingEventArgsFrom
#define kExtraMessagingEventArgsFromUserName @"username"
#define kExtraMessagingEventArgsFromDisplayname @"displayname"
#define kExtraMessagingEventArgsDate @"date"
#define kExtraMessagingEventArgsContentType @"contentType"
#define kExtraMessagingEventArgsContentTransferEncoding @"contentTransferEncoding"

@interface NgnMessagingEventArgs : NgnEventArgs {
	long sessionId;
	NgnMessagingEventTypes_t eventType;
    NSString* sipPhrase;
    NSData* payload;
}

@property(readonly) long sessionId;
@property(readonly) NgnMessagingEventTypes_t eventType;
@property(readonly) NSString* sipPhrase;
@property(readonly) NSData* payload;

-(NgnMessagingEventArgs*)initWithSessionId: (long)sessionId andEventType: (NgnMessagingEventTypes_t)eventType andPhrase: (NSString*)phrase andPayload: (NSData*)payload;

@end

