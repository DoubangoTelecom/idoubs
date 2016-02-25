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
#import "NgnInviteSession.h"
#import "NgnEngine.h"
#import "NgnStringUtils.h"

#import "MediaSessionMgr.h"
 

@implementation NgnInviteSession

-(NgnInviteSession*)initWithSipStack:(NgnSipStack *)sipStack
{
	if((self = (NgnInviteSession*)[super initWithSipStack:sipStack])){
		mState = INVITE_STATE_NONE;
		_mMediaSessionMgr = tsk_null;
		mRemoteDeviceInfo = [[NgnDeviceInfo alloc] init];
		
		mDidConnect = NO;
	}
	return self;
}

-(void)dealloc
{
	_mMediaSessionMgr = tsk_null; // Not yours
	[mRemoteDeviceInfo release];
	[super dealloc];
}

-(NgnMediaType_t) getMediaType
{
	return mMediaType;
}

-(void) setMediaType:(NgnMediaType_t)mediaType_
{
	mMediaType = mediaType_;
}

-(InviteState_t) getState
{
	return mState;
}

-(void) setState: (InviteState_t)newState
{
	if(mState == newState){
		return;
	}
	mState = newState;
	NgnHistoryEvent* event = [[self getHistoryEvent] retain];
	
	switch (mState) {
		case INVITE_STATE_INCOMING:
		{
			mEventIncoming = YES;
			if(event){
				event.status = HistoryEventStatus_Missed;
			}
			break;
		}
			
		case INVITE_STATE_INPROGRESS:
		{
			mEventIncoming = NO;
			if(event){
				event.status = HistoryEventStatus_Outgoing;
			}
			break;
		}
			
		case INVITE_STATE_INCALL:
		{
			mDidConnect = YES;
			if(event){
				event.start = [[NSDate date] timeIntervalSince1970];
				event.end = event.start;
				event.status = mEventIncoming ? HistoryEventStatus_Incoming : HistoryEventStatus_Outgoing;
			}
			break;
		}
		case INVITE_STATE_TERMINATING:
		case INVITE_STATE_TERMINATED:
		{
			if(event && !mEventAdded){
				mEventAdded = YES;
				if(event.status != HistoryEventStatus_Missed){
					event.end = mDidConnect ? [[NSDate date] timeIntervalSince1970] : event.start;
				}
				[[NgnEngine sharedInstance].historyService addEvent: event];
			}
			break;
		}
	}
	
	[event release];
}

-(BOOL) isActive
{
	return mState != INVITE_STATE_NONE
	&& mState != INVITE_STATE_TERMINATING 
	&& mState != INVITE_STATE_TERMINATED;
}

-(BOOL) active
{
	return [self isActive];
}

-(BOOL) isLocalHeld
{
	return mLocalHold;
}

-(void) setLocalHold: (BOOL)held
{
	mLocalHold = held;
}

-(BOOL) isRemoteHeld{
	return mRemoteHold;
}

-(void) setRemoteHold: (BOOL)held
{
	mRemoteHold = held;
}

-(NgnHistoryEvent*) getHistoryEvent
{
	[NSException raise:NSInternalInconsistencyException 
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
	return nil;
}

-(NSString*)getRemotePartyDisplayName
{
	return self.historyEvent ? self.historyEvent.remotePartyDisplayName : self.remotePartyUri;
}

-(NgnDeviceInfo*)getRemoteDeviceInfo
{
	return mRemoteDeviceInfo;
}

// override from SipSession
-(void)setRemotePartyUri:(NSString*)uri
{
	[super setRemotePartyUri:uri];
	if([self getHistoryEvent]){
		[[self getHistoryEvent] setRemotePartyWithValidUri:uri];
	}
}

-(const MediaSessionMgr*) getMediaSessionMgr
{
	if(!_mMediaSessionMgr){
		if(!self.session){
			TSK_DEBUG_ERROR("Null session");
		}
		else {
			_mMediaSessionMgr = dynamic_cast<InviteSession*>(const_cast<SipSession*>(self.session))->getMediaMgr();
		}
	}
	return _mMediaSessionMgr;
}

-(BOOL) sendInfoWithContentData:(NSData*)content contentType:(NSString*)ctype
{
	if(!self.session){
		TSK_DEBUG_ERROR("Null session");
		return NO;
	}
	if(!content || !ctype){
		TSK_DEBUG_ERROR("Invalid parameter");
		return NO;
	}
	
	ActionConfig* _config= new ActionConfig();
	_config->addHeader("Content-Type", [NgnStringUtils toCString:ctype]);
	BOOL ret = dynamic_cast<InviteSession*>(self.session)->sendInfo([content bytes], [content length], _config);
	delete _config;
	
	return ret;
}

-(BOOL) sendInfoWithContentString:(NSString*)content contentType:(NSString*)ctype
{
	if(!content || !ctype){
		TSK_DEBUG_ERROR("Invalid parameter");
		return NO;
	}
	return [self sendInfoWithContentData:[content dataUsingEncoding:NSUTF8StringEncoding] contentType:ctype];
}

@end
