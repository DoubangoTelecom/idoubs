#import "TestRegistration.h"

#undef TAG
#define kTAG @"TestRegistration///: "
#define TAG kTAG

// Credentials
//static const NSString* kProxyHost = @"proxy.sipthor.net";
//static const int kProxyPort = 5060;
//static const NSString* kRealm = @"sip2sip.info";
//static const NSString* kPassword = @"d3sb7j4fb8";
//static const NSString* kPrivateIdentity = @"2233392625";
//static const NSString* kPublicIdentity = @"sip:2233392625@sip2sip.info";
//static const BOOL kEnableEarlyIMS = TRUE;

static const NSString* kProxyHost = @"212.123.76.";
static const int kProxyPort = 5060;
static const NSString* kRealm = @"212.123.76.";
static const NSString* kPassword = @"xxxx";
static const NSString* kPrivateIdentity = @"200006395544399062";
static const NSString* kPublicIdentity = @"sip:200006395544399062@212.123.76.";
static const BOOL kEnableEarlyIMS = TRUE;

@implementation TestRegistration(SipCallbackEvents)

//== Registrations events == //
-(void) onRegistrationEvent:(NSNotification*)notification {
	NgnRegistrationEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		// provisional responses
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
			break;
		// final responses
		case REGISTRATION_OK:
		case REGISTRATION_NOK:
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
		default:
			break;
	}
	[buttonRegister setTitle: [mSipService isRegistered] ? @"UnRegister" : @"Register" forState: UIControlStateNormal];
	labelStatus.text = eargs.sipPhrase;
	
	ConnectionState_t registrationState = [mSipService getRegistrationState];	
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			[buttonRegister setTitle: @"Register" forState: UIControlStateNormal];
			if(mScheduleRegistration){
				mScheduleRegistration = FALSE;
				[mSipService registerIdentity];
			}
			break;
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
			[buttonRegister setTitle: @"Cancel" forState: UIControlStateNormal];
			break;
		case CONN_STATE_CONNECTED:
			[buttonRegister setTitle: @"UnRegister" forState: UIControlStateNormal];
			break;
	}
}

@end

@implementation TestRegistration

@synthesize window;
@synthesize buttonRegister;
@synthesize labelStatus;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NgnNSLog(TAG, @"applicationDidFinishLaunching");
    
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
	
	// take an instance of the engine
	mEngine = [[NgnEngine getInstance] retain];
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
