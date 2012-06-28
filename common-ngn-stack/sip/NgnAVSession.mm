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
#import "NgnAVSession.h"
#import "NgnConfigurationEntry.h"
#import "NgnEngine.h"
#import "NgnStringUtils.h"
#import "NgnUriUtils.h"
#import "NgnProxyPluginMgr.h"

#import "SipSession.h"
#import "SipMessage.h"
#import "MediaSessionMgr.h"
#import "ProxyConsumer.h"
#import "ProxyProducer.h"

#undef kSessions
#define kSessions [NgnAVSession getAllSessions]

//
// private implementation
//

@interface NgnAVSession (Private)
+(NSMutableDictionary*) getAllSessions;
+(NgnAVSession*) makeCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t)mType;
-(NgnAVSession*) internalInit: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (NgnMediaType_t) mediaType andState: (InviteState_t) callState;
-(BOOL)initializeConsumersAndProducers;
-(BOOL) setFlipVideo: (BOOL) flip forConsumer: (BOOL)consumer_;
@end

@implementation NgnAVSession (Private)

+(NSMutableDictionary*) getAllSessions{
	static NSMutableDictionary* sessions = nil;
	if(sessions == nil){
		sessions = [[NSMutableDictionary alloc] init];
	}
	return sessions;
}

+(NgnAVSession*) makeCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t)mType{
	NSString* validUri = [NgnUriUtils makeValidSipUri: remoteUri];
	if(validUri){
		NgnAVSession* avSession = [NgnAVSession createOutgoingSessionWithSipStack: sipStack andMediaType: mType];
		if(avSession){
			if(![avSession makeCall: [NgnUriUtils makeValidSipUri:validUri]]){
				[NgnAVSession releaseSession:&avSession];
			}
		}
		return avSession;
	}
	return nil;
}

-(NgnAVSession*) internalInit: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (NgnMediaType_t) mediaType_ andState: (InviteState_t) callState{
	if((self = (NgnAVSession*)[super initWithSipStack: sipStack])){
		mMediaType = mediaType_;
		mSpeakerOn = isVideoType(mMediaType);
		mMute = NO;
		if(session && *session){
			_mSession = *session, *session = tsk_null;
		}
		else {
			_mSession = new CallSession(sipStack._stack);
		}
		// commons
		[super initialize];
		// History event
		mEvent = [[NgnHistoryEvent createAudioVideoEventWithRemoteParty:nil andVideo:isVideoType(mMediaType)] retain];
		// SigComp
		[super setSigCompId: [sipStack getSigCompId]];
        // Session timers
		if([[NgnEngine sharedInstance].configurationService getBoolWithKey:QOS_USE_SESSION_TIMERS]){
			int timeout = [[NgnEngine sharedInstance].configurationService getIntWithKey:QOS_SIP_CALLS_TIMEOUT];
			NSString* refresher = [[NgnEngine sharedInstance].configurationService getStringWithKey:QOS_REFRESHER];
			_mSession->setSessionTimer((unsigned)timeout, [NgnStringUtils toCString:refresher]);
		}
        // Precondition (FIXME)
		// mSession.setQoS(tmedia_qos_stype_t.valueOf(mConfigurationService
		//										   .getString(NgnConfigurationEntry.QOS_PRECOND_TYPE,
		//													  NgnConfigurationEntry.DEFAULT_QOS_PRECOND_TYPE)),
		//				tmedia_qos_strength_t.valueOf(mConfigurationService.getString(NgnConfigurationEntry.QOS_PRECOND_STRENGTH,
		//																			  NgnConfigurationEntry.DEFAULT_QOS_PRECOND_STRENGTH)));
		
		/* 3GPP TS 24.173
		 *
		 * 5.1 IMS communication service identifier
		 * URN used to define the ICSI for the IMS Multimedia Telephony Communication Service: urn:urn-7:3gpp-service.ims.icsi.mmtel. 
		 * The URN is registered at http://www.3gpp.com/Uniform-Resource-Name-URN-list.html.
		 * Summary of the URN: This URN indicates that the device supports the IMS Multimedia Telephony Communication Service.
		 *
		 * Contact: <sip:impu@doubango.org;gr=urn:uuid:xxx;comp=sigcomp>;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel"
		 * Accept-Contact: *;+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel"
		 * P-Preferred-Service: urn:urn-7:3gpp-service.ims.icsi.mmtel
		 */
		[super addCapsWithName: @"+g.3gpp.icsi-ref" andValue: @"\"urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel\""];
		[super addHeaderWithName: @"Accept-Contact" andValue: @"*;+g.3gpp.icsi-ref=\"urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel\""];
		[super addHeaderWithName:@"P-Preferred-Service" andValue: @"urn:urn-7:3gpp-service.ims.icsi.mmtel"];
		
		[super setState:callState];
	}
	return self;
}

