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
#import "NgnSipService.h"
#import "NgnConfigurationEntry.h"
#import "NgnEngine.h"
#import "NgnNotificationCenter.h"
#import "NgnStringUtils.h"
#import "NgnContentType.h"
#import "NgnUriUtils.h"

#import "NgnRegistrationEventArgs.h"
#import "NgnStackEventArgs.h"
#import "NgnInviteEventArgs.h"
#import "NgnMessagingEventArgs.h"
#import "NgnSubscriptionEventArgs.h"
#import "NgnPublicationEventArgs.h"

#import "NgnRegistrationSession.h"
#import "NgnAVSession.h"
#import "NgnMsrpSession.h"
#import "NgnMessagingSession.h"
#import "NgnSubscriptionSession.h"
#import "NgnPublicationSession.h"

#import "SipCallback.h"
#import "SipEvent.h"
#import "SipMessage.h"
#import "SMSEncoder.h"

#import "tsk_debug.h"

#undef TAG
#define kTAG @"NgnSipService///: "
#define TAG kTAG

//
// NgnSipService private declaration
//
@interface  NgnSipService(Private)
-(void)releaseSipRegSession;
@end


//
//	NgnSipCallback
//

class _NgnSipCallback : public SipCallback
{
public:
	_NgnSipCallback(NgnSipService* sipService) : SipCallback(){
		// I know that you will say why we don't get the sip service from the engine? See below for the response
		mSipService = [sipService retain];
		// in the next versions we will get the stack id in order to retrieve the associated engine then the configuration service
		mConfigurationService = [[NgnEngine sharedInstance].configurationService retain];
	}
	
	~_NgnSipCallback(){
		[mSipService release];
		[mConfigurationService release];
	}
	
