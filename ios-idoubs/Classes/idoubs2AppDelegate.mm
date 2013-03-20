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
#import "idoubs2AppDelegate.h"

#import "AudioCallViewController.h"
#import "VideoCallViewController.h"

#import "MediaContent.h"
#import "MediaSessionMgr.h"
#import "tsk_base64.h"

#undef TAG
#define kTAG @"idoubs2AppDelegate///: "
#define TAG kTAG
#define kTabBarIndex_Favorites	0
#define kTabBarIndex_Recents	1
#define kTabBarIndex_Contacts	2
#define kTabBarIndex_Numpad		3
#define kTabBarIndex_Messages	4

#define kNotifKey									@"key"
#define kNotifKey_IncomingCall						@"icall"
#define kNotifKey_IncomingMsg						@"imsg"
#define kNotifIncomingCall_SessionId				@"sid"

#define kNetworkAlertMsgThreedGNotEnabled			@"Only 3G network is available. Please enable 3G and try again."
#define kNetworkAlertMsgNotReachable				@"No network connection"

#define kNewMessageAlertText						@"You have a new message"

#define kAlertMsgButtonOkText						@"OK"
#define kAlertMsgButtonCancelText					@"Cancel"

//
// private functions
//
@interface idoubs2AppDelegate(Private)
-(void) networkAlert:(NSString*)message;
-(void) newMessageAlert:(NSString*)message;
-(BOOL) queryConfigurationAndRegister;
@end

@implementation idoubs2AppDelegate(Private)

-(void) networkAlert:(NSString*)message{
	if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iDoubs"
														message:message
													   delegate:nil
											  cancelButtonTitle:kAlertMsgButtonOkText
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

-(void) newMessageAlert:(NSString*)message{
	if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iDoubs"
														message:message
													   delegate:self
											  cancelButtonTitle:kAlertMsgButtonCancelText
											  otherButtonTitles:kAlertMsgButtonOkText, nil];
		[alert show];
		[alert release];
	}
}

-(BOOL) queryConfigurationAndRegister{
	BOOL on3G = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
	BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
	if(on3G && !use3G){
		[self networkAlert:kNetworkAlertMsgThreedGNotEnabled];
		return NO;
	}
    else if(![[NgnEngine sharedInstance].networkService isReachable]){
        [self networkAlert:kNetworkAlertMsgNotReachable];
		return NO;
    }
	else {
		return [[NgnEngine sharedInstance].sipService registerIdentity];
	}
}

@end


//
//	sip callback events implementation
//
@interface idoubs2AppDelegate(Sip_And_Network_Callbacks)
-(void) onNetworkEvent:(NSNotification*)notification;
-(void) onNativeContactEvent:(NSNotification*)notification;
-(void) onStackEvent:(NSNotification*)notification;
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onMessagingEvent:(NSNotification*)notification;
-(void) onInviteEvent:(NSNotification*)notification;
@end

@implementation idoubs2AppDelegate(Sip_And_Network_Callbacks)

//== Network events == //
-(void) onNetworkEvent:(NSNotification*)notification {
	NgnNetworkEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case NETWORK_EVENT_STATE_CHANGED:
		default:
		{
			NgnNSLog(TAG,@"NetworkEvent reachable=%@ networkType=%i", 
					 [NgnEngine sharedInstance].networkService.reachable ? @"YES" : @"NO", [NgnEngine sharedInstance].networkService.networkType);
			
			if([NgnEngine sharedInstance].networkService.reachable){
				BOOL onMobileNework = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
				
				if(onMobileNework){ // 3G, 4G, EDGE ...
					MediaSessionMgr::defaultsSetBandwidthLevel(tmedia_bl_medium); // QCIF, SQCIF
				}
				else {// WiFi
					MediaSessionMgr::defaultsSetBandwidthLevel(tmedia_bl_unrestricted);// SQCIF, QCIF, CIF ...
				}
				
				// unregister the application and schedule another registration
				BOOL on3G = onMobileNework; // Downgraded to 3G even if it could be 4G or EDGE
				BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
				if(on3G && !use3G){
					[self networkAlert:kNetworkAlertMsgThreedGNotEnabled];
					[[NgnEngine sharedInstance].sipService stopStackSynchronously];
				}
				else { // "on3G and use3G" or on WiFi
					// stop stack => clean up all dialogs
					[[NgnEngine sharedInstance].sipService stopStackSynchronously];
					[[NgnEngine sharedInstance].sipService registerIdentity];
				}
			}
            else{
                if([NgnEngine sharedInstance].sipService.registered){
                    [[NgnEngine sharedInstance].sipService stopStackSynchronously];
                }
            }
			
			break;
		}
	}
}

