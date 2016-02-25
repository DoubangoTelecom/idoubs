

> # Introduction #
This is a short but useful developer's guide to help you starting to write VoIP applications for iOS (iPhone, iPod Touch and iPad) using our NGN (Next Generation Network) Stack. <br />
If you haven't already configured your development environment then please take a look at the [this page](http://code.google.com/p/idoubs/wiki/Building_iDoubs_v2_x) which explain how to build both the NGN Stack and the test VoIP client (**iDoubs v2.x**). In the next sections we'll consider that you have successfully built the NGN library. <br />

# Licensing #
iDoubs (all versions) and all materials (documents, Doubango Framework, NGN Stack, scripts ..) provided by us (Doubango Telecom) are free softwares licensing under the GNU GPLv3 license terms. As far as the commercial product using [iDoubs](http://code.google.com/p/idoubs/), the NGN Stack or [Doubango Framewok](http://doubango.org) isn't a **closed-source** software and is compatible with [GNU GPL v3.0](http://www.gnu.org/licenses/gpl.html) terms, there is no license violation. However, if your commercial product is a **closed-source** software and you want to keep it closed, then you should get a non-GPL license. <br /><br />
We can provide a non-GPL version of all components used in both [iDoubs](http://code.google.com/p/idoubs/) and [Doubango](http://doubango.org) except for [x264](http://www.videolan.org/developers/x264.html) library. <br /> An alternative to x264 could be PacketVideo's H.264 implementation which is released under Apache License.
Owners of [doubango](http://doubango.org) licenses can reuse part or whole
[iDoubs](http://code.google.com/p/idoubs/)'s source code whithout any restruction.<br />
For more information: [http://code.google.com/p/idoubs/wiki/Commercial\_License](http://code.google.com/p/idoubs/wiki/Commercial_License)


# Architecture #
  * <a href='http://www.doubango.org'>doubango</a> is an open source 3GPP IMS/LTE framework for both embedded and desktop systems. Doubango is developed and maintained by **Doubango Telecom**, a company based in Paris (France). The framework is written in ANSI-C to ease portability and has been carefully designed to efficiently work on embedded systems with limited memory and low computing power and to be extremely portable.
  * **ios-ngn-satck** is our NGN (Next Generation Network) stack written written in Objective-C as a wrapper around [Doubango](http://www.doubango.org) to speedup your development by providing high level API and utility functions.
  * **iDoubs** is our test VoIP client for iOS provided to you as **reference implementation**. This "test" application is fully-featured and could be considered as **one of the most advanced open source VoIP client for iOS**. If you don't believe me, then come share with us the NGN experience. **_Features_**: Audio Call, Video Call, Chat, Call log storage, Favorites, Content sharing, 3GPP SMS ...

## Header files ##
This is very important: In order to have access to all public functions provided by the NGN Stack you only have one file to include: **iOSNgnStack.h**. You **MUST** not include any other header file from the NGN stack into you project.<br />
Use **#import** instead of **#include** as shown below:
```
#import "iOSNgnStack.h"
```

## NGN Engine ##
The NGN engine is the higher level layer giving you access to all services. These services include:
  1. **NgnSipService**: This is the SIP/IMS service used to register to your server.
  1. **NgnConfigurationService**: This service is responsible for all tasks related to the configuration (credentials, preferences ...). The data stored using this service are persistent and will be written into the application's bundle.
  1. **NgnStorageService**: This service is an utility service used to store private data (e.g. favorites, call log ...) in a SQLite3 database named **NgnDataBase.db**.
  1. **NgnHistoryService**: This service is used to store and manage the call-log into the embedded database (**NgnDataBase.db**). This service uses **NgnStorageService** for all read/write operations involving the SQLite3 database.
  1. **NgnContactService**: This service is used as a wrapper around your native address book.
  1. **NgnHttpService**: This is the HTTP client service (To be implemented)
  1. **NgnNetworkService**: This is the network service (useless for now)
  1. **NgnNetworkService**: This service is used to play sounds (ringtone, ringback, alerts ...), route audio (speaker |-| earpiece), vibrate the phone ...

### Getting an instance of the NGN Engine ###
From anywhere in your code you can get an instance of the engine like this:
```
NgnEngine *engine = [NgnEngine getInstance];
```
This function will give you a unique instance of the engine. It doesn't matter how many times you call this function because it will always return the same instance. It's very important to use this function in order to create an instance of the engine. You **MUST** not create (alloc + init) the engine by yourself. Using this function will ensure that your code will not break when we introduce new features (e.g. support for multi-accounts).

### Starting the NGN Engine ###
Before starting to use the NGN engine you must start it at least one time. We recommend doing it in [– application:didFinishLaunchingWithOptions:](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html) function from your application delegate. You can do it like this:
```
BOOL succeed = [[NgnEngine getInstance] start]; // TRUE if succeed and FALSE otherwise
```
Starting the engine will start all underlaying services: **NgnSipService**, **NgnConfigurationService**, **NgnStorageService**, **NgnHistoryService** ...
if the **-start** function returns **YES** then this means that you are ready to use all services.

### Configuration Service ###
**Note**: You **MUST** start the NGN Engine before using any function from this service. For more information on how to start the NGN engine, please see above.
The configuration service (**NgnConfigurationService**) is used to store/retrieve the user preferences into/from the application bundle. For example, if you are using **iDoubs** and configured the client from the **Settings** page then you can retrieve the data from the configuration service.
  * For example, to retrieve the user's **Public Id** (a.k.a IMPU) you can do this:
```
NSString* publicId = [[NgnEngine getInstance].configurationService getStringWithKey:IDENTITY_IMPU];
```
The credentials stored using the **NgnConfigurationService** will be used by the **NgnSipService** in order to connect (and authenticate) to your SIP Server.
> #### Protocol definition ####
```
@protocol INgnConfigurationService <INgnBaseService>
-(NSString*)getStringWithKey: (NSString*)key;
-(int)getIntWithKey: (NSString*)key;
-(float)getFloatWithKey: (NSString*)key;
-(BOOL)getBoolWithKey: (NSString*)key;
-(void)setStringWithKey: (NSString*)key andValue:(NSString*)value;
-(void)setIntWithKey: (NSString*)key andValue:(int)value;
-(void)setFloatWithKey: (NSString*)key andValue:(float)value;
-(void)setBoolWithKey: (NSString*)key andValue:(BOOL)value;
@end
```

### SIP/IMS Service ###
**Note**: You **MUST** start the NGN Engine before using any function from this service. For more information on how to start the NGN engine, please see above.
The **NgnSipService** is used to register to your SIP/IMS Service. This service holds a unique instance of a SIP/IMS Stack.
> #### Protocol definition ####
```
@protocol INgnSipService <INgnBaseService>
-(NSString*)getDefaultIdentity;
-(void)setDefaultIdentity: (NSString*)identity;
-(NgnSipStack*)getSipStack;
-(BOOL)isRegistered;
-(ConnectionState_t)getRegistrationState;
-(int)getCodecs;
-(void)setCodecs: (int)codecs;
-(BOOL)stopStack;
-(BOOL)registerIdentity;
-(BOOL)unRegisterIdentity;
@end
```

#### Setting up your SIP/IMS credentials ####
Before trying to register to your SIP/IMS service you **MUST** set your credentials using the **NgnConfugurationService** like this:
```
// Your credentials
static const NSString* kProxyHost = @"192.168.0.1";
static const int kProxyPort = 5060;
static const NSString* kRealm = @"doubango.org";
static const NSString* kPassword = @"mysecret";
static const NSString* kPrivateIdentity = @"bob";
static const NSString* kPublicIdentity = @"sip:bob@doubango.org";
static const BOOL kEnableEarlyIMS = TRUE;

// Setting your credentials
[[NgnEngine getInstance] setStringWithKey: IDENTITY_IMPI andValue: kPrivateIdentity];
[[NgnEngine getInstance] setStringWithKey: IDENTITY_IMPU andValue: kPublicIdentity];
[[NgnEngine getInstance] setStringWithKey: IDENTITY_PASSWORD andValue: kPassword];
[[NgnEngine getInstance] setStringWithKey: NETWORK_REALM andValue: kRealm];
[[NgnEngine getInstance] setStringWithKey: NETWORK_PCSCF_HOST andValue:kProxyHost];
[[NgnEngine getInstance] setIntWithKey: NETWORK_PCSCF_PORT andValue: kProxyPort];
[[NgnEngine getInstance] setBoolWithKey: NETWORK_USE_EARLY_IMS andValue: kEnableEarlyIMS];
```

#### SIP registration and events handling ####
Once you have started the NGN engine and defined you SIP/credentials, you are ready to log-in to your SIP server. Before trying to register you should listen to the registration events in order to get notified when the registration state change.

To listen to the registration events:
```
// target function
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

// start listening
[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
```

To register to your server:
```
BOOL success = [[NgnEngine getInstance].sipService registerIdentity]; // Asynchronous function. 'YES' if request sent and 'NO'
```
**-registerIdentity** function will try to register the identity defined via the **NgnConfigurationService**.
Don't forget to use [- (void)removeObserver:(id)notificationObserver name:(NSString \*)notificationName object:(id)notificationSender](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/Reference/Reference.html) if you no longer need to listen to the registration events.
To get started we recommend taking a look at the **testRegistration** project.

#### Sending/Receiving IM ####
Here we consider that you have already started the NGN engine and successfully registered to your SIP/IMS server.

First, you should listen to events related to the SIP Pager Mode IM (SIP MESSAGE). To do this:
```
// target function
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
				NSLog(@"Incoming message from:%@\n with ctype:%@\n and content:%@",
				 from, contentType, content);
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
}


// start listening
[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
```

To send SIP Pager Mode IM (SIP MESSAGE):
```
ActionConfig* actionConfig = new ActionConfig();
if(actionConfig){
	// add some SIP headers       
	actionConfig->addHeader("Organization", "Doubango Telecom");
	actionConfig->addHeader("Subject", "testing iOS NGN Stack");
}
// Send UTF-8 message (Null-terminated string)
// Please use 'sendDataWithSipStack: andToUri: andData: data andContentType:' in order to send binary content
const NSString *kRemoteParty = @"sip:bob@doubango.org";
const NSString* kMessageBody = @"Hello world!";
NgnMessagingSession* imSession = [[NgnMessagingSession sendTextMessageWithSipStack: [[NgnEngine getInstance].sipService getSipStack] 
											andToUri: kRemoteParty											        
                                                                                       andMessage: kMessageBody
											andContentType: kContentTypePlainText
											andActionConfig: actionConfig
									   ] retain]; // Do not retain the session if you don't want it
// do whatever you want with the session
	if(actionConfig){
		delete actionConfig, actionConfig = tsk_null;
	}
      // Release the session
	[NgnMessagingSession releaseSession: &imSession];
```

Don't forget to use [- (void)removeObserver:(id)notificationObserver name:(NSString \*)notificationName object:(id)notificationSender](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/Reference/Reference.html) if you no longer need to listen to the messaging events.

To get started we recommend taking a look at the **testMessaging** project.

### Storage Service ###
**Note**: You **MUST** start the NGN Engine before using any function from this service. For more information on how to start the NGN engine, please see above.
The **NgnStorageService** is used to read/write date from/to the embedded SQLite3 database (**NgnDatabase.db**). For example, this service is used to store the 'favorites'. For the history events (call-log), please take a look at the **NgnHistoryService**.<br />
> #### Protocol definition ####
```
@protocol INgnStorageService <INgnBaseService>

#if TARGET_OS_IPHONE
-(sqlite3 *) database;
-(BOOL) execSQL: (NSString*)sqlQuery;
-(NSMutableDictionary*) favorites;
-(BOOL) addFavorite: (NgnFavorite*) favorite;
-(BOOL) deleteFavorite: (NgnFavorite*) favorite;
-(BOOL) deleteFavoriteWithId: (long long) id;
-(BOOL) clearFavorites;
#endif /* TARGET_OS_IPHONE */

@end
```

In order to get notified when the 'favorites' changes you must listen to these events like this:
```
// target function
-(void) onFavoritesEvent:(NSNotification*)notification{
	NgnFavoriteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case FAVORITE_ITEM_ADDED:			
		case HISTORY_EVENT_ITEM_MOVED:
		case HISTORY_EVENT_ITEM_UPDATED:
		case HISTORY_EVENT_ITEM_REMOVED:			
		case HISTORY_EVENT_RESET:
		default:
		{
			break;
		}
	}
}

// start listening
[[NSNotificationCenter defaultCenter]
			addObserver:self selector:@selector(onFavoritesEvent:) name:kNgnFavoriteEventArgs_Name object:nil];
```

Don't forget to use [- (void)removeObserver:(id)notificationObserver name:(NSString \*)notificationName object:(id)notificationSender](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/Reference/Reference.html) if you no longer need to listen to the 'favorites' events.


### History Service ###
**Note**: You **MUST** start the NGN Engine before using any function from this service. For more information on how to start the NGN engine, please see above.
This service is used to manage the call-log events. This service uses the **NgnStorageService** in order to write/read data to/from the embedded SQLite3 database.
> #### Protocol definition ####
```
@protocol INgnHistoryService <INgnBaseService>

-(BOOL) load;
-(BOOL) isLoading;
-(BOOL) addEvent: (NgnHistoryEvent*) event;
-(BOOL) updateEvent: (NgnHistoryEvent*) event;
-(BOOL) deleteEvent: (NgnHistoryEvent*) event;
-(BOOL) deleteEventAtIndex: (int) location;
-(BOOL) deleteEventWithId: (long long) eventId;
-(BOOL) deleteEvents: (NgnMediaType_t) mediaType;
-(BOOL) deleteEvents: (NgnMediaType_t) mediaType withRemoteParty: (NSString*)remoteParty;
-(BOOL) clear;
-(NgnHistoryEventDictionary*) events;

@end
```

In order to get notified when the 'call-log' changes you must listen to these events like this:
```
// target function
-(void) onHistoryEvent:(NSNotification*)notification{
	NgnHistoryEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case HISTORY_EVENT_ITEM_ADDED:
		case HISTORY_EVENT_ITEM_MOVED:
		case HISTORY_EVENT_ITEM_UPDATED:		
		case HISTORY_EVENT_ITEM_REMOVED:
		case HISTORY_EVENT_RESET:
		default:
		{
			break;
		}
	}
}

@end


// start listening
[[NSNotificationCenter defaultCenter]
		addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
```

Don't forget to use [- (void)removeObserver:(id)notificationObserver name:(NSString \*)notificationName object:(id)notificationSender](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/Reference/Reference.html) if you no longer need to listen to the 'call-log' events.

### Contact Service ###

### HTTP Service ###