-(BOOL) setFlipVideo: (BOOL) flip forConsumer: (BOOL)consumer_{
	const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
	if(_mediaMgr){
		if(consumer_){
			const_cast<MediaSessionMgr*>(_mediaMgr)->consumerSetInt32(twrap_media_video, "flip", flip ? 1 : 0);
		}
		else{
			const_cast<MediaSessionMgr*>(_mediaMgr)->producerSetInt32(twrap_media_video, "flip", flip ? 1 : 0);
		}
		return YES;
	}
	else {
		TSK_DEBUG_ERROR("Failed to find session manager");
		return NO;
	}
}
  
-(BOOL)initializeConsumersAndProducers{
	if(mConsumersAndProducersInitialzed || !isVideoType(self.mediaType)){
		return YES;
	}
	const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
	if(_mediaMgr){
		const ProxyPlugin* _videoConsumer = _mediaMgr->findProxyPluginConsumer(twrap_media_video);
		if(_videoConsumer){
			[mVideoConsumer release];
			mVideoConsumer = [[NgnProxyPluginMgr getProxyPluginWithId: _videoConsumer->getId()] retain];
			_videoConsumer = tsk_null;
		}
		else {
			TSK_DEBUG_ERROR("Failed to find video consumer");
		}

		const ProxyPlugin* _videoProducer = _mediaMgr->findProxyPluginProducer(twrap_media_video);
		if(_videoProducer){
			[mVideoProducer release];
			mVideoProducer = [[NgnProxyPluginMgr getProxyPluginWithId: _videoProducer->getId()] retain];
			_videoProducer = tsk_null;
		}
		else {
			TSK_DEBUG_ERROR("Failed to find video producer");
		}
		mConsumersAndProducersInitialzed = YES;
		return YES;
	}
	TSK_DEBUG_ERROR("Cannot find media session manager");
	return NO;
}
  
@end



//
//	default implementation
//

@implementation NgnAVSession

-(void)dealloc{
	if(_mSession){
		delete _mSession;
	}
	
#if TARGET_OS_IPHONE
	[mVideoConsumer release];
	[mVideoProducer release];
#endif
	[mEvent release];
	
	[super dealloc];
}

-(BOOL) makeCall: (NSString*) validUri{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	
	BOOL ret;
	
	mOutgoing = TRUE;
	[super setToUri: validUri];
	
	if(mEvent){
		[mEvent setRemotePartyWithValidUri:validUri];
	}
	
	// FIXME: Set bandwidth
	ActionConfig* _config = new ActionConfig();
	// String level = mConfigurationService.getString(NgnConfigurationEntry.QOS_PRECOND_BANDWIDTH,
	//											   NgnConfigurationEntry.DEFAULT_QOS_PRECOND_BANDWIDTH);
	// tmedia_bandwidth_level_t bl = getBandwidthLevel(level);
	// config.setMediaInt(twrap_media_type_t.twrap_media_audiovideo, "bandwidth-level", bl.swigValue());
	
	switch (super.mediaType){
		case MediaType_AudioVideo:
		case MediaType_Video:
			ret = _mSession->callAudioVideo([NgnStringUtils toCString:validUri], _config);
			break;
		case MediaType_Audio:
		default:
			ret = _mSession->callAudio([NgnStringUtils toCString:validUri], _config);
			break;
	}
	if(_config){
		delete _config, _config = tsk_null;
	}
	
	return ret;
}

-(BOOL) makeVideoSharingCall: (NSString*) validUri{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	
	mOutgoing = TRUE;
	[super setToUri:validUri];
	
	if(mEvent){
		[mEvent setRemotePartyWithValidUri:validUri];
	}
	
	return _mSession->callVideo([NgnStringUtils toCString:validUri]);
}

-(BOOL) updateSession: (NgnMediaType_t)mediaType_{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	
	if(isVideoType(mediaType_)){
		return _mSession->callAudioVideo([NgnStringUtils toCString:self.toUri]);
	}
	else {
		return _mSession->callAudio([NgnStringUtils toCString:self.toUri]);
	}
}

-(BOOL) acceptCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	return _mSession->accept(config);
}

