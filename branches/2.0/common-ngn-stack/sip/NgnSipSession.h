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

#import "sip/NgnSipStack.h"

#import "SipSession.h"

typedef enum ConnectionState_e{
	CONN_STATE_NONE,
	CONN_STATE_CONNECTING,
	CONN_STATE_CONNECTED,
	CONN_STATE_TERMINATING,
	CONN_STATE_TERMINATED,
}
ConnectionState_t;

@interface NgnSipSession : NSObject {
	NgnSipStack* mSipStack;
    BOOL mOutgoing;
    NSString* mFromUri;
    NSString* mToUri;
    NSString* mCompId;
    NSString* mRemotePartyUri;
    NSString* mRemotePartyDisplayName;
    long mId;
    ConnectionState_t mConnectionState;
}

@property(readonly, getter=getId) long id;
@property(readonly, getter=getConnectionState) ConnectionState_t connectionState;
@property(readwrite, assign, getter=getRemotePartyUri, setter=setRemotePartyUri:) NSString* remotePartyUri;
@property(readonly, getter=getFromUri) NSString* fromUri;
@property(readonly, getter=getToUri) NSString* toUri;
@property(readonly, getter=isConnected) BOOL connected;
@property(readonly, getter=getSession) SipSession* session;

-(NgnSipSession*)initWithSipStack:(NgnSipStack*)sipStack;
-(void)initialize;
-(long)getId;
-(NSNumber*)getIdAsNumber;
-(BOOL)isOutgoing;
-(NgnSipStack*)getSipStack;
-(BOOL)addHeaderWithName:(NSString*)name andValue:(NSString*)value;
-(BOOL)removeHeaderWithName:(NSString*)name;
-(BOOL)addCapsWithName:(NSString*)name;
-(BOOL)addCapsWithName:(NSString*)name andValue:(NSString*)value;
-(BOOL)removeCapsWithName:(NSString*)name;
-(BOOL)isConnected;
-(ConnectionState_t)getConnectionState;
-(void)setConnectionState:(ConnectionState_t)state;
-(NSString*)getFromUri;
-(BOOL)setFromUri:(NSString*)uri;
-(NSString*)getToUri;
-(BOOL)setToUri:(NSString*)uri;
-(NSString*)getRemotePartyUri;
-(void)setRemotePartyUri:(NSString*)uri;
-(void)setSigCompId:(NSString*)compId;
-(BOOL)setExpires:(unsigned)expires;
-(SipSession*)getSession;

@end
