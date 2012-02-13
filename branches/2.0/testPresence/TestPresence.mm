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
#import "TestPresence.h"

// Include all headers
#import "iOSNgnStack.h"

#undef TAG
#define kTAG @"TestPresence///: "
#define TAG kTAG

// Credentials
static const NSString* kProxyHost = @"proxy.sipthor.net";
static const int kProxyPort = 5060;
static const NSString* kRealm = @"sip2sip.info";
static const NSString* kPassword = @"d3sb7j4fb8";
static const NSString* kPrivateIdentity = @"2233392625";
static const NSString* kPublicIdentity = @"sip:2233392625@sip2sip.info";
static const BOOL kEnableEarlyIMS = TRUE;


//
// Presence implementation
//

@interface TestPresence(Presence)
-(BOOL) subscribe;
-(BOOL) unSubscribe;
-(BOOL) isSubscribed;
-(BOOL) publish;
-(BOOL) unPublish;
-(BOOL) isPublished;
@end


@implementation TestPresence(Presence)

-(BOOL) subscribe{
	if(!mSubSession){
		mSubSession = [[NgnSubscriptionSession createOutgoingSessionWithStack:[NgnEngine sharedInstance].sipService.stack 
																	andToUri:[NgnEngine sharedInstance].sipService.defaultIdentity
																   andPackage:EventPackage_PresenceList] retain];
	}
	return [mSubSession subscribe];
}

-(BOOL) unSubscribe{
	if(mSubSession){
		return [mSubSession unSubscribe];
	}
	return NO;
}

-(BOOL) isSubscribed{
	if(mSubSession){
		return mSubSession.connected;
	}
	return NO;
}

-(BOOL) publish{
	if(!mPubSession){
		mPubSession = [[NgnPublicationSession createOutgoingSessionWithStack:[NgnEngine sharedInstance].sipService.stack 
																	andToUri:[NgnEngine sharedInstance].sipService.defaultIdentity] retain];
		mPubSession.event = @"presence";
		mPubSession.contentType = kContentTypePidf;
	}
	return [mPubSession publishContent: [NgnPublicationSession createPresenceContentWithEntityUri:mPubSession.fromUri 
																					andStatus:PresenceStatus_Online 
																					  andNote:@"hello"]
			];
}

-(BOOL) unPublish{
	if(mPubSession){
		return [mPubSession unPublish];
	}
	return NO;
}

-(BOOL) isPublished{
	return NO;
}

@end

//
// SipCallbackEvents
//

@interface TestPresence(SipCallbackEvents)
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onSubscriptionEvent:(NSNotification*)notification;
-(void) onPublicationEvent:(NSNotification*)notification;
@end

@implementation TestPresence(SipCallbackEvents)

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
	[buttonRegister setTitle: [NgnEngine sharedInstance].sipService.registered ? @"UnRegister" : @"Register" forState: UIControlStateNormal];
	labelStatus.text = eargs.sipPhrase;
	
	// gets the new registration state
	ConnectionState_t registrationState = [NgnEngine sharedInstance].sipService.registrationState;	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
		default:
			[buttonRegister setTitle: @"Register" forState: UIControlStateNormal];
			if(mScheduleRegistration){
				mScheduleRegistration = FALSE;
				[[NgnEngine sharedInstance].sipService registerIdentity];
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

//== Subscription events == //
-(void) onSubscriptionEvent:(NSNotification*)notification{
	NgnSubscriptionEventArgs* eargs = [notification object];
	
	// only process the event if it's ours
	if(mSubSession && mSubSession.id == eargs.sessionId){
		switch (eargs.eventType) {
			[self.buttonSubscribe setTitle:mSubSession.connected ? @"UnSubscribe" : @"Subscribe" forState: UIControlStateNormal];
			
			case INCOMING_NOTIFY:
			{
				// process notify content
				// eargs.content; 
				// eargs.contentType;
				break;
			}
		
			default:
			case SUBSCRIPTION_OK:
			case SUBSCRIPTION_NOK:
			case SUBSCRIPTION_INPROGRESS:
			case UNSUBSCRIPTION_OK:
			case UNSUBSCRIPTION_NOK:
			case UNSUBSCRIPTION_INPROGRESS:
			{
				self.labelStatus.text = eargs.sipPhrase;
				break;
			}
		}
	}
}

//== Publication events == //
-(void) onPublicationEvent:(NSNotification*)notification{
	NgnPublicationEventArgs* eargs = [notification object];
	
	// only process the event if it's ours
	if(mPubSession && mPubSession.id == eargs.sessionId){
		switch (eargs.eventType) {
				[self.buttonPublish setTitle:mPubSession.connected ? @"UnPublish" : @"Publish" forState: UIControlStateNormal];
				
			default:
			case PUBLICATION_OK:
			case PUBLICATION_NOK:
			case PUBLICATION_INPROGRESS:
			case UNPUBLICATION_OK:
			case UNPUBLICATION_NOK:
			case UNPUBLICATION_INPROGRESS:
			{
				self.labelStatus.text = eargs.sipPhrase;
				break;
			}
		}
	}		
}

@end


//
//	default implementation
//

@implementation TestPresence

@synthesize window;
@synthesize activityIndicator;
@synthesize buttonRegister;
@synthesize buttonPublish;
@synthesize buttonSubscribe;
@synthesize labelStatus;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NgnNSLog(TAG, @"applicationDidFinishLaunching");
    
	// add observers
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onSubscriptionEvent:) name:kNgnSubscriptionEventArgs_Name object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onPublicationEvent:) name:kNgnPublicationEventArgs_Name object:nil];
	
	// start the engine
	[[NgnEngine sharedInstance] start];
	
	// set credentials
	[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPI andValue:kPrivateIdentity];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPU andValue:kPublicIdentity];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_PASSWORD andValue:kPassword];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:kRealm];
	[[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_HOST andValue:kProxyHost];
	[[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_PCSCF_PORT andValue:kProxyPort];
	[[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_EARLY_IMS andValue:kEnableEarlyIMS];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
	
	// Try to register the default identity
	[[NgnEngine sharedInstance].sipService registerIdentity];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
	ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
	NgnNSLog(TAG, @"applicationWillEnterForeground and RegistrationState=%d", registrationState);
	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			[[NgnEngine sharedInstance].sipService registerIdentity];
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			mScheduleRegistration = TRUE;
			[[NgnEngine sharedInstance].sipService unRegisterIdentity];
		case CONN_STATE_CONNECTED:
			break;
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NgnNSLog(TAG, @"applicationWillTerminate");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[NgnEngine sharedInstance] stop];
}

- (IBAction) onButtonClick: (id)sender{
	ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			if(sender == self.buttonRegister){
				[[NgnEngine sharedInstance].sipService registerIdentity];
			}
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
		case CONN_STATE_CONNECTED:
			if(sender == self.buttonRegister){
				[[NgnEngine sharedInstance].sipService unRegisterIdentity];
			}
			break;
	}
	
	if(sender == self.buttonSubscribe){
		if([self isSubscribed]){
			[self unSubscribe];
		}
		else {
			[self subscribe];
		}
	}
	else if(sender == self.buttonPublish){
		if([self isPublished]){
			[self unPublish];
		}
		else {
			[self publish];
		}
	}
}

- (void)dealloc {
	[self.activityIndicator release];
	[self.buttonRegister release];
	[self.buttonSubscribe release];
	[self.buttonPublish release];
	[self.labelStatus release];
    [self.window release];
	
	[NgnSubscriptionSession releaseSession:&mSubSession];
	[mPubSession release];
	
    [super dealloc];
}

@end
