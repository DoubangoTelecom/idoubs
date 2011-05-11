#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"
#import "media/NgnMediaType.h"

#define kNgnInviteEventArgs_Name @"NgnInviteEventArgs_Name"

typedef enum NgnInviteEventTypes_e {
	INVITE_EVENT_INCOMING,
    INVITE_EVENT_INPROGRESS,
    INVITE_EVENT_RINGING,
    INVITE_EVENT_EARLY_MEDIA,
    INVITE_EVENT_CONNECTED,
    INVITE_EVENT_TERMWAIT,
    INVITE_EVENT_TERMINATED,
    INVITE_EVENT_LOCAL_HOLD_OK,
    INVITE_EVENT_LOCAL_HOLD_NOK,
    INVITE_EVENT_LOCAL_RESUME_OK,
    INVITE_EVENT_LOCAL_RESUME_NOK,
    INVITE_EVENT_REMOTE_HOLD,
    INVITE_EVENT_REMOTE_RESUME
}
NgnInviteEventTypes_t;

@interface NgnInviteEventArgs : NgnEventArgs {
	long sessionId;
    NgnInviteEventTypes_t eventType;
    NgnMediaType_t mediaType;
    NSString* sipPhrase;
}

-(NgnInviteEventArgs*)initWithSessionId: (long)sessionId andEvenType: (NgnInviteEventTypes_t)eventType andMediaType: (NgnMediaType_t)mediaType andSipPhrase: (NSString*)sipPhrase;

@property(readonly) long sessionId;
@property(readonly) NgnInviteEventTypes_t eventType;
@property(readonly) NgnMediaType_t mediaType;
@property(readonly,retain) NSString* sipPhrase;

@end