//== Native Contact events == //
-(void) onNativeContactEvent:(NSNotification*)notification {
	NgnContactEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case CONTACT_RESET_ALL:
		default:
		{
			if([UIApplication sharedApplication].applicationState != UIApplicationStateActive){
				self->nativeABChangedWhileInBackground = YES;
			}
			// otherwise addAll will be called when the client registers
			break;
		}
	}
}

-(void) onStackEvent:(NSNotification*)notification {
	NgnStackEventArgs * eargs = [notification object];
	switch (eargs.eventType) {
		case STACK_STATE_STARTING:
		{
			// this is the only place where we can be sure that the audio system is up
			[[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
			
			break;
		}
		default:
			break;
	}
}

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {	
	// gets the new registration state
	ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			if(scheduleRegistration){
				scheduleRegistration = FALSE;
				[[NgnEngine sharedInstance].sipService registerIdentity];
			}
			break;
			
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
		case CONN_STATE_CONNECTED:
		default:
			break;
	}
}

//== PagerMode IM (MESSAGE) events == //
-(void) onMessagingEvent:(NSNotification*)notification {
	NgnMessagingEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case MESSAGING_EVENT_CONNECTING:
		case MESSAGING_EVENT_CONNECTED:
		case MESSAGING_EVENT_TERMINATING:
		case MESSAGING_EVENT_TERMINATED:
		case MESSAGING_EVENT_FAILURE:
		case MESSAGING_EVENT_SUCCESS:
		case MESSAGING_EVENT_OUTGOING:
		default:
		{
			break;
		}
			
		case MESSAGING_EVENT_INCOMING:
		{
			if(eargs.payload){
				// The payload is a NSData object which means that it could contain binary data
				// here I consider that it's utf8 text message
				NSString* contentType = [eargs getExtraWithKey: kExtraMessagingEventArgsContentType];
				//NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUri];
				NSString* userName = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUserName];
				//content-transfer-encoding: base64\r\n
				//NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				
				//NSLog(@"Incoming message from:%@\n with ctype:%@\n and content:%@", from, contentType, content);
				
				// default content: e.g. plain/text
				NSData *content = eargs.payload;
				
				// message/cpim content
				if(contentType && [[contentType lowercaseString] hasPrefix:@"message/cpim"]){
					MediaContent *_content = MediaContent::parse([eargs.payload bytes], [eargs.payload length], [NgnStringUtils toCString:@"message/cpim"]);
					if(_content){
						unsigned _clen = dynamic_cast<MediaContentCPIM*>(_content)->getPayloadLength();
						const void* _cptr = dynamic_cast<MediaContentCPIM*>(_content)->getPayloadPtr();
						if(_clen && _cptr){
							const char* _contentTransferEncoding = dynamic_cast<MediaContentCPIM*>(_content)->getHeaderValue("content-transfer-encoding");
							
							if(tsk_striequals(_contentTransferEncoding, "base64")){
								char *_ascii = tsk_null;
								int ret = tsk_base64_decode((const uint8_t*)_cptr, _clen, &_ascii);
								if((ret > 0) && _ascii){
									content = [NSData dataWithBytes:_ascii length:ret];
								}
								else {
									TSK_DEBUG_ERROR("tsk_base64_decode() failed with error code equal to %d", ret);
								}
								
								TSK_FREE(_ascii);
							}
							else {
								content = [NSData dataWithBytes:_cptr length:_clen];
							}
						}
						delete _content;
					}
				}
				
				NgnHistorySMSEvent *smsEvent = [NgnHistoryEvent createSMSEventWithStatus:HistoryEventStatus_Incoming 
																		  andRemoteParty:userName
																			  andContent:content];
				[[NgnEngine sharedInstance].historyService addEvent:smsEvent];
				
				if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
					UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
					localNotif.alertBody = [NSString stringWithFormat:@"%@: %@", userName, content];
					localNotif.soundName = UILocalNotificationDefaultSoundName; 
					localNotif.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
					localNotif.repeatInterval = 0;
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
											  kNotifKey_IncomingMsg, kNotifKey,
											  nil];
					localNotif.userInfo = userInfo;
					[[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
				}
				else {
					
				}
			}
			break;
		}
	}
}


