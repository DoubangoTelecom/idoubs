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
#import "TestVideoCall.h"

#undef TAG
#define kTAG @"TestVideoCall///: "
#define TAG kTAG

// credentials
//static const NSString* kProxyHost = @"proxy.sipthor.net";
//static const int kProxyPort = 5060;
//static const NSString* kRealm = @"sip2sip.info";
//static const NSString* kPassword = @"d3sb7j4fb8";
//static const NSString* kPrivateIdentity = @"2233392625";
//static const NSString* kPublicIdentity = @"sip:2233392625@sip2sip.info";
//static const BOOL kEnableEarlyIMS = TRUE;

static const NSString* kProxyHost = @"192.168.0.13";
static const int kProxyPort = 5060;
static const NSString* kRealm = @"doubango.org";
static const NSString* kPassword = @"3497328625";
static const NSString* kPrivateIdentity = @"3497328625";
static const NSString* kPublicIdentity = @"sip:3497328625@doubango.org";
static const BOOL kEnableEarlyIMS = TRUE;

// remote party
static const NSString* kRemoteParty = @"1";


//
//	sip callback events implementation
//

@implementation TestVideoCall(SipCallbackEvents)

//== REGISTER events == //
-(void) onRegistrationEvent:(NSNotification*)notification {
	NgnRegistrationEventArgs* eargs = [notification object];
	
	// Current event triggered the callback
	// to get the current registration state you should use "mSipService::getRegistrationState"
	switch (eargs.eventType) {
			// provisional responses
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
			[activityIndicator startAnimating];
			break;
			// final responses
		case REGISTRATION_OK:
		case REGISTRATION_NOK:
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
		default:
			[activityIndicator stopAnimating];
			break;
	}
	
	labelDebugInfo.text = [NSString stringWithFormat: @"onRegistrationEvent: %@", eargs.sipPhrase];
	if([mSipService isRegistered]){
		viewStatus.backgroundColor = [UIColor greenColor];
		labelStatus.text = @"Connected";
	}
	else {
		viewStatus.backgroundColor = [UIColor redColor];
		labelStatus.text = @"Not Connected";
	}
	
	// gets the new registration state
	ConnectionState_t registrationState = [mSipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			if(mScheduleRegistration){
				mScheduleRegistration = FALSE;
				[mSipService registerIdentity];
			}
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			break;
		case CONN_STATE_CONNECTED:
			break;
	}
}

//== INVITE (audio/video, file transfer, chat, ...) events == //
-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
		{
			if(mCurrentAVSession){
				TSK_DEBUG_ERROR("This is a test application and we only support ONE audio/video call at time!");
				[mCurrentAVSession hangUpCall];
				return;
			}
			
			mCurrentAVSession = [[NgnAVSession getSessionWithId: eargs.sessionId] retain];
			if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
				UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
				if (localNotif){
					localNotif.alertBody =[NSString  stringWithFormat:@"Call from %@", [mCurrentAVSession getRemotePartyUri]];
					localNotif.soundName = UILocalNotificationDefaultSoundName;
					localNotif.applicationIconBadgeNumber = 1;
					localNotif.repeatInterval = 0;
					
					[[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
				}
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] 
									  initWithTitle: @"Incoming Call" 
									  message: [NSString  stringWithFormat:@"Call from %@", [mCurrentAVSession getRemotePartyUri]]
									  delegate: self 
									  cancelButtonTitle: @"No" 
									  otherButtonTitles:@"Yes", nil];
				[alert show];
				[alert release];
			}
			break;
		}
			
		case INVITE_EVENT_INPROGRESS:
		{
			break;
		}
			
		case INVITE_EVENT_EARLY_MEDIA:
		case INVITE_EVENT_CONNECTED:
		{
			if(mCurrentAVSession && (mCurrentAVSession.id == eargs.sessionId)){
				[mCurrentAVSession setRemoteVideoDisplay: imageViewRemoteVideo];
				[mCurrentAVSession setLocalVideoDisplay: viewLocalVideo];
			}
			break;
		}
			
		case INVITE_EVENT_TERMINATED:
		case INVITE_EVENT_TERMWAIT:
		{
			if(mCurrentAVSession && (mCurrentAVSession.id == eargs.sessionId)){
				[mCurrentAVSession setRemoteVideoDisplay: nil];
				[mCurrentAVSession setLocalVideoDisplay: nil];
				[NgnAVSession releaseSession: &mCurrentAVSession];			
			}
			break;
		}
			
		default:
			break;
	}
	
	labelDebugInfo.text = [NSString stringWithFormat: @"onInviteEvent: %@", eargs.sipPhrase];
	[buttonMakeVideoCall setTitle: mCurrentAVSession ? @"End Call" : @"Video Call" forState: UIControlStateNormal];
}