-(BOOL) acceptCall{
	return [self acceptCallWithConfig: nil];
}

-(BOOL) hangUpCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	if([self isConnected]){
		return _mSession->hangup(config);
	}
	else {
		return _mSession->reject(config);
	}
}

-(BOOL) hangUpCall{
	return [self hangUpCallWithConfig: nil];
}

-(BOOL) holdCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	return _mSession->hold(config);
}

-(BOOL) holdCall{
	return [self holdCallWithConfig: nil];
}

-(BOOL) resumeCallWithConfig: (ActionConfig*)config{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	return _mSession->resume(config);
}

-(BOOL) resumeCall{
	return [self resumeCallWithConfig: nil];
}

-(BOOL) toggleHoldResumeWithConfig: (ActionConfig*)config{
	if([self isLocalHeld]){
		return [self resumeCallWithConfig:config];
	}
	return [self holdCallWithConfig:config];
}

-(BOOL) toggleHoldResume{
	return [self toggleHoldResumeWithConfig:nil];
}

-(void) setState: (InviteState_t)newState{
	if(mState == newState){
		return;
	}
	
	[super setState: newState];
	
	switch(newState){
		case INVITE_STATE_INCOMING:
		{
			[self initializeConsumersAndProducers];
			break;
		}
			
		case INVITE_STATE_INPROGRESS:
		{
			[self initializeConsumersAndProducers];
			break;
		}
			
		case INVITE_STATE_INCALL:
		{
			[self initializeConsumersAndProducers];
			break;
		}
			
		case INVITE_STATE_TERMINATED:
		case INVITE_STATE_TERMINATING:
		{
			break;
		}
	}
}

// override from InviteSession
-(void) setMediaType:(NgnMediaType_t)mediaType_{
	if(mediaType_ != mMediaType){
		mConsumersAndProducersInitialzed = NO;//force refresh
	}
	[super setMediaType:mediaType_];
	[self initializeConsumersAndProducers];
}

-(BOOL) sendDTMF: (int) digit{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	return _mSession->sendDTMF(digit);
}

-(BOOL) setFlipEncodedVideo: (BOOL) flip{
	return [self setFlipVideo:flip forConsumer:NO];
}

-(BOOL) setFlipDecodedVideo: (BOOL) flip{
	return [self setFlipVideo:flip forConsumer:YES];
}

#if TARGET_OS_IPHONE
-(BOOL) setRemoteVideoDisplay: (iOSGLView*)display{
	if(mVideoConsumer){
		[mVideoConsumer setDisplay: display];
		return YES;
	}
	return NO;
}

-(BOOL) setLocalVideoDisplay: (UIView*)display{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	if(mVideoProducer){
		[mVideoProducer setPreview: display];
		return YES;
	}
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */
	return NO;
}

-(BOOL) setOrientation: (AVCaptureVideoOrientation)orientation{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	// alert the codecs
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait: [self setFlipEncodedVideo:NO]; break;
		case AVCaptureVideoOrientationPortraitUpsideDown: [self setFlipEncodedVideo:NO]; break;
		case AVCaptureVideoOrientationLandscapeLeft: [self setFlipEncodedVideo:NO]; break;
		case AVCaptureVideoOrientationLandscapeRight: [self setFlipEncodedVideo:YES]; break;
	}
	// alert the producer
	if(mVideoProducer){
		[mVideoProducer setOrientation: orientation];
		return YES;
	}
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */
	return NO;
}

-(BOOL) toggleCamera{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	if(mVideoProducer){
		[mVideoProducer toggleCamera];
		return YES;
	}
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */
	return NO;
}

#elif TARGET_OS_MAC

-(BOOL) setRemoteVideoDisplay:(NSObject<NgnVideoView>*)display{
	if(mVideoConsumer){
		[mVideoConsumer setDisplay: display];
		return YES;
	}
	return NO;
}

-(BOOL) setLocalVideoDisplay:(QTCaptureView*)display{
	if(mVideoProducer){
		[mVideoProducer setPreview:display];
		return YES;
	}
	return NO;
}

#endif

-(BOOL) setMute: (BOOL)mute{
	const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
	if(_mediaMgr){
		if(const_cast<MediaSessionMgr*>(_mediaMgr)->producerSetInt32(twrap_media_audio, "mute", mute ? 1 : 0)){
			mMute = mute;
			return YES;
		}
	}
	TSK_DEBUG_ERROR("Failed to mute/unmute the session");
	return NO;
}

