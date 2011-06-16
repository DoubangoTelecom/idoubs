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
#import "media/NgnEventPackageType.h"

#define kNgnSubscriptionEventArgs_Name @"NgnSubscriptionEventArgs_Name"

typedef enum NgnSubscriptionEventTypes_e {
	SUBSCRIPTION_OK,
	SUBSCRIPTION_NOK,
	SUBSCRIPTION_INPROGRESS,
	UNSUBSCRIPTION_OK,
	UNSUBSCRIPTION_NOK,
	UNSUBSCRIPTION_INPROGRESS,
	INCOMING_NOTIFY
}
NgnSubscriptionEventTypes_t;

@interface NgnSubscriptionEventArgs : NgnEventArgs {
	long sessionId;
	NgnSubscriptionEventTypes_t eventType;
	short sipCode;
    NSString *sipPhrase;
    NSData  *content;
    NSString *contentType;
    NgnEventPackageType_t eventPackage;
}

-(NgnSubscriptionEventArgs*) initWithSessionId:(long)sessionId 
		andEventType:(NgnSubscriptionEventTypes_t)eventType 
		andSipCode:(short)sipCode
		andSipPhrase:(NSString*)sipPhrase 
		andContent:(NSData*)content 
		andContentType:(NSString*)contentType 
		andEventPackage:(NgnEventPackageType_t)eventPackage;

-(NgnSubscriptionEventArgs*) initWithSessionId:(long)sessionId 
		andEventType:(NgnSubscriptionEventTypes_t)eventType 
		andSipCode:(short)sipCode
		andSipPhrase:(NSString*)sipPhrase 
		andEventPackage:(NgnEventPackageType_t)eventPackage;

@property(readonly) long sessionId;
@property(readonly) NgnSubscriptionEventTypes_t eventType;
@property(readonly) short sipCode;
@property(readonly) NSString* sipPhrase;
@property(readonly) NSData  *content;
@property(readonly) NSString *contentType;
@property(readonly) NgnEventPackageType_t eventPackage;

@end