@end



//
// Defaault
//

@implementation TestVideoCall

@synthesize window;
@synthesize activityIndicator;
@synthesize labelStatus;
@synthesize viewStatus;
@synthesize labelDebugInfo;
@synthesize buttonMakeVideoCall;
@synthesize viewLocalVideo;
@synthesize imageViewRemoteVideo;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationDidFinishLaunching");
    
	// add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
	
	// take an instance of the engine
	[NgnEngine initialize];
	mEngine = [[NgnEngine getInstance] retain];
	
	// take needed services from the engine
	mSipService = [mEngine.sipService retain];
	mConfigurationService = [mEngine.configurationService retain];
	
	// start the engine
	[mEngine start];
	
	// set credentials
	[mConfigurationService setStringWithKey: IDENTITY_IMPI andValue: kPrivateIdentity];
	[mConfigurationService setStringWithKey: IDENTITY_IMPU andValue: kPublicIdentity];
	[mConfigurationService setStringWithKey: IDENTITY_PASSWORD andValue: kPassword];
	[mConfigurationService setStringWithKey: NETWORK_REALM andValue: kRealm];
	[mConfigurationService setStringWithKey: NETWORK_PCSCF_HOST andValue:kProxyHost];
	[mConfigurationService setIntWithKey: NETWORK_PCSCF_PORT andValue: kProxyPort];
	[mConfigurationService setBoolWithKey: NETWORK_USE_EARLY_IMS andValue: kEnableEarlyIMS];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
	
	// Try to register the default identity
	[mSipService registerIdentity];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
	ConnectionState_t registrationState = [mSipService getRegistrationState];
	NgnNSLog(TAG, @"applicationWillEnterForeground and RegistrationState=%d", registrationState);
	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			[mSipService registerIdentity];
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			mScheduleRegistration = TRUE;
			[mSipService unRegisterIdentity];
			break;
		case CONN_STATE_CONNECTED:
			break;
	}
}

- (IBAction) onButtonVideoCallClick: (id)sender{
	if(mCurrentAVSession){
		[mCurrentAVSession hangUpCall];
	}
	else {
		mCurrentAVSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty: 
							  [NSString stringWithFormat: @"sip:%@@%@", kRemoteParty, kRealm]  
															andSipStack: [mSipService getSipStack]] retain];
	}
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
	if(mCurrentAVSession){
		if (buttonIndex == 1){
			[mCurrentAVSession acceptCall];
		}
		else {
			[mCurrentAVSession hangUpCall];
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationWillTerminate");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mEngine stop];
	
	[mCurrentAVSession release];
	[mEngine release];
	[mSipService release];
	[mConfigurationService release];
}

- (void)dealloc {
    [window release];
	[activityIndicator release];
	[labelStatus release];
	[viewStatus release];
	[labelDebugInfo release];
	[buttonMakeVideoCall release];
	[viewLocalVideo release];
	[imageViewRemoteVideo release];
	
    [super dealloc];
}

@end
