#import <Foundation/Foundation.h>

#import "services/INgnConfigurationService.h"
#import "services/impl/NgnBaseService.h"
#import "sip/NgnInviteSession.h"

#if TARGET_OS_IPHONE
#	import "media/NgnProxyVideoConsumer.h"
#	import "media/NgnProxyVideoProducer.h"
#endif

#undef NgnAVSessionMutableArray
#undef NgnAVSessionArray
#define NgnAVSessionMutableArray	NSMutableArray
#define NgnAVSessionArray	NSArray

class CallSession;
class SipMessage;
class ActionConfig;

@interface NgnAVSession : NgnInviteSession {
	CallSession* _mSession;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	
#if TARGET_OS_IPHONE
	BOOL mConsumersAndProducersInitialzed;
	NgnProxyVideoConsumer* mVideoConsumer;
	NgnProxyVideoProducer* mVideoProducer;
#endif
}

-(BOOL) makeCall: (NSString*) remoteUri;
-(BOOL) makeVideoSharingCall: (NSString*) remoteUri;
-(BOOL) acceptCallWithConfig: (ActionConfig*)config;
-(BOOL) acceptCall;
-(BOOL) hangUpCallWithConfig: (ActionConfig*)config;
-(BOOL) hangUpCall;
-(BOOL) holdCallWithConfig: (ActionConfig*)config;
-(BOOL) holdCall;
-(BOOL) resumeCallWithConfig: (ActionConfig*)config;
-(BOOL) resumeCall;
-(BOOL) sendDTMF: (int) digit;
#if TARGET_OS_IPHONE
-(BOOL) setRemoteVideoDisplay: (UIImageView*)display;
-(BOOL) setLocalVideoDisplay: (UIView*)display;
#endif /* TARGET_OS_IPHONE */

+(NgnAVSession*) takeIncomingSessionWithSipStack: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (twrap_media_type_t) mediaType andSipMessage: (const SipMessage*) sipMessage;
+(NgnAVSession*) createOutgoingSessionWithSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t) mediaType;
+(void) releaseSession: (NgnAVSession**) session;
+(NgnAVSession*) getSessionWithId: (long) sessionId;
+(NgnAVSession*) getSessionWithPredicate: (NSPredicate*) predicate;
+(BOOL) hasSessionWithId:(long) sessionId;
+(BOOL) hasActiveSession;
+(NgnAVSession*) getFirstActiveCallAndNot:(long) sessionId;
+(NgnAVSession*) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack;
+(NgnAVSession*) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack;

@end
