#import <Foundation/Foundation.h>

#import "NgnSipSession.h"
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
	
	const MediaSessionMgr* _mMediaSessionMgr;
}

@property(readonly) NgnMediaType_t mediaType;
@property(readwrite) InviteState_t state;
@property(readonly) BOOL active;

-(NgnInviteSession*) initWithSipStack: (NgnSipStack *)sipStack;
-(NgnMediaType_t) getMediaType;
-(InviteState_t) getState;
-(void) setState: (InviteState_t)newState;
-(BOOL) isActive;
-(BOOL) isLocalHeld;
-(void) setLocalHold: (BOOL)held;
-(BOOL) isRemoteHeld;
-(void) setRemoteHold: (BOOL)held;
-(const MediaSessionMgr*) getMediaSessionMgr;

@end
