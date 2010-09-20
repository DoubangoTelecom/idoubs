//
//  SipService.m
//  iDoubs
//
//  Created by Mamadou DIOP on 9/3/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import "SipService.h"

#import "DWSipSession.h"
#import "DWSipEvent.h"

#import "EventArgs.h"
#import "NSNotificationCenter+MainThread.h"

#import "ServiceManager.h"

//
// Private functions
//
@interface SipService()

@end

@implementation SipService

-(SipService*)init{
	self = [super init];
	
	return self;
}


//
// PService
//
-(BOOL) start{
	return YES;
}

-(BOOL) stop{
	if(self->sipStack && (self->sipStack.state == STACK_STATE_STARTING || self->sipStack.state == STACK_STATE_STARTED)){
		return [self->sipStack stop];
	}
	return YES;
}


//
//	PSipService
//
-(BOOL)stopStack{
	return NO;
}

-(BOOL)registerIdentity{
	
	NSString* realm = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_REALM];
	NSString* impi = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_IDENTITY entry:CONFIGURATION_ENTRY_IMPI];
	NSString* impu = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_IDENTITY entry:CONFIGURATION_ENTRY_IMPU];
	
	NSLog(@"realm=%@, impi=%@, impu=%@", realm, impi, impu);
	
	if(self->sipStack == nil){
		self->sipStack = [[DWSipStack alloc] initWithDelegate:self realmUri:realm impiUri:impi impuUri:impu];
	}
	else {
		if(![self->sipStack setRealm:realm]){
			NSLog(@"Failed to set realm");
			return NO;
		}
		if(![self->sipStack setIMPI:impi]){
			NSLog(@"Failed to set IMPI");
			return NO;
		}
		if(![self->sipStack setIMPU:impu]){
			NSLog(@"Failed to set IMPU");
			return NO;
		}
	}
	
	// set the password
	NSString* password = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_IDENTITY entry:CONFIGURATION_ENTRY_PASSWORD];
	[self->sipStack setPassword:password];
	
	
	// Set AMF
	NSString* amf = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_SECURITY entry:CONFIGURATION_ENTRY_IMSAKA_AMF];
	[self->sipStack setAMF:amf];
	// Set Operator Id
	NSString* operatorId = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_SECURITY entry:CONFIGURATION_ENTRY_IMSAKA_OPID];
	[self->sipStack setOperatorId:operatorId];
	
	// check stack validity
	if(![self->sipStack isValid]){
		NSLog(@"Trying to use invalid stack");
		return NO;
	}
	
	
	// set STUN information
	BOOL useSTUN = [SharedServiceManager.configurationService getBoolean: CONFIGURATION_SECTION_NATT entry:CONFIGURATION_ENTRY_USE_STUN];
	if(useSTUN){
		BOOL discoSTUN  = [SharedServiceManager.configurationService getBoolean: CONFIGURATION_SECTION_NATT entry:CONFIGURATION_ENTRY_STUN_DISCO];
		if(discoSTUN){
			// FIXME: discover STUN
		}
		else {
			NSString* serverSTUN = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_NATT entry:CONFIGURATION_ENTRY_STUN_SERVER];
			int portSTUN = [SharedServiceManager.configurationService getInt:CONFIGURATION_SECTION_NATT entry:CONFIGURATION_ENTRY_STUN_PORT];
		
			[self->sipStack setSTUNServerIP:serverSTUN andPort:portSTUN];
		}
	}
	else{
		[self->sipStack setSTUNServerIP:nil andPort:0];
	}
	
	// set Proxy-CSCF (uses nil instead of "127.0.0.1" to trigger DNS NAPTR discovery)
	NSString* proxyHost = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_PCSCF_HOST];
	int proxyPort = [SharedServiceManager.configurationService getInt:CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_PCSCF_PORT];
	NSString* transport = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_TRANSPORT];
	NSString* ipVersion = [SharedServiceManager.configurationService getString:CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_IP_VERSION];
	
	NSLog(@"proxyHost=%@, proxyPort=%d, transport=%@, ipVersion=%@", 
		  proxyHost, proxyPort, transport, ipVersion);
	
	if(![self->sipStack setProxyCSCFWithFQDN:proxyHost andPort:proxyPort andTransport:transport andIPVersion:ipVersion]){
		NSLog(@"Failed to set Proxy-CSCF parameters");
		return NO;
	}
	
	// set local IP (Only needed in Android version)
	//[self->sipStack setLocalIP:@"*.*.*.*"];
	
	// FIXME
	// Whether to use DNS NAPTR+SRV for the Proxy-CSCF discovery (even if the DNS requests are sent only when the stack starts,
	// should be done after setProxyCSCF())
	//[self->sipStack setDnsDiscovery:NO];
	
	// enable/disable 3GPP early IMS
	BOOL earlyIMS = [SharedServiceManager.configurationService getBoolean: CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_EARLY_IMS];
	[self->sipStack setEarlyIMS:earlyIMS];
	
	// SigComp (only update compartment Id if changed)
	
	BOOL useSigComp = [SharedServiceManager.configurationService getBoolean: CONFIGURATION_SECTION_NETWORK entry:CONFIGURATION_ENTRY_SIGCOMP];
	if(useSigComp){
		NSString* compId = [NSString stringWithFormat:@"urn:uuid:%s", [[NSProcessInfo processInfo] globallyUniqueString]];
		[self->sipStack setSigCompId:compId];
	}
	else{
		[self->sipStack setSigCompId:nil];
	}
		
	// start the stack
	if(![self->sipStack start]){
		NSLog(@"Failed to start SIP stack");
		return NO;
	}
	
	
	// Create registration session
	if (self->registrationSession == nil) {
		self->registrationSession = (DWRegistrationSession*)[[DWRegistrationSession alloc] initWithStack:self->sipStack];
	}
	else{
		[self->registrationSession setSigCompId: [self->sipStack sigCompId]];
	}
	// set/update From URI. For Registration ToUri should be equals to realm
	// (done by the stack)
	[self->registrationSession setFromUri:impu];
	// set Expires (FIXME)
	[self->registrationSession setExpires:360];
	// send Register Request to the server
	if(![self->registrationSession registerIdentity]){
		NSLog(@"Failed to send REGISTER request");
		return NO;
	}
	
	

	return YES;
}

