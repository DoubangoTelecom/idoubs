#import "NgnInviteSession.h"


@implementation NgnInviteSession

-(NgnInviteSession*)initWithSipStack:(NgnSipStack *)sipStack{
	if((self = (NgnInviteSession*)[super initWithSipStack:sipStack])){
		mState = INVITE_STATE_NONE;
	}
	return self;
}

-(void)dealloc{
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

@end