	/* == OnDialogEvent == */
	int OnDialogEvent(const DialogEvent* _e){
		const char* _phrase = _e->getPhrase();
		const short _code = _e->getCode();
		short _sipCode;
		const SipSession* _session = _e->getBaseSession();
		const SipMessage* _sipMesssage = _e->getSipMessage();
		
		if(!_session){
			TSK_DEBUG_ERROR("Null Sip session");
			return -1;
		}
		
		_sipCode = (_sipMesssage && const_cast<SipMessage*>(_sipMesssage)->isResponse()) ? const_cast<SipMessage*>(_sipMesssage)->getResponseCode() : _code;
		
		// This is a POSIX thread but thanks to multithreading
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NgnEventArgs* eargs = nil;
		NSString* phrase = [NgnStringUtils toNSString:_phrase];
		const long _sessionId = _session->getId();
		NgnSipSession* ngnSipSession = nil;
		
		TSK_DEBUG_INFO("OnDialogEvent(%s, %ld)", _phrase, _sessionId);
		
		switch (_code) {
			//== Connecting ==
			case tsip_event_code_dialog_connecting:
			{
				// Registration
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] 
							 initWithSessionId:_sessionId 
							 andEventType:REGISTRATION_INPROGRESS 
							 andSipCode:_code  
							 andSipPhrase:phrase];
					[mSipService.sipRegSession setConnectionState:CONN_STATE_CONNECTING];					
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
				}
				// Audio/Video/MSRP(Chat, FileTransfer)
				else if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] 
							 initWithSessionId: _sessionId andEvenType: 
							 INVITE_EVENT_INPROGRESS andMediaType: ((NgnInviteSession*)ngnSipSession).mediaType 
							 andSipPhrase: phrase];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTING];
					[((NgnInviteSession*)ngnSipSession) setState: INVITE_STATE_INPROGRESS];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				// Messaging (PagerMode IM)
				else if ((ngnSipSession = [NgnMessagingSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnMessagingEventArgs alloc] 
							 initWithSessionId:_sessionId 
							 andEventType:MESSAGING_EVENT_CONNECTING
							 andPhrase:phrase 
							 andPayload:nil];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTING];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnMessagingEventArgs_Name object:eargs];
				}
				// Subscription
				else if ((ngnSipSession = [NgnSubscriptionSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnSubscriptionEventArgs alloc] initWithSessionId:_sessionId 
																   andEventType:SUBSCRIPTION_INPROGRESS 
																andSipCode:_code 
																   andSipPhrase:phrase 
																andEventPackage:((NgnSubscriptionSession*)ngnSipSession).eventPackage];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTING];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnSubscriptionEventArgs_Name object:eargs];
				}
				// Publication
				else if ((ngnSipSession = [NgnPublicationSession getSessionWithId:_sessionId]) != nil){
					eargs = [(NgnPublicationEventArgs*)[NgnPublicationEventArgs alloc] initWithSessionId:_sessionId 
																andEventType:PUBLICATION_INPROGRESS 
																andSipCode:_code 
																andSipPhrase:phrase];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTING];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnPublicationEventArgs_Name object:eargs];
				}
				break;
			}
			
			//== Connected == //
			case tsip_event_code_dialog_connected:
			{
				// Registration
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] initWithSessionId:_sessionId 
										andEventType:REGISTRATION_OK  
										andSipCode:_code  
										andSipPhrase:phrase];
					[mSipService.sipRegSession setConnectionState: CONN_STATE_CONNECTED];
					// Update default identity (vs barred)
					NSString* defaultIdentity = [mSipService.sipStack getPreferredIdentity];
					if(![NgnStringUtils isNullOrEmpty:defaultIdentity]){
						[mSipService setDefaultIdentity:defaultIdentity];
					}
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
				}
				// Audio/Video/MSRP(Chat, FileTransfer)
				else if (((ngnSipSession = [NgnAVSession getSessionWithId: _sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] 
							 initWithSessionId: _sessionId 
							 andEvenType:INVITE_EVENT_CONNECTED 
							 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType 
							 andSipPhrase:phrase];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTED];
					[((NgnInviteSession*)ngnSipSession) setState:INVITE_STATE_INCALL];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				// Messaging (PagerMode IM)
				else if ((ngnSipSession = [NgnMessagingSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnMessagingEventArgs alloc]
							 initWithSessionId:_sessionId
							 andEventType:MESSAGING_EVENT_CONNECTED
							 andPhrase:phrase
							 andPayload:nil];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTED];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnMessagingEventArgs_Name object:eargs];
				}
				// Subscription
				else if ((ngnSipSession = [NgnSubscriptionSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnSubscriptionEventArgs alloc] initWithSessionId:_sessionId 
																   andEventType:SUBSCRIPTION_OK
																	 andSipCode:_code 
																   andSipPhrase:phrase 
																andEventPackage:((NgnSubscriptionSession*)ngnSipSession).eventPackage];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTED];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnSubscriptionEventArgs_Name object:eargs];
				}
				// Publication
				else if ((ngnSipSession = [NgnPublicationSession getSessionWithId:_sessionId]) != nil){
					eargs = [(NgnPublicationEventArgs*)[NgnPublicationEventArgs alloc] initWithSessionId:_sessionId 
																  andEventType:PUBLICATION_OK
																	andSipCode:_code 
																  andSipPhrase:phrase];
					[ngnSipSession setConnectionState:CONN_STATE_CONNECTED];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnPublicationEventArgs_Name object:eargs];
				}
				break;
			}
				
			//== Terminating == //
			case tsip_event_code_dialog_terminating:
			{
				// Registration
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] 
							 initWithSessionId:_sessionId 
							 andEventType:UNREGISTRATION_INPROGRESS  
							 andSipCode:_code  
							 andSipPhrase:phrase];
					[mSipService.sipRegSession setConnectionState:CONN_STATE_TERMINATING];					
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
				}
				// Audio/Video/MSRP(Chat, FileTransfer)
				else if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] 
							 initWithSessionId:_sessionId
							 andEvenType:INVITE_EVENT_TERMWAIT
							 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType 
							 andSipPhrase:phrase];
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATING];
					[((NgnInviteSession*)ngnSipSession) setState:INVITE_STATE_TERMINATING];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				// Messaging (PagerMode IM)
				else if ((ngnSipSession = [NgnMessagingSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnMessagingEventArgs alloc] 
							 initWithSessionId:_sessionId 
							 andEventType:MESSAGING_EVENT_TERMINATING
							 andPhrase:phrase 
							 andPayload:nil];
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATING];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnMessagingEventArgs_Name object:eargs];
				}
				// Subscription
				else if ((ngnSipSession = [NgnSubscriptionSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnSubscriptionEventArgs alloc] initWithSessionId:_sessionId 
																   andEventType:UNSUBSCRIPTION_INPROGRESS 
																	 andSipCode:_code 
																   andSipPhrase:phrase 
																andEventPackage:((NgnSubscriptionSession*)ngnSipSession).eventPackage];
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATING];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnSubscriptionEventArgs_Name object:eargs];
				}
				// Publication
				else if ((ngnSipSession = [NgnPublicationSession getSessionWithId:_sessionId]) != nil){
					eargs = [(NgnPublicationEventArgs*)[NgnPublicationEventArgs alloc] initWithSessionId:_sessionId 
																  andEventType:UNPUBLICATION_INPROGRESS
																  andSipCode:_code 
																  andSipPhrase:phrase];
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATING];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnPublicationEventArgs_Name object:eargs];
				}
				break;
			}
				
			//== Terminated == //
			case tsip_event_code_dialog_terminated:
			{
				// Registration
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] 
							 initWithSessionId:_sessionId 
							 andEventType:mSipService.sipRegSession.connectionState == CONN_STATE_TERMINATING ? UNREGISTRATION_OK : REGISTRATION_NOK
							 andSipCode:_sipCode  
							 andSipPhrase:phrase];
					if(_sipCode == 503 && _sipMesssage){//Tiscali on ZTE IMS networks
						char* retry_after = const_cast<SipMessage*>(_sipMesssage)->getSipHeaderValue("retry-after", 0);
						if(retry_after){
							[eargs putExtraWithKey:kExtraRegistrationEventArgsRetryAfter andValue:[NgnStringUtils toNSString:retry_after]];
							TSK_FREE(retry_after);
						}
					}
					[mSipService.sipRegSession setConnectionState:CONN_STATE_TERMINATED];
					[mSipService releaseSipRegSession];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
					
					/* Stop the stack (as we are already in the stack-thread, then do it in a new thread) */