-(BOOL)unRegisterIdentity{
	if(self->registrationSession){
		return [self->registrationSession unRegisterIdentity];
	}
	
	return NO;
}

-(BOOL)publish{
	return NO;
}

-(BOOL)isRegistered{
	return (self->registrationSession != nil && self->registrationSession.state == SESSION_STATE_CONNECTED);
}


-(DWSipStack*) sipStack{
	return self->sipStack;
}



-(int) onStackEvent: (DWStackEvent*) e {
	switch([e code]){
		case tsip_event_code_stack_started:
			self->sipStack.state = STACK_STATE_STARTED;
			NSLog(@"Stack started");
			break;
		case tsip_event_code_stack_failed_to_start:
			NSLog(@"Failed to start SIP Stack: %s", e.phrase);
			break;
		case tsip_event_code_stack_failed_to_stop:
			NSLog(@"Failed to stop the stack");
			break;
		case tsip_event_code_stack_stopped:
			self->sipStack.state = STACK_STATE_STOPPED;
			break;
	}
	return 0;
}


-(int) onRegistrationEvent: (DWRegistrationEvent*) e {
	return 0;
}

-(int) onDialogEvent: (DWDialogEvent*) e {
	
	EventArgs* eargs = nil;
	DWSipSession* baseSession;
	
	short code = e.code;
	if(!(baseSession = e.baseSession)){
		NSLog(@"Invalid Session");
		return -1;
	}
	
	tsip_ssession_id_t session_id = baseSession.id;
	SESSION_TYPE_T type = baseSession.type;
	NSString* phrase = e.phrase;
	SESSION_STATE_T oldState = baseSession.state;
	
	switch (code) {
		case tsip_event_code_dialog_connecting:
		{
			baseSession.state = SESSION_STATE_CONNECTING;
			
			switch (type) {
				case SESSION_TYPE_REGISTRATION:
					// Registration
					if(self->registrationSession != nil && (session_id==self->registrationSession.id)){
						eargs = [[RegistrationEventArgs alloc] initWithType:REGISTRATION_INPROGRESS andSipCode:code andPhrase:phrase];
						[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
						[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[RegistrationEventArgs eventName] object:eargs];
					}
					else{
						NSLog(@"Invalid Registration Session");
					}
					break;
					
					// Audio/Video/Msrp Calls
				case SESSION_TYPE_INVITE:
				case SESSION_TYPE_MSRP:
				case SESSION_TYPE_CALL:
					eargs = [[InviteEventArgs alloc]initWithType:INVITE_INPROGRESS andSipCode:code andPhrase:phrase];
					[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[InviteEventArgs eventName] object:eargs];
					break;
			}		
			
			break;
		}
		
		case tsip_event_code_dialog_connected:
		{
			baseSession.state = SESSION_STATE_CONNECTED;
			
			switch (type) {
				case SESSION_TYPE_REGISTRATION:
					// Registration
					if(self->registrationSession != nil && (session_id==self->registrationSession.id)){
						eargs = [[RegistrationEventArgs alloc] initWithType:REGISTRATION_OK andSipCode:code andPhrase:phrase];
						[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
						[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[RegistrationEventArgs eventName] object:eargs];
					}
					else{
						NSLog(@"Invalid Registration Session");
					}
					break;
					
					// Audio/Video/Msrp Calls
				case SESSION_TYPE_INVITE:
				case SESSION_TYPE_MSRP:
				case SESSION_TYPE_CALL:
					eargs = [[InviteEventArgs alloc]initWithType:INVITE_CONNECTED andSipCode:code andPhrase:phrase];
					[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[InviteEventArgs eventName] object:eargs];
					break;
			}
			
			break;
		}
			
		case tsip_event_code_dialog_terminating:
		{
			baseSession.state = SESSION_STATE_DISCONNECTING;
			
			switch (type) {
				case SESSION_TYPE_REGISTRATION:
					// Registration
					if(self->registrationSession != nil && (session_id==self->registrationSession.id)){
						RegistrationEventTypes_t type = UNREGISTRATION_INPROGRESS;
						eargs = [[RegistrationEventArgs alloc] initWithType:type andSipCode:code andPhrase:phrase];
						[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
						[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[RegistrationEventArgs eventName] object:eargs];						
					}
					else{
						NSLog(@"Invalid Registration Session");
					}
					break;
					
					// Audio/Video/Msrp Calls
				case SESSION_TYPE_INVITE:
				case SESSION_TYPE_MSRP:
				case SESSION_TYPE_CALL:
					eargs = [[InviteEventArgs alloc]initWithType:INVITE_TERMWAIT andSipCode:code andPhrase:phrase];
					[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[InviteEventArgs eventName] object:eargs];
					break;
			}			
			
			break;
		}
			
		case tsip_event_code_dialog_terminated:
		{
			baseSession.state = SESSION_STATE_DISCONNECTED;
			
			switch (type) {
				case SESSION_TYPE_REGISTRATION:
					// Registration
					if(self->registrationSession != nil && (session_id==self->registrationSession.id)){
						RegistrationEventTypes_t type = (oldState == SESSION_STATE_CONNECTED || oldState == SESSION_STATE_DISCONNECTING)
						? UNREGISTRATION_OK : REGISTRATION_NOK;
						eargs = [[RegistrationEventArgs alloc] initWithType:type andSipCode:code andPhrase:phrase];
						[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
						[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[RegistrationEventArgs eventName] object:eargs];						
						/* FIXME: Stop the stack (as we are already in the stack-thread, then do it in a new thread) */
					}
					else{
						NSLog(@"Invalid Registration Session");
					}
					break;
					
					// Audio/Video/Msrp Calls
				case SESSION_TYPE_INVITE:
				case SESSION_TYPE_MSRP:
				case SESSION_TYPE_CALL:
					eargs = [[InviteEventArgs alloc]initWithType:INVITE_DISCONNECTED andSipCode:code andPhrase:phrase];
					[eargs putExtraWithKey:@"id" andValue:[NSString stringWithFormat:@"%lld", session_id]];
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:[InviteEventArgs eventName] object:eargs];
					break;
			}
			
			
			break;
		}
	}
	
	[eargs release];
	
	return 0;
}

//
//	DWSipStackCallback
//
- (int) onEvent: (DWSipEvent*)event{
	int ret = -1;
	
	switch (event.baseType) {
			/*tsip_event_invite,
			 tsip_event_message,
			 tsip_event_options,
			 tsip_event_publish,
			 ,
			 tsip_event_subscribe,
			 
			 ,
			 tsip_event_stack,*/
			
		case tsip_event_dialog:
			{
				DWDialogEvent* stackEvent = [event isMemberOfClass:[DWDialogEvent class]] ? ((DWDialogEvent*)event) : nil;
				ret = [self onDialogEvent: stackEvent];
				break;
			}
			
		case tsip_event_stack:
			{
				DWStackEvent* stackEvent = [event isMemberOfClass:[DWStackEvent class]] ? ((DWStackEvent*)event) : nil;
				ret = [self onStackEvent: stackEvent];
				break;
			}
			
		case tsip_event_register:
			{
				// See OnDialogEvent
				//DWRegistrationEvent* registrationEvent = [event isMemberOfClass:[DWRegistrationEvent class]] ? ((DWRegistrationEvent*)event) : nil;
				//ret = [self onRegistrationEvent: registrationEvent];
				break;
			}
		default:
			break;
	}
	
	return ret;
}



-(void) dealloc{
	[self->registrationSession release];
	[self->sipStack release];
	
	[super dealloc];
}

@end
