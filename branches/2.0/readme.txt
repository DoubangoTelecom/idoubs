iOS NGN Stack
This version of the NGN stack is based on Doubango v2.x and has been developed from scratch. If you are using iDoubs v1.x you MUST know that it won't work with this NGN stack.

1) == Building the source code ==

To build the source code you will need: xcode 3.x or later, iOS SDK 4.x or later and svn tools.

a) open new Terminal (Applications => Utilities => Terminal)

b) from the command line, login as root
sudo -i

c) Create new directory named mydoubs anywhere in your disk
mkdir mydoubs
cd mydoubs

d) checkout doubango source code (both trunk and branches) into mydoubs. Important: The destination folder MUST be named doubango.
svn checkout http://doubango.googlecode.com/svn/ doubango

e) create new folder named iPhone into mydoubs
mkdir iPhone
cd iPhone

f) checkout ios-ngn-stack source code into iPhone folder. Important: The destination folder MUST be named idoubs.
svn checkout http://idoubs.googlecode.com/svn/ idoubs

g) change mydoubs folder permissions
cd ../..
chmod -R 777 mydoubs/*

h) open mydoubs/iPhone/idoubs/branches/2.0/ios-ngn-stack.xcodeproj
	1) Very Important: make sure that the right base sdk is selected (iOS SDK x.y): Right click on "ios-ngn-stack" => "Get Info" => "Build" tab => From "Architectures" group adjust "Base SDK" and select "iOS x.y".
	2) build Doubango: Right click on "Doubango" aggregated target and select "Build Doubango"
	3) build the NGN stack: Right click on "ios-ngn-stack" target and select "Build ios-ngn-stack"
	4) build the audio test application: Right click on "testAudioCall" and select "Build testAudioCall". For now don't try to run the test application. See next section for more information.

2) == Adjusting your credentials ==
The default credentials use sip2sip.info and should work for all users. Before changing these credentials you can try to use these credentials to be sure that there are no network issues.
a) From xcode, open Tests/testAudioCall/TestAudioCall.mm
b) From line 13 to 19 you have the default credentials used by the test application. Change them to yours!
c) Right click on "testAudioCall" target and select "Build testAudioCall and Start". If your credentials are correct then you should auto. login (green bar).
Enter any phone number and press "Audio Call" to make a call.

3) == Audio Quality ==
The NGN stack contains two audio system implementations: AudioQueue and AudioUnit. By default we use AudioUnit because this one contains a native echo canceler and Acoustic gain control. However, AudioUnit is under dev. and not so mature. If you experiment bad (outgoing) voice quality using AudioUnit then just switch to AudioQueue like this:
a) From xcode, right click on "ios-ngn-stack", select "Get info" then "Build" tab
b) scroll to "GCC x.y - Language" and double click on "Other C Flags" value
c) set -DHAVE_COREAUDIO_AUDIO_UNIT value to 0 and -DHAVE_COREAUDIO_AUDIO_QUEUE value to 1
d) Rebuild both "Doubango" and "ios-ngn-stack" targets
Et voilà

4) == Short presentation for developers ==
Right now the documentation is not ready yet but if you are already developing with "android-ngn-stack" you should not have any problem with "ios-ngn-stack" as we are using the same classes, functions, engine, philosophy, …
The best way to start programing with the NGN stack is to study the source code of "testAudioCall" application. In the coming days we will release the source code of iDoubs.

a) Including all header files
in order to have access to all functions of the framework, you must include the stack header file: 
#import "iOSNgnStack.h"

b) getting an instance of the engine and starting it
NgnEngine* mEngine = [[NgnEngine getInstance] retain]; // do not forget to call -release when you no longer need this instance
BOOL ok = [mEngine start];
staring the engine will start all underlying services (sip, configuration, contacts, …)

c) getting the configuration service and setting the user credentials
NgnBaseService<INgnConfigurationService>* mConfigurationService = [mEngine.configurationService retain]; // do not forget to call -release when you no longer need this instance
[mConfigurationService setStringWithKey: IDENTITY_IMPI andValue: @"johndoe"];
[mConfigurationService setStringWithKey: IDENTITY_IMPU andValue: @"sip:johndoe@doubango.org"];
[mConfigurationService setStringWithKey: IDENTITY_PASSWORD andValue: @"mysecret"];
[mConfigurationService setStringWithKey: NETWORK_REALM andValue: @"doubango.org"];
[mConfigurationService setStringWithKey: NETWORK_PCSCF_HOST andValue: @"192.168.0.1"];
[mConfigurationService setIntWithKey: NETWORK_PCSCF_PORT andValue: 5060];
[mConfigurationService setBoolWithKey: NETWORK_USE_EARLY_IMS andValue: TRUE];

d) observing registration state
// declare the selector like this:
-(void) onRegistrationEvent:(NSNotification*)notification {
	NgnRegistrationEventArgs* eargs = [notification object];
	switch (eargs.eventType) {
		case REGISTRATION_INPROGRESS:
		case UNREGISTRATION_INPROGRESS:
		case REGISTRATION_OK:
		case REGISTRATION_NOK:
		case UNREGISTRATION_OK:
		case UNREGISTRATION_NOK:
		default:
			break;
	}
}
// add the observer like this:
[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
// do not forget to remove the observer using -removeObserver when you no longer need it

e) observing audio/video call state
// declare the observer like this:
-(void) onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
    		case INVITE_EVENT_INPROGRESS:
    		case INVITE_EVENT_RINGING:
    		case INVITE_EVENT_EARLY_MEDIA:
    		case INVITE_EVENT_CONNECTED:
    		case INVITE_EVENT_TERMWAIT:
    		case INVITE_EVENT_TERMINATED:
   		case INVITE_EVENT_LOCAL_HOLD_OK:
    		case INVITE_EVENT_LOCAL_HOLD_NOK:
    		case INVITE_EVENT_LOCAL_RESUME_OK:
    		case INVITE_EVENT_LOCAL_RESUME_NOK:
    		case INVITE_EVENT_REMOTE_HOLD:
    		case INVITE_EVENT_REMOTE_RESUME:
			break;
	}
}
// add the observer like this:
[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
// do not forget to remove the observer using -removeObserver when you no longer need it

f) Getting an instance of the sip service
NgnBaseService<INgnSipService>* mSipService = [mEngine.sipService retain]; // do not forget to call -release when you no longer need this instance

g) registering (login)
BOOL ok = [mSipService registerIdentity];
registration progress will be notified to -onRegistrationEvent:
at anytime you can check the registration state using -getRegistrationState (<INgnSipService>)
unregistering : [mSipService unRegisterIdentity];

h) making audio call to @"007"
NgnAVSession* audioCall = [[NgnAVSession makeAudioCallWithRemoteParty: @"sip:007@doubango.org" 
		andSipStack: [mSipService getSipStack]] retain]; // do not forget to call -release when you no longer need this instance
call progress will be notified to -onInviteEvent:
when notification comes and -onInviteEvent is called, then you can compare the session ids to check if the notification is for YOUR "audioCall":
// if(eargs.sessionId == audioCall.id) it's mine
to hangup the call: [audioCall hangUpCall];
to hold the call: [audioCall holdCall];
to resume the call: [audioCall resumeCall];
to send dtmf (e.g. "1"): [audioCall sendDTMF: 1];
etc etc...