#if 0 /* FIXME: won't work if network type or reachability change */
					[mSipService stopStackAsynchronously];
#endif
				}
				// Audio/Video/MSRP(Chat, FileTransfer)
				else if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] 
							 initWithSessionId:_sessionId
							 andEvenType:INVITE_EVENT_TERMINATED
							 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
							 andSipPhrase:phrase];
					
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATED];
					[((NgnInviteSession*)ngnSipSession) setState:INVITE_STATE_TERMINATED];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
					if([ngnSipSession isKindOfClass:[NgnAVSession class]]){
						[NgnAVSession releaseSession:(NgnAVSession**)&ngnSipSession];
					}
					else if([ngnSipSession isKindOfClass:[NgnMsrpSession class]]){
						[NgnMsrpSession releaseSession:(NgnMsrpSession**)&ngnSipSession];
					}
				}
				// Messaging (PagerMode IM)
				else if ((ngnSipSession = [NgnMessagingSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnMessagingEventArgs alloc] 
							 initWithSessionId:_sessionId 
							 andEventType:MESSAGING_EVENT_TERMINATED
							 andPhrase:phrase 
							 andPayload:nil];
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATED];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnMessagingEventArgs_Name object:eargs];
					[NgnMessagingSession releaseSession:(NgnMessagingSession**)&ngnSipSession];
				}
				// Subscription
				else if ((ngnSipSession = [NgnSubscriptionSession getSessionWithId:_sessionId]) != nil){
					eargs = [[NgnSubscriptionEventArgs alloc] initWithSessionId:_sessionId 
																   andEventType:ngnSipSession.connectionState ==CONN_STATE_TERMINATING ? UNSUBSCRIPTION_OK : SUBSCRIPTION_NOK
																   andSipCode:_sipCode 
																   andSipPhrase:phrase 
																andEventPackage:((NgnSubscriptionSession*)ngnSipSession).eventPackage];
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATED];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnSubscriptionEventArgs_Name object:eargs];
					[NgnSubscriptionSession releaseSession: (NgnSubscriptionSession**)&ngnSipSession];
				}
				// Publication
				else if ((ngnSipSession = [NgnPublicationSession getSessionWithId:_sessionId]) != nil){
					eargs = [(NgnPublicationEventArgs*)[NgnPublicationEventArgs alloc] initWithSessionId:_sessionId 
																  andEventType:ngnSipSession.connectionState == CONN_STATE_TERMINATING ? UNPUBLICATION_OK : PUBLICATION_NOK
																  andSipCode:_sipCode 
																  andSipPhrase:phrase];
					[ngnSipSession setConnectionState:CONN_STATE_TERMINATED];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnPublicationEventArgs_Name object:eargs];
					[NgnPublicationSession releaseSession: (NgnPublicationSession**)&ngnSipSession];
				}
				break;
			}
			
			default:
				break;
		}
		
		