//== INVITE (audio/video, file transfer, chat, ...) events == //
-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
		{
			NgnAVSession* incomingSession = [[NgnAVSession getSessionWithId: eargs.sessionId] retain];
			if (incomingSession && [UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
				UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
				if (localNotif){
					bool _isVideoCall = isVideoType(incomingSession.mediaType);
					NSString *remoteParty = incomingSession.historyEvent ? incomingSession.historyEvent.remotePartyDisplayName : [incomingSession getRemotePartyUri];
					
					NSString *stringAlert = [NSString stringWithFormat:@"Call from \n %@", remoteParty];
					if (_isVideoCall)
						stringAlert = [NSString stringWithFormat:@"Video call from \n %@", remoteParty];
					
					localNotif.alertBody = stringAlert;
					localNotif.soundName = UILocalNotificationDefaultSoundName; 
					localNotif.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
					localNotif.repeatInterval = 0;
					NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
											  kNotifKey_IncomingCall, kNotifKey,
											  [NSNumber numberWithLong:incomingSession.id], kNotifIncomingCall_SessionId,
											  nil];
					localNotif.userInfo = userInfo;
					[[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
				}
			}
			else if(incomingSession){
				[CallViewController receiveIncomingCall:incomingSession];
			}
			
			[NgnAVSession releaseSession:&incomingSession];
			break;
		}
			
		case INVITE_EVENT_MEDIA_UPDATED:
		{
			NgnAVSession* session = [[NgnAVSession getSessionWithId:eargs.sessionId] retain];
			if(session){
				// Dismiss previous and display(present) the new one
				// animation must be NO because we are calling dismiss then present
				[self.tabBarController dismissModalViewControllerAnimated:NO];
				[CallViewController displayCall:session];
			}
			[NgnAVSession releaseSession:&session];
			break;
		}
			
		case INVITE_EVENT_TERMINATED:
		{
			if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
				// call terminated while in background
				// if the application goes to background while in call then the keepAwake mechanism was not started
				if([NgnEngine sharedInstance].sipService.registered && ![NgnAVSession hasActiveSession]){
					if([[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_KEEPAWAKE]){
						[[NgnEngine sharedInstance] startKeepAwake];
					}
				}
			}
			break;
		}
		
		default:
		{
			break;
		}
	}
}

@end

//
//	Default implementation
//
@implementation idoubs2AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize contactsViewController;
@synthesize messagesViewController;