-(BOOL) isMuted{
	return mMute;
}

-(BOOL) setSpeakerEnabled: (BOOL)speakerOn{
	mSpeakerOn = speakerOn;
	return YES;
}

-(BOOL) isSpeakerEnabled{
	return mSpeakerOn;
}

-(BOOL) isSecure{
	const MediaSessionMgr* _mediaMgr = [super getMediaSessionMgr];
	if(_mediaMgr){
		return (const_cast<MediaSessionMgr*>(_mediaMgr)->sessionGetInt32(twrap_media_audiovideo, "srtp-enabled") != 0);
	}
	return NO;
}

+(NgnAVSession*) takeIncomingSessionWithSipStack: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (twrap_media_type_t) mediaType andSipMessage: (const SipMessage*) sipMessage{
	NgnMediaType_t media;
	
	@synchronized (kSessions){
		switch (mediaType){
			case twrap_media_audio:
				media = MediaType_Audio;
				break;
			case twrap_media_video:
				media = MediaType_Video;
				break;
			case twrap_media_audiovideo:
				media = MediaType_AudioVideo;
				break;
			default:
				return nil;
		}
		NgnAVSession* avSession = [[[NgnAVSession alloc] internalInit: sipStack 
													   andCallSession: session 
													   andMediaType: media 
													   andState: INVITE_STATE_INCOMING] autorelease];
		if(avSession){
			if (sipMessage){
				char* _fHeaderValue = const_cast<SipMessage*>(sipMessage)->getSipHeaderValue("f");
				[avSession setRemotePartyUri: [NgnStringUtils toNSString: _fHeaderValue]];
				TSK_FREE(_fHeaderValue);
			}
			[kSessions setObject: avSession forKey:[avSession getIdAsNumber]];
			return avSession;
		}
	}
	return nil;
}

+(NgnAVSession*) createOutgoingSessionWithSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t) media{
	NgnAVSession* avSession;
	@synchronized (kSessions){
		avSession = [[[NgnAVSession alloc] internalInit:sipStack andCallSession:tsk_null andMediaType:media andState:INVITE_STATE_INPROGRESS] autorelease];
		if(avSession){
			[kSessions setObject:avSession forKey:[avSession getIdAsNumber]];
		}
	}
	return avSession;
}

+(void) releaseSession: (NgnAVSession**) session{
	@synchronized (kSessions){
		if (session && *session){
			if([(*session) retainCount] == 1){
				[kSessions removeObjectForKey:[*session getIdAsNumber]];
			}
			else {
				[(*session) release];
			}
			*session = nil;
		}
	}
}

+(NgnAVSession*) getSessionWithId: (long) sessionId{
	NgnAVSession* avSession;
	@synchronized(kSessions){
		avSession = [kSessions objectForKey:[NSNumber numberWithLong:sessionId]];
	}
	return avSession;
}

+(NgnAVSession*) getSessionWithPredicate: (NSPredicate*) predicate{
	@synchronized(kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if([predicate evaluateWithObject:value]){
				return value;
			}
		}
	}
	return nil;
}

+(BOOL) hasSessionWithId:(long) sessionId{
	return [NgnAVSession getSessionWithId:sessionId] != nil;
}

+(BOOL) hasActiveSession{
	@synchronized (kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if([value isActive]){
				return TRUE;
			}
		}
	}
	return FALSE;
}

+(NgnAVSession*) getFirstActiveCallAndNot:(long) sessionId{
	@synchronized (kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if(value.id != sessionId && [value isActive] && ![value isLocalHeld] && ![value isRemoteHeld]){
				return value;
			}
		}
	}
	return nil;
}

+(int) getNumberOfActiveCalls:(BOOL) countOnHold{
	int number = 0;
	@synchronized (kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if([value isActive] && (countOnHold || (![value isLocalHeld] && ![value isRemoteHeld]))){
				++number;
			}
		}
	}
	return number;
}

+(NgnAVSession*) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack{
	return [NgnAVSession makeCallWithRemoteParty:remoteUri andSipStack: sipStack andMediaType:MediaType_Audio];
}

+(NgnAVSession*) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack{
	return [NgnAVSession makeCallWithRemoteParty:remoteUri andSipStack: sipStack andMediaType:MediaType_AudioVideo];
}

// @Override
-(SipSession*)getSession{
	return _mSession;
}

// @Override
-(NgnHistoryEvent*) getHistoryEvent{
	return mEvent;
}

@end
