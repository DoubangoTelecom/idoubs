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
 */
#import <Foundation/Foundation.h>

#import "sip/NgnSipSession.h"

#undef NgnMessagingSessionMutableArray
#undef NgnMessagingSessionArray
#define NgnMessagingSessionMutableArray	NSMutableArray
#define NgnMessagingSessionArray		NSArray

class MessagingSession;
class ActionConfig;
class SipMessage;

@interface NgnMessagingSession : NgnSipSession {
	MessagingSession* _mSession;
}

-(BOOL) sendBinaryMessage:(NSString*)asciiText smscValue:(NSString*)smsc;
-(BOOL) sendData:(NSData*)data contentType:(NSString*)ctype actionConfig:(ActionConfig*)config;
-(BOOL) sendData:(NSData*)data contentType:(NSString*)ctype;
-(BOOL) sendTextMessage:(NSString*) asciiText contentType:(NSString*)ctype actionConfig:(ActionConfig*)config;
-(BOOL) sendTextMessage:(NSString*) asciiText contentType:(NSString*)ctype;
-(BOOL) acceptWithActionConfig: (ActionConfig*)config;
-(BOOL) accept;
-(BOOL) rejectWithActionConfig: (ActionConfig*)config;
-(BOOL) reject;

+(NgnMessagingSession*) takeIncomingSessionWithSipStack:(NgnSipStack*)sipStack andMessagingSession:(MessagingSession**)session andSipMessage:(const SipMessage*)sipMessage;
+(NgnMessagingSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack andToUri:(NSString*)toUri;
+(NgnMessagingSession*) getSessionWithId:(long)sessionId;
+(BOOL) hasSessionWithId:(long)sessionId;
+(void) releaseSession: (NgnMessagingSession**) session;
+(NgnMessagingSession*) sendBinaryMessageWithSipStack:(NgnSipStack*)sipStack andToUri:(NSString*)uri andMessage:(NSString*)asciiText smscValue:(NSString*)smsc;
+(NgnMessagingSession*) sendDataWithSipStack:(NgnSipStack*)sipStack andToUri:(NSString*)uri andData:(NSData*) data andContentType:(NSString*) ctype andActionConfig:(ActionConfig*) config;
+(NgnMessagingSession*) sendDataWithSipStack:(NgnSipStack*)sipStack andToUri:(NSString*)uri andData:(NSData*) data andContentType:(NSString*) ctype;
+(NgnMessagingSession*) sendTextMessageWithSipStack:(NgnSipStack*)sipStack andToUri:(NSString*)uri andMessage:(NSString*)asciiText andContentType:(NSString*)ctype andActionConfig:(ActionConfig*)config;
+(NgnMessagingSession*) sendTextMessageWithSipStack:(NgnSipStack*)sipStack andToUri:(NSString*)uri andMessage:(NSString*)asciiText andContentType:(NSString*)ctype;

@end
