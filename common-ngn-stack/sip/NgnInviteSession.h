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
#import "model/NgnHistoryEvent.h"
#import "model/NgnDeviceInfo.h"
#import "media/NgnMediaType.h"

class MediaSessionMgr;

typedef enum InviteState_e{
	INVITE_STATE_NONE,
	INVITE_STATE_INCOMING,
	INVITE_STATE_INPROGRESS,
	INVITE_STATE_REMOTE_RINGING,
	INVITE_STATE_EARLY_MEDIA,
	INVITE_STATE_INCALL,
	INVITE_STATE_TERMINATING,
	INVITE_STATE_TERMINATED,
}
InviteState_t;

@interface NgnInviteSession : NgnSipSession {
	NgnMediaType_t mMediaType;
    InviteState_t mState;
	BOOL mRemoteHold;
    BOOL mLocalHold;
	BOOL mEventAdded;
	BOOL mEventIncoming;
	BOOL mDidConnect;
	NgnDeviceInfo* mRemoteDeviceInfo;
	
	
	const MediaSessionMgr* _mMediaSessionMgr;
}

@property(readonly,getter=getMediaType) NgnMediaType_t mediaType;
@property(readwrite,getter=getState,setter=setState:) InviteState_t state;
@property(readonly) BOOL active;
@property(readonly,getter=getHistoryEvent) NgnHistoryEvent* historyEvent;
@property(readonly,getter=getRemotePartyDisplayName) NSString* remotePartyDisplayName;
@property(readonly,getter=getRemoteDeviceInfo) NgnDeviceInfo* remoteDeviceInfo;

-(NgnInviteSession*) initWithSipStack: (NgnSipStack *)sipStack;
-(NgnMediaType_t)getMediaType;
-(void) setMediaType:(NgnMediaType_t)mediaType; // should only be called by the NgnSipService
-(InviteState_t) getState;
-(void) setState:(InviteState_t)newState;
-(BOOL) isActive;
-(BOOL) isLocalHeld;
-(void) setLocalHold:(BOOL)held;
-(BOOL) isRemoteHeld;
-(void) setRemoteHold:(BOOL)held;
-(NgnHistoryEvent*) getHistoryEvent;
-(NSString*)getRemotePartyDisplayName;
-(NgnDeviceInfo*)getRemoteDeviceInfo;
-(const MediaSessionMgr*)getMediaSessionMgr;

-(BOOL) sendInfoWithContentData:(NSData*)content contentType:(NSString*)ctype;
-(BOOL) sendInfoWithContentString:(NSString*)content contentType:(NSString*)ctype;

@end
