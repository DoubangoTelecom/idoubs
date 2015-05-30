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
#import "TestMessaging.h"

// Include all headers
#import "iOSNgnStack.h"

#undef TAG
#define kTAG @"TestMessaging///: "
#define TAG kTAG

// credentials
static NSString* kProxyHost = @"proxy.sipthor.net";
static int kProxyPort = 5060;
static NSString* kRealm = @"sip2sip.info";
static NSString* kPassword = @"d3sb7j4fb8";
static NSString* kPrivateIdentity = @"2233392625";
static NSString* kPublicIdentity = @"sip:2233392625@sip2sip.info";
static BOOL kEnableEarlyIMS = TRUE;
static NSString* kRemoteParty = @"test";

//
//	sip callback events implementation
//
@implementation TestMessaging(SipCallbackEvents)

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
		buttonSend.backgroundColor = [UIColor greenColor];
		buttonSend.enabled = TRUE;
	}
	else {
		viewStatus.backgroundColor = [UIColor redColor];
		labelStatus.text = @"Not Connected";
		buttonSend.backgroundColor = [UIColor redColor];
		buttonSend.enabled = FALSE;
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
				NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFrom];
				NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				messageTextView.text = 
				[NSString stringWithFormat: @"Incoming message from:%@\n with ctype:%@\n and content:%@",
				 from, contentType, content];
				// If the configuration entry "RCS_AUTO_ACCEPT_PAGER_MODE_IM" (BOOL) is equal to false then
				// you must accept() or reject() the message like this:
				// NgnMessagingSession* imSession = [[NgnMessagingSession getSessionWithId: eargs.sessionId] retain];
				// if(session){
				//	[imSession accept]; // or [imSession reject];
				//	[imSession release];
				//}
				
			}
			break;
		}
	}
	
	labelDebugInfo.text = [NSString stringWithFormat: @"onMessagingEvent: %@", eargs.sipPhrase];
}

@end

@implementation TestMessaging

@synthesize labelStatus;
@synthesize viewStatus;
@synthesize labelDebugInfo;
@synthesize activityIndicator;
@synthesize window;
@synthesize messageTextView;
@synthesize buttonSend;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NgnNSLog(TAG, @"applicationDidFinishLaunching");
	
	// add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
	
	
	// take an instance of the engine
	mEngine = [[NgnEngine sharedInstance] retain];
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
		case CONN_STATE_CONNECTED:
			break;
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationWillTerminate");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mEngine stop];
	
	[mSipService release];
	[mConfigurationService release];
	[mEngine release];
	
}

- (IBAction) onButtonSendClick: (id)sender{
	ActionConfig* actionConfig = new ActionConfig();
	if(actionConfig){
		actionConfig->addHeader("Organization", "Doubango Telecom");
		actionConfig->addHeader("Subject", "testMessaging for iOS");
	}
	NgnMessagingSession* imSession = [[NgnMessagingSession sendTextMessageWithSipStack: [mSipService getSipStack] 
											andToUri: [NSString stringWithFormat: @"sip:%@@%@", kRemoteParty, kRealm]
											andMessage: messageTextView.text
											andContentType: kContentTypePlainText
											andActionConfig: actionConfig
									   ] retain]; // Do not retain the session if you don't want it
	// do whatever you want with the session
	if(actionConfig){
		delete actionConfig, actionConfig = tsk_null;
	}
	[NgnMessagingSession releaseSession: &imSession];
}

- (void)dealloc {
	[activityIndicator release];
	[labelStatus release];
	[viewStatus release];
	[labelDebugInfo release];
	[messageTextView release];
	[buttonSend release];
	[window release];
	
    [super dealloc];
}

@end
