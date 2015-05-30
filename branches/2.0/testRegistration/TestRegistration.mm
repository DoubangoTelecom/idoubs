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
#import "TestRegistration.h"

// Include all headers
#import "iOSNgnStack.h"

#undef TAG
#define kTAG @"TestRegistration///: "
#define TAG kTAG

// Credentials
static NSString* kProxyHost = @"proxy.sipthor.net";
static int kProxyPort = 5060;
static NSString* kRealm = @"sip2sip.info";
static NSString* kPassword = @"d3sb7j4fb8";
static NSString* kPrivateIdentity = @"2233392625";
static NSString* kPublicIdentity = @"sip:2233392625@sip2sip.info";
static BOOL kEnableEarlyIMS = TRUE;

@implementation TestRegistration(SipCallbackEvents)

//== Registrations events == //
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
			[activityIndicator stopAnimating];
		default:
			break;
	}
	[buttonRegister setTitle: [mSipService isRegistered] ? @"UnRegister" : @"Register" forState: UIControlStateNormal];
	labelStatus.text = eargs.sipPhrase;
	
	// gets the new registration state
	ConnectionState_t registrationState = [mSipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
		default:
			[buttonRegister setTitle: @"Register" forState: UIControlStateNormal];
			if(mScheduleRegistration){
				mScheduleRegistration = FALSE;
				[mSipService registerIdentity];
			}
			labelStatus.backgroundColor = [UIColor redColor];
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			[buttonRegister setTitle: @"Cancel" forState: UIControlStateNormal];
			labelStatus.backgroundColor = [UIColor redColor];
			break;
		case CONN_STATE_CONNECTED:
			[buttonRegister setTitle: @"UnRegister" forState: UIControlStateNormal];
			labelStatus.backgroundColor = [UIColor greenColor];
			break;
	}
}

@end

@implementation TestRegistration

@synthesize window;
@synthesize activityIndicator;
@synthesize buttonRegister;
@synthesize labelStatus;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NgnNSLog(TAG, @"applicationDidFinishLaunching");
		
	
	// add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	
	// take an instance of the engine
	mEngine = [[NgnEngine sharedInstance] retain];
	[mEngine start];// start the engine
	
	// take needed services from the engine
	mSipService = [[mEngine getSipService] retain];
	mConfigurationService = [[mEngine getConfigurationService] retain];
	
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
		case CONN_STATE_CONNECTED:
			break;
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationWillTerminate");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mEngine release];
	[mSipService release];
	[mConfigurationService release];
}

- (IBAction) onButtonRegisterClick: (id)sender{
	ConnectionState_t registrationState = [mSipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			[mSipService registerIdentity];
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
		case CONN_STATE_CONNECTED:
			[mSipService unRegisterIdentity];
			break;
	}
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
