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
 *
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

@interface NgnAVSession (Private)
+(NSMutableDictionary*) getAllSessions;
-(NgnAVSession*) internalInit: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (NgnMediaType_t) mediaType andState: (InviteState_t) callState;
#if TARGET_OS_IPHONE
-(BOOL)initializeConsumersAndProducers;
#endif
@end

@implementation NgnAVSession (Private)

+(NSMutableDictionary*) getAllSessions{
	static NSMutableDictionary* sessions = nil;
	if(sessions == nil){
		sessions = [[NSMutableDictionary alloc] init];
	}
	return sessions;
}

-(NgnAVSession*) internalInit: (NgnSipStack*) sipStack andCallSession: (CallSession**) session andMediaType: (NgnMediaType_t) mediaType andState: (InviteState_t) callState{
	if((self = (NgnAVSession*)[super initWithSipStack: sipStack])){
		mConfigurationService = [[[NgnEngine getInstance] getConfigurationService] retain];
		if(session && *session){
			_mSession = *session, *session = tsk_null;
		}
		else {
			_mSession = new CallSession([sipStack getStack]);
		}
		mMediaType = mediaType;
		// commons
		[super initialize];
		// History event
		mEvent = [[NgnHistoryEvent createAudioVideoEventWithRemoteParty: nil andVideo: isVideoType(mMediaType)] retain];
		// SigComp
		[super setSigCompId: [sipStack getSigCompId]];
		// 100rel
		_mSession->set100rel(true); // will add "Supported: 100rel"
        // Session timers
		if([mConfigurationService getBoolWithKey:QOS_USE_SESSION_TIMERS]){
			int timeout = [mConfigurationService getIntWithKey:QOS_SIP_CALLS_TIMEOUT];
			NSString* refresher = [mConfigurationService getStringWithKey:QOS_REFRESHER];
			_mSession->setSessionTimer((unsigned)timeout, [NgnStringUtils toCString: refresher]);
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
		
		//-- mHistoryEvent = new NgnHistoryAVCallEvent((mediaType == NgnMediaType.AudioVideo || mediaType == NgnMediaType.Video), null);
		[super setState:callState];
	}
	return self;
}

#if TARGET_OS_IPHONE
  
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
  
#endif
  
@end


@implementation NgnAVSession

-(void)dealloc{
	[mConfigurationService release];
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

-(BOOL) makeCall: (NSString*) remoteUri{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	
	BOOL ret;
	
	mOutgoing = TRUE;
	remoteUri = [NgnUriUtils makeValidSipUri: remoteUri];
	[super setToUri: remoteUri];
	
	if(mEvent){
		mEvent.remoteParty = remoteUri;
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
			ret = _mSession->callAudioVideo([NgnStringUtils toCString: remoteUri], _config);
			break;
		case MediaType_Audio:
		default:
			ret = _mSession->callAudio([NgnStringUtils toCString: remoteUri], _config);
			break;
	}
	if(_config){
		delete _config;
	}
	
	return ret;
}

-(BOOL) makeVideoSharingCall: (NSString*) remoteUri{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	
	mOutgoing = TRUE;
	remoteUri = [NgnUriUtils makeValidSipUri: remoteUri];
	[super setToUri: remoteUri];
	
	if(mEvent){
		mEvent.remoteParty = remoteUri;
	}
	
	return _mSession->callVideo([NgnStringUtils toCString: remoteUri]);
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

-(void) setState: (InviteState_t)newState{
	if(mState == newState){
		return;
	}
	
	[super setState: newState];
	
	switch(newState){
		case INVITE_STATE_INCOMING:
		{
#if TARGET_OS_IPHONE
			[self initializeConsumersAndProducers];
#endif
			break;
		}
			
		case INVITE_STATE_INPROGRESS:
		{
#if TARGET_OS_IPHONE
			[self initializeConsumersAndProducers];
#endif
			break;
		}
			
		case INVITE_STATE_INCALL:
		{
#if TARGET_OS_IPHONE
			[self initializeConsumersAndProducers];
#endif
			break;
		}
			
		case INVITE_STATE_TERMINATED:
		case INVITE_STATE_TERMINATING:
		{
			break;
		}
	}
}

-(BOOL) sendDTMF: (int) digit{
	if(!_mSession){
		TSK_DEBUG_ERROR("Null embedded session");
		return FALSE;
	}
	return _mSession->sendDTMF(digit);
}

#if TARGET_OS_IPHONE
-(BOOL) setRemoteVideoDisplay: (UIImageView*)display{
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
#endif /* TARGET_OS_IPHONE */

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
				char* fHeaderValue = const_cast<SipMessage*>(sipMessage)->getSipHeaderValue("f");
				[avSession setRemotePartyUri: [NgnStringUtils toNSString: fHeaderValue]];
				TSK_FREE(fHeaderValue);
			}
			[kSessions setObject: avSession forKey:[avSession getIdAsNumber]];
			return avSession;
		}
		return nil;
	}
}

+(NgnAVSession*) createOutgoingSessionWithSipStack: (NgnSipStack*) sipStack andMediaType: (NgnMediaType_t) media{
	@synchronized (kSessions){
		NgnAVSession* avSession = [[[NgnAVSession alloc] internalInit: sipStack andCallSession: tsk_null andMediaType: media andState: INVITE_STATE_INPROGRESS] autorelease];
		if(avSession){
			[kSessions setObject: avSession forKey:[avSession getIdAsNumber]];
		}
		return avSession;
	}
}

+(void) releaseSession: (NgnAVSession**) session{
	@synchronized (kSessions){
		if (session && *session){
			if([(*session) retainCount] == 1){
				[kSessions removeObjectForKey: [*session getIdAsNumber]];
			}
			else {
				[(*session) release];
			}
			*session = nil;
		}
	}
}

+(NgnAVSession*) getSessionWithId: (long) sessionId{
	@synchronized(kSessions){
		return [kSessions objectForKey:[NSNumber numberWithLong:sessionId]];
	}
}

+(NgnAVSession*) getSessionWithPredicate: (NSPredicate*) predicate{
	@synchronized(kSessions){
		NSArray* values = [kSessions allValues];
		for(NgnAVSession* value in values){
			if([predicate evaluateWithObject: value]){
				return value;
			}
		}
	}
	return nil;
}

+(BOOL) hasSessionWithId:(long) sessionId{
	return [NgnAVSession getSessionWithId: sessionId] != nil;
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

+(NgnAVSession*) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack{
	NgnAVSession* avSession = [NgnAVSession createOutgoingSessionWithSipStack: sipStack andMediaType: MediaType_Audio];
	if(avSession){
		if(![avSession makeCall: [NgnUriUtils makeValidSipUri: remoteUri]]){
			[NgnAVSession releaseSession: &avSession];
		}
	}
	return avSession;
}

+(NgnAVSession*) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack{
	NgnAVSession* avSession = [NgnAVSession createOutgoingSessionWithSipStack: sipStack andMediaType: MediaType_AudioVideo];
	if(avSession){
		if(![avSession makeCall: [NgnUriUtils makeValidSipUri: remoteUri]]){
			[NgnAVSession releaseSession: &avSession];
		}
	}
	return avSession;
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