done:
		[eargs autorelease];
		[pool release];
		return 0; 
	}
	
	/* == OnStackEvent == */
	int OnStackEvent(const StackEvent* _e) {
		short _code = _e->getCode();
		const char* _phrase = _e->getPhrase();
		// This is a POSIX thread but thanks to multithreading
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NgnStackEventTypes_t eventType = STACK_EVENT_NONE;
		
		switch(_code){
			case tsip_event_code_stack_started:
				[mSipService.sipStack setState: STACK_STATE_STARTED];
				eventType = STACK_START_OK;
				NgnNSLog(TAG, @"Stack started");
				break;
			case tsip_event_code_stack_failed_to_start:
				TSK_DEBUG_ERROR("Failed to start the stack. \nAdditional info:\n%s", _phrase);
				eventType = STACK_START_NOK;
				break;
			case tsip_event_code_stack_failed_to_stop:
				TSK_DEBUG_ERROR("Failed to stop the stack");
				eventType = STACK_STOP_NOK;
				break;
			case tsip_event_code_stack_stopped:
				[mSipService.sipStack setState: STACK_STATE_STOPPED];
				eventType = STACK_STOP_OK;
				NgnNSLog(TAG, @"Stack stopped");
				break;
		}
		
		NgnStackEventArgs* eargs = [[NgnStackEventArgs alloc]initWithEventType: eventType andPhrase: [NgnStringUtils toNSString:_phrase]];
		[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnStackEventArgs_Name object:eargs];
done:
		[eargs autorelease];
		[pool release];
		return 0; 
	}
	
	/* == OnInviteEvent == */
	int OnInviteEvent(const InviteEvent* _e) { 
		tsip_invite_event_type_t _type = _e->getType();
		short _code = _e->getCode();
		const char* _phrase = _e->getPhrase();
		const InviteSession* _session = _e->getSession();
		
		// This is a POSIX thread but thanks to multithreading
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NgnInviteEventArgs* eargs = nil;
		NSString* phrase = [NgnStringUtils toNSString:_phrase];
		const long _sessionId = _session ? _session->getId() : -1;
		NgnSipSession* ngnSipSession = nil;
		
		switch (_type) {
			case tsip_i_newcall:
			{
				if(_session) /* As we are not the owner, then the session MUST be null */{
					TSK_DEBUG_ERROR("Invalid incoming session");
					const_cast<InviteSession*>(_session)->hangup(); // To avoid another callback event
					goto done;
				
				}
				const SipMessage* _message = _e->getSipMessage();
				if(!_message){
					TSK_DEBUG_ERROR("Invalid message");
					goto done;
				}
				
				twrap_media_type_t _sessionType = _e->getMediaType();
				// == BEGIN SWITCH
				switch(_sessionType){
					case twrap_media_msrp:
					{
						//if ((session = e.takeMsrpSessionOwnership()) == null){
						//	Log.e(TAG,"Failed to take MSRP session ownership");
						//	return -1;
						//}
						
						//NgnMsrpSession msrpSession = NgnMsrpSession.takeIncomingSession(mSipService.getSipStack(), 
						//																(MsrpSession)session, message);
						//if (msrpSession == null){
						//	Log.e(TAG,"Failed to create new session");
						//	session.hangup();
						//	session.delete();
						//	return 0;
						//}
						//mSipService.broadcastInviteEvent(new NgnInviteEventArgs(msrpSession.getId(), NgnInviteEventTypes.INCOMING, msrpSession.getMediaType(), phrase));
						goto done;
					}
						
					case twrap_media_audio:
					case twrap_media_audiovideo:
					case twrap_media_video:
					{
						if (!(_session = _e->takeCallSessionOwnership())){
							TSK_DEBUG_ERROR("Failed to take audio/video session ownership");
							goto done;
						}
						NgnAVSession* ngnAVSession = [NgnAVSession takeIncomingSessionWithSipStack: mSipService.sipStack 
																					andCallSession: (CallSession**)&_session 
																					  andMediaType: _sessionType 
																					 andSipMessage: _message];
						if(_session){
							delete _session;
						}
						if(ngnAVSession){
							eargs = [[NgnInviteEventArgs alloc] initWithSessionId: ngnAVSession.id 
															 andEvenType: INVITE_EVENT_INCOMING 
															 andMediaType: ngnAVSession.mediaType
															 andSipPhrase: phrase];
							[ngnAVSession setState:INVITE_STATE_INCOMING];
							[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
						}
						break;
					}
						
					default:
					{
						TSK_DEBUG_ERROR("Invalid media type");
						goto done;
					}
				}
				// == END SWITCH
				break;
			}
				
			
			case tsip_ao_request:
			{
				if ((_code == 180 || _code == 183) && _session != tsk_null){
					if (((ngnSipSession = [NgnAVSession getSessionWithId: _sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
						const SipMessage* _message = _e->getSipMessage();
						BOOL containsSdp = _message && const_cast<SipMessage*>(_message)->getSdpMessage();
						
						eargs = [[NgnInviteEventArgs alloc] initWithSessionId: ngnSipSession.id 
																  andEvenType: _code==180 ? INVITE_EVENT_RINGING : (containsSdp ? INVITE_EVENT_EARLY_MEDIA : INVITE_EVENT_INPROGRESS)
																 andMediaType: ((NgnInviteSession*)ngnSipSession).mediaType
																 andSipPhrase: phrase];
						[((NgnInviteSession*)ngnSipSession) setState:_code==180 ? INVITE_STATE_REMOTE_RINGING : (containsSdp ? INVITE_STATE_EARLY_MEDIA : INVITE_STATE_INPROGRESS)];
						[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
					}
				}
				break;
			}
				
			case tsip_i_request:
			{
				const SipMessage* _message = _e->getSipMessage();
				if(_message && (((ngnSipSession = [NgnAVSession getSessionWithId: _sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil))){
					if(const_cast<SipMessage*>(_message)->getRequestType() == tsip_INFO){
						const void* _content = const_cast<SipMessage*>(_message)->getSipContentPtr();
						char* _content_type = const_cast<SipMessage*>(_message)->getSipHeaderValue("c");
						if(_content && _content_type){
							NSString* contentType = [NgnStringUtils toNSString:_content_type];
							if([contentType isEqualToString:kContentDoubangoDeviceInfo]){
								NSString* content = [NgnStringUtils toNSString:(const char*)_content];
								NSArray* items = [content componentsSeparatedByString:@"\r\n"];
								for (NSString* item in items) {
									NSArray* info = [item componentsSeparatedByString:@":"];
									if([info count] == 2){
										// orientation
										if([[info objectAtIndex:0] isEqualToString:@"orientation"]){
											NSString* orientation = [info objectAtIndex:1];
											if([orientation isEqualToString:@"portrait"]){
												((NgnInviteSession*)ngnSipSession).remoteDeviceInfo.orientation = NgnDeviceInfo_Orientation_Portrait;
											}
											else if([orientation isEqualToString:@"landscape"]){
												((NgnInviteSession*)ngnSipSession).remoteDeviceInfo.orientation = NgnDeviceInfo_Orientation_Landscape;
											}
										}
										// lang
										else if([[info objectAtIndex:0] isEqualToString:@"lang"]){
											((NgnInviteSession*)ngnSipSession).remoteDeviceInfo.lang = [info objectAtIndex:1];
										}
									}
								}
								eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
																		  andEvenType:INVITE_EVENT_REMOTE_DEVICE_INFO_CHANGED
																		 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
																		 andSipPhrase:phrase];
								[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
							}
						}
						TSK_FREE(_content_type);
					}
				}
				break;
			}
				
			case tsip_o_ect_ok:
			case tsip_o_ect_nok:
			case tsip_i_ect:
			{
				break;
			}
			
				
			case tsip_m_early_media:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_EARLY_MEDIA
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
			
			case tsip_m_updating:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															 andEvenType:INVITE_EVENT_MEDIA_UPDATING
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
				
			case tsip_m_updated:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					twrap_media_type_t _new_media_type = _e->getMediaType();
					switch (_new_media_type) {
						case twrap_media_audiovideo:
							((NgnInviteSession*)ngnSipSession).mediaType = MediaType_AudioVideo;
							break;
						case twrap_media_video:
							((NgnInviteSession*)ngnSipSession).mediaType = MediaType_Video;
							break;
						case twrap_media_audio:
							((NgnInviteSession*)ngnSipSession).mediaType = MediaType_Audio;
							break;
					}
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_MEDIA_UPDATED
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
				
			case tsip_m_local_hold_ok:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					[((NgnInviteSession*)ngnSipSession) setLocalHold:YES];
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_LOCAL_HOLD_OK
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
			case tsip_m_local_hold_nok:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId: _sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_LOCAL_HOLD_NOK
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
			case tsip_m_local_resume_ok:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					[((NgnInviteSession*)ngnSipSession) setLocalHold:NO];
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_LOCAL_RESUME_OK
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
			case tsip_m_local_resume_nok:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_LOCAL_RESUME_NOK
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
			case tsip_m_remote_hold:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					[((NgnInviteSession*)ngnSipSession) setRemoteHold:YES];
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_REMOTE_HOLD
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
			case tsip_m_remote_resume:
			{
				if (((ngnSipSession = [NgnAVSession getSessionWithId:_sessionId]) != nil) || ((ngnSipSession = [NgnMsrpSession getSessionWithId: _sessionId]) != nil)){
					[((NgnInviteSession*)ngnSipSession) setRemoteHold:NO];
					eargs = [[NgnInviteEventArgs alloc] initWithSessionId:ngnSipSession.id 
															  andEvenType:INVITE_EVENT_REMOTE_RESUME
															 andMediaType:((NgnInviteSession*)ngnSipSession).mediaType
															 andSipPhrase:phrase];
					[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnInviteEventArgs_Name object:eargs];
				}
				break;
			}
				
			default:
				break;
		}
		
		
done:
		[pool release];
		return 0; 
	}
	
	/* == OnMessagingEvent == */
	int OnMessagingEvent(const MessagingEvent* _e) { 
		tsip_message_event_type_t _type = _e->getType();
		
		// This is a POSIX thread but thanks to multithreading
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NgnMessagingEventArgs* eargs = nil;
		
		switch (_type) {
			case tsip_ao_message:
			{
				const MessagingSession* _session = _e->getSession();
				const SipMessage* _message = _e->getSipMessage();
				const char* _phrase = _e->getPhrase();
				char* _from = _message ? const_cast<SipMessage*>(_message)->getSipHeaderValue("f") : tsk_null;
				short _code = _e->getCode();
				if(_session && _code>=200 && _message){// just ignore 1xx
					eargs = [[NgnMessagingEventArgs alloc] 
							 initWithSessionId: _session->getId() 
							 andEventType: (_code >=200 && _code<=299) ? MESSAGING_EVENT_SUCCESS : MESSAGING_EVENT_FAILURE
							 andPhrase: [NgnStringUtils toNSString: _phrase] 
							 andPayload: nil];
					[eargs putExtraWithKey:kExtraMessagingEventArgsFrom andValue:[NgnStringUtils toNSString: _from]];
					TSK_FREE(_from);
				}
				break;
			}
			
			case tsip_i_message:
			{
				if(_e->getSession()){
					TSK_DEBUG_ERROR("Incoming message cannot contain non-null session");
					goto done;
				}
				const SipMessage* _message = _e->getSipMessage();
				if(!_message){
					TSK_DEBUG_ERROR("Null Sip Message");
					goto done;
				}
				MessagingSession* _session = _e->takeSessionOwnership(); /* "Server-side-session" e.g. Initial MESSAGE sent by the remote party */
				NgnMessagingSession* ngnSession = nil;
				if (!_session){
					TSK_DEBUG_ERROR("Failed to take session ownership");
					goto done;
				}
				ngnSession = [NgnMessagingSession takeIncomingSessionWithSipStack: mSipService.sipStack
														andMessagingSession: &_session 
														andSipMessage: _message];
				if(!ngnSession){
					if(_session){
						_session->reject();
						TSK_DEBUG_ERROR("Failed to create NGN session base on messaging session");
						delete _session;
					}
					goto done;
				}
				
				const char* _phrase = _e->getPhrase();
				char* _from = const_cast<SipMessage*>(_message)->getSipHeaderValue("f");
				char* _ctype = const_cast<SipMessage*>(_message)->getSipHeaderValue("c");
				char* _ctransfer_encoding = const_cast<SipMessage*>(_message)->getSipHeaderValue("content-transfer-encoding");
				
				const void* _content = const_cast<SipMessage*>(_message)->getSipContentPtr();
				unsigned _content_length = const_cast<SipMessage*>(_message)->getSipContentLength();
				NSString *ctype = nil;
				NSString *contentTransferEncoding = nil;
				
				if(!_content || !_content_length){
					TSK_DEBUG_ERROR("Invalid MESSAGE");
					[ngnSession reject];
					goto tsip_i_message_done;
				}
				
				// accept
				if([mConfigurationService getBoolWithKey: RCS_AUTO_ACCEPT_PAGER_MODE_IM]){
					[ngnSession accept];
				}
				
				
				ctype = [NgnStringUtils toNSString: _ctype];
				contentTransferEncoding = [NgnStringUtils toNSString: _ctransfer_encoding];
				
				// parse data
				if([ctype caseInsensitiveCompare: kContentType3gppSMS] == NSOrderedSame){
					TSK_DEBUG_ERROR("3GPP SMS Not implemented yet");
					goto tsip_i_message_done;
				}
				else {
					eargs = [[NgnMessagingEventArgs alloc] 
							 initWithSessionId: ngnSession.id 
							 andEventType: MESSAGING_EVENT_INCOMING
							 andPhrase: [NgnStringUtils toNSString: _phrase] 
							 andPayload: [NSData dataWithBytes: _content length: _content_length]];
					NSString *fromUri = [NgnStringUtils toNSString:_from];
					[eargs putExtraWithKey:kExtraMessagingEventArgsFromUri andValue:fromUri];
					[eargs putExtraWithKey:kExtraMessagingEventArgsFromUserName andValue:[NgnUriUtils getUserName:fromUri]];
					[eargs putExtraWithKey:kExtraMessagingEventArgsFromDisplayname andValue:[NgnUriUtils getDisplayName:fromUri]];
					[eargs putExtraWithKey:kExtraMessagingEventArgsContentType andValue: ctype];
					[eargs putExtraWithKey:kExtraMessagingEventArgsContentTransferEncoding andValue: contentTransferEncoding];
				}

				
tsip_i_message_done:
				if(_session){
					delete _session, _session = tsk_null;
				}
				TSK_FREE(_from);
				TSK_FREE(_ctype);
				TSK_FREE(_ctransfer_encoding);
				
				break;
			}
				
			default:
				break;
		}
		
		if(eargs){
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnMessagingEventArgs_Name object:eargs];
		}
		
done:
		[eargs autorelease];
		[pool release];
		return 0;
	}
	
	/* == OnOptionsEvent == */
	int OnOptionsEvent(const OptionsEvent* _e) { 
		// This is a POSIX thread but thanks to multithreading
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		tsip_options_event_type_t _type = _e->getType();
		const OptionsSession *_sipSession = _e->getSession();
		
		switch (_type) {
			case tsip_i_options:
			{
				if(!_sipSession){// New session
					OptionsSession *_newSipSession;
					if((_newSipSession = _e->takeSessionOwnership())){
						_newSipSession->accept();
						delete _newSipSession, _newSipSession = tsk_null;
					}
				}
				break;
			}
				
			default:
			case tsip_ao_options:
			{
				break;
			}
		}
done:
		[pool release];
		return 0; 
	}
	
	/* == OnPublicationEvent == */
	int OnPublicationEvent(const PublicationEvent* _e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0; 
	}
	
	/* == OnRegistrationEvent == */
	int OnRegistrationEvent(const RegistrationEvent* _e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0; 
	}
	
	/* == OnSubscriptionEvent == */
	int OnSubscriptionEvent(const SubscriptionEvent* _e) { 
		// This is a POSIX thread but thanks to multithreading
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NgnSubscriptionEventArgs *eargs = nil;
		tsip_subscribe_event_type_t _type = _e->getType();
		const SubscriptionSession *_sipSession = _e->getSession();
		
		switch (_type) {
			case tsip_i_notify:
			{
				if(_sipSession){
					short _code = _e->getCode();
					const char *_phrase = _e->getPhrase();
					const SipMessage *_message = _e->getSipMessage();
					if(!_message || !_sipSession){
						TSK_DEBUG_ERROR("Invalid session");
						return 0;
					}
					NgnSubscriptionSession *ngnSession = [NgnSubscriptionSession getSessionWithId:_sipSession->getId()];
					if(!ngnSession){
						TSK_DEBUG_ERROR("cannot find session with id=%u", _sipSession->getId());
						return 0;
					}
					
					char* _ctype = const_cast<SipMessage*>(_message)->getSipHeaderValue("c");
					const void* _content = const_cast<SipMessage*>(_message)->getSipContentPtr();
					unsigned _content_length = const_cast<SipMessage*>(_message)->getSipContentLength();
					
					NSData *content = nil;
					if(_content && _content_length){
						content = [NSData dataWithBytes:_content length:_content_length];
					}
					NSString* ctype = [NgnStringUtils toNSString:_ctype];
					TSK_FREE(_ctype);
					
					eargs = [[NgnSubscriptionEventArgs alloc] initWithSessionId:ngnSession.id
															andEventType:INCOMING_NOTIFY 
															andSipCode:_code 
															andSipPhrase:[NgnStringUtils toNSString:_phrase] 
															andContent:content 
															andContentType:ctype 
															andEventPackage:ngnSession.eventPackage];
				}
				break;
			}
				
			default:
			case tsip_i_subscribe:
			case tsip_ao_subscribe:
			case tsip_i_unsubscribe:
			case tsip_ao_unsubscribe:
			case tsip_ao_notify:
			{
				break;
			}
		}
done:
		if(eargs){
			[NgnNotificationCenter postNotificationOnMainThreadWithName:kNgnSubscriptionEventArgs_Name object:eargs];
		}
		
		[eargs autorelease];
		[pool release];
		return 0; 
	}
	
private:
	NgnSipService* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
};

//
//	NgnSipService
//

@implementation  NgnSipService(Private)
-(void)releaseSipRegSession{
	[NgnRegistrationSession releaseSession:&self->sipRegSession];
}
@end


@implementation NgnSipService

@synthesize sipStack;
@synthesize sipRegSession;
@synthesize sipPreferences;

-(NgnSipService*)init{
	if((self = [super init])){
		_mSipCallback = new _NgnSipCallback(self);
		self->sipPreferences = [[NgnSipPreferences alloc]init];
		mConfigurationService = [[[NgnEngine sharedInstance] getConfigurationService] retain];
	}
	return self;
}

-(void)dealloc{
	[self stop];
	
	[sipPreferences release];
	[mConfigurationService release];
	[sipStack release];
	if(_mSipCallback){
		delete _mSipCallback;
	}
	if(sipRegSession){
		[NgnRegistrationSession releaseSession: &sipRegSession];
	}
	[super dealloc];
}

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	[self stopStackSynchronously];
	return YES;
}

-(NSString*)getDefaultIdentity{
	if(self->sipDefaultIdentity == nil){
		if(self->sipStack){
			self.defaultIdentity = self->sipStack.preferredIdentity;
		}
	}
	if(self->sipDefaultIdentity){
		return self->sipDefaultIdentity;
	}
	else {
		return [[NgnEngine sharedInstance].configurationService getStringWithKey:IDENTITY_IMPU];
	}
}

-(void)setDefaultIdentity: (NSString*)identity{
	[self->sipDefaultIdentity release];
	self->sipDefaultIdentity = [identity retain];
}

-(NgnSipStack*)getSipStack{
	return sipStack;
}

-(BOOL)isRegistered{
	if (sipRegSession) {
		return [sipRegSession isConnected];
	}
	return FALSE;
}

-(ConnectionState_t)getRegistrationState{
	if (sipRegSession) {
		return [sipRegSession getConnectionState];
	}
	return CONN_STATE_NONE;
}

-(int)getCodecs{
	return 0;
}

-(void)setCodecs: (int)codecs{
	
}

-(BOOL)stopStackSynchronously{
	if(sipStack && (sipStack.state == STACK_STATE_STARTING || sipStack.state == STACK_STATE_STARTED)){
		return [sipStack stop];
	}
	return YES;
}

-(BOOL)stopStackAsynchronously{
	[NSThread detachNewThreadSelector:@selector(stopStackSynchronously) toTarget:self withObject:nil];
	return YES;
}

-(BOOL)registerIdentity{
	NgnNSLog(TAG, @"register()");
	
#if defined(RECYCLE_STACK) && RECYCLE_STACK // FIXME: This is a workaround because sometimes the client fails to register when you switch from network-1 or network-2
	if(self->sipStack && (!self->sipRegSession || !self->sipRegSession.connected)){//registration terminated but stack still not destroyed => create new stack
		NgnNSLog(TAG,@"Recycling the stack");
		if(self->sipStack.state != STACK_STATE_STOPPED && self->sipStack.state != STACK_STATE_STOPPING){
			[self->sipStack stop];
		}
		[self->sipStack release]; self->sipStack = nil;
		[self releaseSipRegSession];
	}
#endif
	
	sipPreferences.realm = [mConfigurationService getStringWithKey:NETWORK_REALM];
	sipPreferences.impi = [mConfigurationService getStringWithKey:IDENTITY_IMPI];
	sipPreferences.impu = [mConfigurationService getStringWithKey:IDENTITY_IMPU];
	NgnNSLog(TAG, @"realm='%@', impu='%@', impi='%@'", sipPreferences.realm, sipPreferences.impu, sipPreferences.impi);
	
	if (sipStack == nil) {
		sipStack = [[NgnSipStack alloc] initWithSipCallback:_mSipCallback andRealmUri:sipPreferences.realm andIMPIUri:sipPreferences.impi andIMPUUri:sipPreferences.impu];
	} else {
		if (![sipStack setRealm:sipPreferences.realm]) {
			TSK_DEBUG_ERROR("Failed to set realm");
			return FALSE;
		}
		if (![sipStack setIMPI:sipPreferences.impi]) {
			TSK_DEBUG_ERROR("Failed to set IMPI");
			return FALSE;
		}
		if (![sipStack setIMPU:sipPreferences.impu]) {
			TSK_DEBUG_ERROR("Failed to set IMPU");
			return FALSE;
		}
	}
	
	
	// set the Password
	[sipStack setPassword: [mConfigurationService getStringWithKey:IDENTITY_PASSWORD]];
	// Set AMF
	[sipStack setAMF: [mConfigurationService getStringWithKey:SECURITY_IMSAKA_AMF]];
	// Set Operator Id
	[sipStack setOperatorId: [mConfigurationService getStringWithKey:SECURITY_IMSAKA_OPID]];
	
	// Check stack validity
	if (![sipStack isValid]) {
		TSK_DEBUG_ERROR("Trying to use invalid stack");
		return FALSE;
	}
	
	// Set STUN information
	if([mConfigurationService getBoolWithKey:NATT_USE_STUN]){                 
		NgnNSLog(TAG, @"STUN=yes");
		if([mConfigurationService getBoolWithKey:NATT_USE_STUN_DISCO]){
			NSString* domain = [sipPreferences.realm stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
			unsigned short stunPort = 0;
			NSString* stunServer = [sipStack dnsSrvWithService:[@"_stun._udp." stringByAppendingString:domain] andPort:&stunPort];
			if(stunServer){
				NgnNSLog(TAG, @"Failed to discover STUN server with service:_stun._udp.%@", domain);
			}
			[sipStack setSTUNServerIP:stunServer andPort:stunPort]; // Needed event if null (to disable/enable)
		}
		else{
			NSString* server = [mConfigurationService getStringWithKey:NATT_STUN_SERVER];
			int port = [mConfigurationService getIntWithKey:NATT_STUN_PORT];
			NgnNSLog(TAG, @"STUN2 - server=%@ and port=%d", server, port);
			[sipStack setSTUNServerIP:server andPort:port];
		}
	}
	else{
		NgnNSLog(TAG, @"STUN=no");
		[sipStack setSTUNServerIP:nil andPort:0];
	}
	
	// Set Proxy-CSCF
	sipPreferences.pcscfHost = [mConfigurationService getStringWithKey:NETWORK_PCSCF_HOST];
	sipPreferences.pcscfPort = [mConfigurationService getIntWithKey:NETWORK_PCSCF_PORT];
	sipPreferences.transport = [mConfigurationService getStringWithKey:NETWORK_TRANSPORT];
	sipPreferences.ipVersion = [mConfigurationService getStringWithKey:NETWORK_IP_VERSION];
	NgnNSLog(TAG, @"pcscf-host='%@', pcscf-port='%d', transport='%@', ipversion='%@'",
							 sipPreferences.pcscfHost, 
							 sipPreferences.pcscfPort,
							 sipPreferences.transport,
							 sipPreferences.ipVersion);
	
	if(![sipStack setProxyCSCFWithFQDN:sipPreferences.pcscfHost andPort:sipPreferences.pcscfPort andTransport:sipPreferences.transport 
						   andIPVersion:sipPreferences.ipVersion]){
		TSK_DEBUG_ERROR("Failed to set Proxy-CSCF parameters");
		return FALSE;
	}
	
	// Whether to use DNS NAPTR+SRV for the Proxy-CSCF discovery (even if the DNS requests are sent only when the stack starts,
	// should be done after setProxyCSCF())
	[sipStack setDnsDiscovery:[mConfigurationService getBoolWithKey:NETWORK_PCSCF_DISCOVERY_USE_DNS]];           
	
	// enable/disable 3GPP early IMS
	[sipStack setEarlyIMS:[mConfigurationService getBoolWithKey:NETWORK_USE_EARLY_IMS]];
	
	// SigComp (only update compartment Id if changed)
	if([mConfigurationService getBoolWithKey:NETWORK_USE_SIGCOMP]){
		NSString* compId = [NSString stringWithFormat:@"urn:uuid:%@", [[NSProcessInfo processInfo] globallyUniqueString]];
		[sipStack setSigCompId:compId];
	}
	else{
		[sipStack setSigCompId:nil];
	}
	
	// Start the Stack
	if (![sipStack start]) {
		TSK_DEBUG_ERROR("Failed to start the SIP stack");
		return FALSE;
	}
	
	// Preference values
	sipPreferences.xcap = [mConfigurationService getBoolWithKey:XCAP_ENABLED];
	sipPreferences.presence = [mConfigurationService getBoolWithKey:RCS_USE_PRESENCE];
	sipPreferences.mwi = [mConfigurationService getBoolWithKey:RCS_USE_MWI];
	
	// Create registration session
	if (sipRegSession == nil) {
		sipRegSession = [NgnRegistrationSession createOutgoingSessionWithStack:sipStack];
	}
	else{
		[sipRegSession setSigCompId: [sipStack getSigCompId]];
	}
	
	// Set/update From URI. For Registration ToUri should be equals to realm
	// (done by the stack)
	[sipRegSession setFromUri: sipPreferences.impu];
	// Send REGISTER
	if(![sipRegSession register_]){
		TSK_DEBUG_ERROR("Failed to send REGISTER request");
		return FALSE;
	}
	
	return TRUE;
}

-(BOOL)unRegisterIdentity{
	// Instead of just unregistering, hangup all dialogs (INVITE, SUBSCRIBE, PUBLISH, MESSAGE, ...)
	return [self stopStackAsynchronously];
}

@end




