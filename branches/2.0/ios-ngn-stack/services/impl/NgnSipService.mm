#import "NgnSipService.h"
#import "NgnConfigurationEntry.h"
#import "NgnEngine.h"
#import "NgnNotificationCenter.h"
#import "NgnStringUtils.h"

#import "NgnRegistrationEventArgs.h"
#import "NgnStackEventArgs.h"

#import "SipCallback.h"
#import "SipEvent.h"

#import "tsk_debug.h"

#undef TAG
#define kTAG @"NgnSipService///: "
#define TAG kTAG

//
//	NgnSipCallback
//

class _NgnSipCallback : public SipCallback
{
public:
	_NgnSipCallback(NgnSipService* sipService) : SipCallback(){
		mSipService = [sipService retain];
	}
	
	~_NgnSipCallback(){
		[mSipService release];
	}
	
	/* == OnDialogEvent == */
	int OnDialogEvent(const DialogEvent* e){
		const char* _phrase = e->getPhrase();
		const short _code = e->getCode();
		const SipSession* _session = e->getBaseSession();
		
		if(!_session){
			TSK_DEBUG_ERROR("Null Sip session");
			return -1;
		}
		
		// This is a POSIX thread but thanks to multithreading
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NgnEventArgs* eargs = nil;
		NSString* phrase = [NgnStringUtils toNSString:_phrase];
		const long _sessionId = _session->getId();
		NgnSipSession* ngnSipSession = nil;
		
		TSK_DEBUG_INFO("OnDialogEvent(%s, %ld)", _phrase, sessionId);
		
		switch (_code) {
			//== Connecting ==
			case tsip_event_code_dialog_connecting:
			{
				// Registration
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] 
							 initWithSessionId:_sessionId andEventType: REGISTRATION_INPROGRESS  andSipCode:_code  andSipPhrase: phrase];
					[mSipService.sipRegSession setConnectionState: CONN_STATE_CONNECTING];					
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
				}
				break;
			}
			
			//== Connected == //
			case tsip_event_code_dialog_connected:
			{
				// Registration
				// mammamia
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] 
							 initWithSessionId:_sessionId andEventType: REGISTRATION_OK  andSipCode:_code  andSipPhrase: phrase];
					[mSipService.sipRegSession setConnectionState: CONN_STATE_CONNECTED];
					// Update default identity (vs barred)
					NSString* defaultIdentity = [mSipService.sipStack getPreferredIdentity];
					if(![NgnStringUtils isNullOrEmpty:defaultIdentity]){
						[mSipService setDefaultIdentity:defaultIdentity];
					}
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
				}
				break;
			}
				
			//== Terminating == //
			case tsip_event_code_dialog_terminating:
			{
				// Registration
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] 
							 initWithSessionId:_sessionId andEventType: UNREGISTRATION_INPROGRESS  andSipCode:_code  andSipPhrase: phrase];
					[mSipService.sipRegSession setConnectionState: CONN_STATE_TERMINATING];					
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
				}
				break;
			}
				
			//== Terminated == //
			case tsip_event_code_dialog_terminated:
			{
				// Registration
				if (mSipService.sipRegSession && mSipService.sipRegSession.id == _sessionId){
					eargs = [[NgnRegistrationEventArgs alloc] 
							 initWithSessionId:_sessionId andEventType: UNREGISTRATION_OK  andSipCode:_code  andSipPhrase: phrase];
					[mSipService.sipRegSession setConnectionState: CONN_STATE_TERMINATED];					
					[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kNgnRegistrationEventArgs_Name object:eargs];
					/* Stop the stack (as we are already in the stack-thread, then do it in a new thread) */
					[mSipService stopStack];
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
	int OnStackEvent(const StackEvent* e) {
		short _code = e->getCode();
		const char* _phrase = e->getPhrase();
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
		[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kNgnStackEventArgs_Name object:eargs];
done:
		[eargs autorelease];
		[pool release];
		return 0; 
	}
	
	/* == OnInviteEvent == */
	int OnInviteEvent(const InviteEvent* e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0; 
	}
	
	/* == OnMessagingEvent == */
	int OnMessagingEvent(const MessagingEvent* e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0;
	}
	
	/* == OnOptionsEvent == */
	int OnOptionsEvent(const OptionsEvent* e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0; 
	}
	
	/* == OnPublicationEvent == */
	int OnPublicationEvent(const PublicationEvent* e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0; 
	}
	
	/* == OnRegistrationEvent == */
	int OnRegistrationEvent(const RegistrationEvent* e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0; 
	}
	
	/* == OnSubscriptionEvent == */
	int OnSubscriptionEvent(const SubscriptionEvent* e) { 
		// This is a POSIX thread but thanks to multithreading
		//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		//done:
		//		[pool release];
		return 0; 
	}
	
private
	:
	NgnSipService* mSipService;
};

//
//	NgnSipService
//

@implementation NgnSipService(Private)

-(void)asyncStackStop {
	if(sipStack && (sipStack.state == STACK_STATE_STARTING || sipStack.state == STACK_STATE_STARTED)){
		[sipStack stop];
	}
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
		mConfigurationService = [[[NgnEngine getInstance] getConfigurationService] retain];
	}
	return self;
}

-(void)dealloc{
	[self->sipPreferences release];
	[mConfigurationService release];
	[self->sipStack release];
	if(_mSipCallback){
		delete _mSipCallback;
	}
	if(sipRegSession){
		[NgnRegistrationSession releaseSessionWithId: [sipRegSession getId]];
		sipRegSession = nil;
	}
	[super dealloc];
}

-(BOOL) start{
	NSLog(@"NgnSipService::Start()");
	return YES;
}

-(BOOL) stop{
	NSLog(@"NgnSipService::Start()");
	return YES;
}

-(NSString*)getDefaultIdentity{
	return nil;
}

-(void)setDefaultIdentity: (NSString*)identity{
	
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

-(BOOL)stopStack{
	[NSThread detachNewThreadSelector:@selector(asyncStackStop) toTarget:self withObject:nil];
	return TRUE;
}

-(BOOL)registerIdentity{
	NgnNSLog(TAG, @"register()");
	
	sipPreferences.realm = [mConfigurationService getStringWithKey:NETWORK_REALM];
	sipPreferences.impi = [mConfigurationService getStringWithKey:IDENTITY_IMPI];
	sipPreferences.impu = [mConfigurationService getStringWithKey:IDENTITY_IMPU];
	NgnNSLog(TAG, @"realm='%@', impu='%@', impi='%@'", sipPreferences.realm, sipPreferences.impu, sipPreferences.impi);
	
	if (sipStack == nil) {
		sipStack = [[NgnSipStack alloc] initWithSipCallback:_mSipCallback andRealmUri:sipPreferences.realm andIMPIUri:sipPreferences.impu andIMPUUri:sipPreferences.impu];
		//SipStack.setCodecs_2(mConfigurationService.getInt(NgnConfigurationEntry.MEDIA_CODECS, 
		//												  NgnConfigurationEntry.DEFAULT_MEDIA_CODECS));
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
		if([mConfigurationService getBoolWithKey:NATT_STUN_DISCO]){
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
	[sipStack setDnsDiscovery:FALSE];           
	
	// enable/disable 3GPP early IMS
	[sipStack setEarlyIMS: [mConfigurationService getBoolWithKey:NETWORK_USE_EARLY_IMS]];
	
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
	[NSThread detachNewThreadSelector:@selector(asyncStackStop) toTarget:self withObject:nil];
	return YES;
}

@end




