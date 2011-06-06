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
#import "idoubs2AppDelegate.h"

#import "AudioCallViewController.h"
#import "VideoCallViewController.h"

#undef TAG
#define kTAG @"idoubs2AppDelegate///: "
#define TAG kTAG
#define kTabBarIndex_Favorites	0
#define kTabBarIndex_Recents	1
#define kTabBarIndex_Contacts	2
#define kTabBarIndex_Numpad		3
#define kTabBarIndex_Messages	4

#define kNotifKey						@"key"
#define kNotifKey_IncomingCall			@"icall"
#define kNotifIncomingCall_SessionId	@"sid"

//
//	sip callback events implementation
//
@interface idoubs2AppDelegate(SipCallbackEvents)
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onMessagingEvent:(NSNotification*)notification;
-(void) onInviteEvent:(NSNotification*)notification;
@end

@implementation idoubs2AppDelegate(SipCallbackEvents)

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {	
	// gets the new registration state
	ConnectionState_t registrationState = [[NgnEngine getInstance].sipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			if(scheduleRegistration){
				scheduleRegistration = FALSE;
				[[NgnEngine getInstance].sipService registerIdentity];
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
				NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUri];
				NSString* userName = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUserName];
				NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				
				NSLog(@"Incoming message from:%@\n with ctype:%@\n and content:%@", from, contentType, content);
				
				NgnHistorySMSEvent *smsEvent = [NgnHistoryEvent createSMSEventWithStatus:HistoryEventStatus_Incoming 
																		  andRemoteParty:userName
																			  andContent:eargs.payload];
				[[NgnEngine getInstance].historyService addEvent:smsEvent];
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
					localNotif.alertBody =[NSString  stringWithFormat:@"%@ call from\n %@", _isVideoCall ? @"Video" : @"Audio", remoteParty];
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

			[incomingSession release];
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

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
	
	// start the engine
	[[NgnEngine getInstance] start];
	
	// Set the tab bar controller as the window's root view controller and display.
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
	// switch to Numpad tab
	[self.tabBarController setSelectedIndex: kTabBarIndex_Numpad];
	
	// Try to register the default identity
	[[NgnEngine getInstance].sipService registerIdentity];
	
	// enable the speaker: for errors, ringtone, numpad, ...
	// shoud be done after the SipStack is initialized (thanks to tdav_init() which will initialize the audio system)
	[[NgnEngine getInstance].soundService setSpeakerEnabled: YES];
	
	multitaskingSupported = [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [[UIDevice currentDevice] isMultitaskingSupported];
	backgroundTask = UIBackgroundTaskInvalid;
	expirationHandler = ^{
		NSLog(@"Background task completed");
		// keep awake
		if([[NgnEngine getInstance].sipService isRegistered]){
			[[NgnEngine getInstance] startKeepAwake];
		}
		[idoubs2AppDelegate sharedInstance]->backgroundTask = UIBackgroundTaskInvalid;
    };
	
	if(multitaskingSupported){
		NSLog(@"Multitasking IS supported");
	}
	
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
		ConnectionState_t registrationState = [[NgnEngine getInstance].sipService getRegistrationState];
		if(registrationState == CONN_STATE_CONNECTING || registrationState == CONN_STATE_CONNECTED){
			NSLog(@"applicationDidEnterBackground (Registered or Regitering)");
			// request for 10min to complete the work (registration, computation ...)
			[idoubs2AppDelegate sharedInstance]->backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:self->expirationHandler];
			//[application setKeepAliveTimeout:600 handler: ^{
			//	NSLog(@"applicationDidEnterBackground:: setKeepAliveTimeout:handler^");
			//}];
		}
	}
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED */
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
	// application.idleTimerDisabled = NO;
	
    ConnectionState_t registrationState = [[NgnEngine getInstance].sipService getRegistrationState];
	NgnNSLog(TAG, @"applicationWillEnterForeground and RegistrationState=%d", registrationState);
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
	// terminate background task
	if([idoubs2AppDelegate sharedInstance]->backgroundTask != UIBackgroundTaskInvalid){
		[application endBackgroundTask:[idoubs2AppDelegate sharedInstance]->backgroundTask]; // Using shared instance will crash the application
		[idoubs2AppDelegate sharedInstance]->backgroundTask = UIBackgroundTaskInvalid;
	}
	// stop keepAwake
	[[NgnEngine getInstance] stopKeepAwake];
	
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED */
	
	// register if not already done
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			[[NgnEngine getInstance].sipService registerIdentity];
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			scheduleRegistration = TRUE;
			[[NgnEngine getInstance].sipService unRegisterIdentity];
			break;
		case CONN_STATE_CONNECTED:
			break;
	}
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
	
	NSString *notifKey = [notification.userInfo objectForKey:kNotifKey];
	if([notifKey isEqualToString:kNotifKey_IncomingCall]){
		NSNumber* sessionId = [notification.userInfo objectForKey:kNotifIncomingCall_SessionId];
		NgnAVSession* session = [[NgnAVSession getSessionWithId:[sessionId longValue]] retain];
		
		if(session){
			[CallViewController receiveIncomingCall: session];
			[session release];
			application.applicationIconBadgeNumber -= notification.applicationIconBadgeNumber;
		}
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationWillTerminate");
	
    [[NgnEngine getInstance] stop];
	
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
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
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
