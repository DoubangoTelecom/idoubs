#import "NgnInviteSession.h"

#import "MediaSessionMgr.h"

@implementation NgnInviteSession

-(NgnInviteSession*)initWithSipStack:(NgnSipStack *)sipStack{
	if((self = (NgnInviteSession*)[super initWithSipStack:sipStack])){
		mState = INVITE_STATE_NONE;
		_mMediaSessionMgr = tsk_null;
	}
	return self;
}

-(void)dealloc{
	_mMediaSessionMgr = tsk_null; // Not yours
	[super dealloc];
}

-(NgnMediaType_t) getMediaType{
	return mMediaType;
}
-(NgnMediaType_t) mediaType{
	return [self getMediaType];
}

-(InviteState_t) getState{
	return mState;
}
-(InviteState_t) state{
	return [self getState];
}

-(void) setState: (InviteState_t)newState{
	mState = newState;
}
-(void) state: (InviteState_t)newState{
	[self setState: newState];
}

-(BOOL) isActive{
	return mState != INVITE_STATE_NONE
	&& mState != INVITE_STATE_TERMINATING 
	&& mState != INVITE_STATE_TERMINATED;
}

-(BOOL) active{
	return [self isActive];
}

-(BOOL) isLocalHeld{
	return mLocalHold;
}

-(void) setLocalHold: (BOOL)held{
	mLocalHold = held;
}

-(BOOL) isRemoteHeld{
	return mRemoteHold;
}

-(void) setRemoteHold: (BOOL)held{
	mRemoteHold = held;
}

-(const MediaSessionMgr*) getMediaSessionMgr{
	if(!_mMediaSessionMgr){
		const SipSession* _session = [self getSession];
		if(!_session){
			TSK_DEBUG_ERROR("Null session");
		}
		else {
			_mMediaSessionMgr = dynamic_cast<InviteSession*>(
															 const_cast<SipSession*>(_session)
															 )->getMediaMgr();
		}
	}
	return _mMediaSessionMgr;
}

@end
