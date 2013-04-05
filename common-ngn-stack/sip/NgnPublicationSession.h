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
#import "sip/NgnPresenceStatus.h"

class PublicationSession;
class ActionConfig;

@interface NgnPublicationSession : NgnSipSession {
	PublicationSession *_mSession;
	NSString *mEvent;
	NSString *mContentType;
}

@property(retain,getter=getContentType,setter=setContentType:) NSString* contentType;
@property(retain,getter=getEvent,setter=setEvent:) NSString* event;

+(NSData*) createPresenceContentWithEntityUri:(NSString*)entityUri andStatus:(NgnPresenceStatus_t)status  andNote:(NSString*)note;
+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack 
												andToUri:(NSString*)toUri
												andEvent:(NSString*)event
												andContentType:(NSString*)contentType;
+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack 
												andToUri:(NSString*)toUri;
+(NgnPublicationSession*) createOutgoingSessionWithStack:(NgnSipStack*)sipStack;
+(NgnPublicationSession*) getSessionWithId:(long)sessionId;
+(BOOL) hasSessionWithId:(long)sessionId;
+(void) releaseSession:(NgnPublicationSession**) session;

-(BOOL)publishContent:(NSData*)content andEvent:(NSString*)event andContentType:(NSString*)contentType;
-(BOOL)publishContent:(NSData*)content;
-(BOOL)publishContent:(NSData*)content andActionConfig:(ActionConfig*)_config;
-(BOOL)unPublishWithConfig:(ActionConfig*)_config;
-(BOOL)unPublish;

-(void)setContentType:(NSString *)contentType;
-(NSString *)getContentType;
-(void)setEvent:(NSString *)event;
-(NSString *)getEvent;

@end