static UIBackgroundTaskIdentifier sBackgroundTask = UIBackgroundTaskInvalid;
static dispatch_block_t sExpirationHandler = nil;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 
    
	// add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onNetworkEvent:) name:kNgnNetworkEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onNativeContactEvent:) name:kNgnContactEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onStackEvent:) name:kNgnStackEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
	
	// start the engine
	[[NgnEngine sharedInstance] start];
	
	// Set the tab bar controller as the window's root view controller and display.
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
	// switch to Numpad tab
	[self.tabBarController setSelectedIndex: kTabBarIndex_Numpad];
	
	// Try to register the default identity
	[self queryConfigurationAndRegister];
	
	
	// enable the speaker: for errors, ringtone, numpad, ...
	// shoud be done after the SipStack is initialized (thanks to tdav_init() which will initialize the audio system)
	[[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
	
	multitaskingSupported = [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [[UIDevice currentDevice] isMultitaskingSupported];
	sBackgroundTask = UIBackgroundTaskInvalid;
	sExpirationHandler = ^{
		NSLog(@"Background task completed");
		// keep awake
		if([[NgnEngine sharedInstance].sipService isRegistered]){
			if([[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_KEEPAWAKE]){
				[[NgnEngine sharedInstance] startKeepAwake];
			}
		}
		[[UIApplication sharedApplication] endBackgroundTask:sBackgroundTask];
		sBackgroundTask = UIBackgroundTaskInvalid;
    };
	
	if(multitaskingSupported){
		NgnNSLog(TAG, @"Multitasking IS supported");
	}
	
	// Set media parameters if you want
	MediaSessionMgr::defaultsSetAudioGain(0, 0);
	// Set some codec priorities
	/*int prio = 0;
	SipStack::setCodecPriority(tdav_codec_id_g722, prio++);
	SipStack::setCodecPriority(tdav_codec_id_speex_wb, prio++);
	SipStack::setCodecPriority(tdav_codec_id_pcma, prio++);
	SipStack::setCodecPriority(tdav_codec_id_pcmu, prio++);
	SipStack::setCodecPriority(tdav_codec_id_h264_bp, prio++);
	SipStack::setCodecPriority(tdav_codec_id_h264_mp, prio++);
	SipStack::setCodecPriority(tdav_codec_id_vp8, prio++);*/
	//...etc etc etc
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// application.idleTimerDisabled = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
	if([idoubs2AppDelegate sharedInstance]->multitaskingSupported){
		ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
		if(registrationState == CONN_STATE_CONNECTING || registrationState == CONN_STATE_CONNECTED){
			NSLog(@"applicationDidEnterBackground (Registered or Registering)");
			//if(registrationState == CONN_STATE_CONNECTING){
			// request for 10min to complete the work (registration, computation ...)
			sBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:sExpirationHandler];
			//}
			if(registrationState == CONN_STATE_CONNECTED){
                if([[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_KEEPAWAKE]){
                    if(![NgnAVSession hasActiveSession]){
						[[NgnEngine sharedInstance] startKeepAwake];
                    }
                }
			}
			
			[application setKeepAliveTimeout:600 handler: ^{
				NSLog(@"applicationDidEnterBackground:: setKeepAliveTimeout:handler^");
			}];
		}
	}
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED */
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
	// application.idleTimerDisabled = NO;
	
    ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
	NgnNSLog(TAG, @"applicationWillEnterForeground and RegistrationState=%d, NetworkReachable=%s", registrationState, [NgnEngine sharedInstance].networkService.reachable ? "TRUE" : "FALSE");
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
	// terminate background task
	if(sBackgroundTask != UIBackgroundTaskInvalid){
		[[UIApplication sharedApplication] endBackgroundTask:sBackgroundTask]; // Using shared instance will crash the application
		sBackgroundTask = UIBackgroundTaskInvalid;
	}
	// stop keepAwake
	[[NgnEngine sharedInstance] stopKeepAwake];
	
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED */
	
	if(registrationState != CONN_STATE_CONNECTED){
		[self queryConfigurationAndRegister];
	}
	
	// check native contacts changed while app was runnig on background
	if(self->nativeABChangedWhileInBackground){
		// trigger refresh
		self->nativeABChangedWhileInBackground = NO;
	}
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
	
	NSString *notifKey = [notification.userInfo objectForKey:kNotifKey];
	if([notifKey isEqualToString:kNotifKey_IncomingCall]){
		NSNumber* sessionId = [notification.userInfo objectForKey:kNotifIncomingCall_SessionId];
		NgnAVSession* session = [[NgnAVSession getSessionWithId:[sessionId longValue]] retain];
		
		if(session){
			[CallViewController receiveIncomingCall:session];
			[session release];
			application.applicationIconBadgeNumber -= notification.applicationIconBadgeNumber;
		}
	}
	else if([notifKey isEqualToString:kNotifKey_IncomingMsg]){
		[self selectTabMessages];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationWillTerminate");
	
    [[NgnEngine sharedInstance] stop];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods


 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	 if(self.tabBarController.selectedIndex == kTabBarIndex_Recents){
		 // reset badge number
		 [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	 }
 }
 

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NgnEngine sharedInstance].contactService unload];
	[[NgnEngine sharedInstance].historyService clear];
	[[NgnEngine sharedInstance].storageService clearFavorites];
}

-(AudioCallViewController *)audioCallController{
	if(!self->audioCallController){
		self->audioCallController = [[AudioCallViewController alloc] initWithNibName: @"AudioCallView" bundle:nil];;
	}
	return self->audioCallController;
}

-(VideoCallViewController *)videoCallController{
	if(!self->videoCallController){
		self->videoCallController = [[VideoCallViewController alloc] initWithNibName: @"VideoCallView" bundle:nil];;
	}
	return self->videoCallController;
}

-(ChatViewController *)chatViewController{
	if(!self->chatViewController){
		self->chatViewController = [[ChatViewController alloc] initWithNibName: @"ChatView" bundle:nil];
	}
	return self->chatViewController;
}

-(void) selectTabContacts{
	self.tabBarController.selectedIndex = kTabBarIndex_Contacts;
}

-(void) selectTabMessages{
	self.tabBarController.selectedIndex = kTabBarIndex_Messages;
}

+(idoubs2AppDelegate*) sharedInstance{
	return ((idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate]);
}

- (void)dealloc {
    [tabBarController release];
	[contactsViewController release];
	[audioCallController release];
	[videoCallController release];
	[messagesViewController release];
	[chatViewController release];
	
    [window release];
    [super dealloc];
}

@end
