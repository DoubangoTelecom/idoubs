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

#import "services/INgnConfigurationService.h"
#import "services/impl/NgnBaseService.h"
#import "sip/NgnInviteSession.h"
#import "model/NgnHistoryAVCallEvent.h"
#import "media/NgnVideoView.h"

#import "media/NgnProxyVideoConsumer.h"
#if TARGET_OS_IPHONE
#	import "iOSProxyVideoProducer.h"
#   import "iOSGLView.h"
#elif TARGET_OS_MAC
#	import "OSXProxyVideoProducer.h"
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
	NgnHistoryAVCallEvent* mEvent;
	
	BOOL mMute;
	BOOL mSpeakerOn;
	
	BOOL mConsumersAndProducersInitialzed;
	NgnProxyVideoConsumer* mVideoConsumer;
	NgnProxyVideoProducer* mVideoProducer;
}

-(BOOL) makeCall: (NSString*) validUri;
-(BOOL) makeVideoSharingCall: (NSString*) validUri;
-(BOOL) updateSession: (NgnMediaType_t)mediaType;
-(BOOL) acceptCallWithConfig: (ActionConfig*)config;
-(BOOL) acceptCall;
-(BOOL) hangUpCallWithConfig: (ActionConfig*)config;
-(BOOL) hangUpCall;
-(BOOL) holdCallWithConfig: (ActionConfig*)config;
-(BOOL) holdCall;
-(BOOL) resumeCallWithConfig: (ActionConfig*)config;
-(BOOL) resumeCall;
-(BOOL) toggleHoldResumeWithConfig: (ActionConfig*)config;
-(BOOL) toggleHoldResume;
-(BOOL) sendDTMF: (int) digit;
-(BOOL) setFlipEncodedVideo: (BOOL) flip;
-(BOOL) setFlipDecodedVideo: (BOOL) flip;
#if TARGET_OS_IPHONE
-(BOOL) setRemoteVideoDisplay: (iOSGLView*)display;
-(BOOL) setLocalVideoDisplay: (UIView*)display;
-(BOOL) setOrientation: (AVCaptureVideoOrientation)orientation;
-(BOOL) toggleCamera;
-(BOOL) setMute: (BOOL)mute;
-(BOOL) isMuted;
-(BOOL) setSpeakerEnabled: (BOOL)speakerOn;
-(BOOL) isSpeakerEnabled;
-(BOOL) isSecure;
#elif TARGET_OS_MAC
-(BOOL) setRemoteVideoDisplay:(NSObject<NgnVideoView>*)display;
-(BOOL) setLocalVideoDisplay: (QTCaptureView*)display;
#endif

+(NgnAVSession*) takeIncomingSessionWithSipStack: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (twrap_media_type_t) mediaType andSipMessage: (const SipMessage*) sipMessage;
+(NgnAVSession*) createOutgoingSessionWithSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t) mediaType;
+(void) releaseSession: (NgnAVSession**) session;
+(NgnAVSession*) getSessionWithId: (long) sessionId;
+(NgnAVSession*) getSessionWithPredicate: (NSPredicate*) predicate;
+(BOOL) hasSessionWithId:(long) sessionId;
+(BOOL) hasActiveSession;
+(NgnAVSession*) getFirstActiveCallAndNot:(long) sessionId;
+(int) getNumberOfActiveCalls:(BOOL) countOnHold;
+(NgnAVSession*) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack;
+(NgnAVSession*) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack;

@end
