#import <Foundation/Foundation.h>

#import "events/NgnEventArgs.h"

typedef enum NgnMessagingEventTypes_e {
	MESSAGING_EVENT_CONNECTING,
	MESSAGING_EVENT_CONNECTED,
	MESSAGING_EVENT_TERMINATING,
	MESSAGING_EVENT_TERMINATED,
	
	MESSAGING_EVENT_INCOMING,
    MESSAGING_EVENT_OUTGOING,
    MESSAGING_EVENT_SUCCESS,
    MESSAGING_EVENT_FAILURE
}
NgnMessagingEventTypes_t;

#define kNgnMessagingEventArgs_Name @"NgnMessagingEventArgs_Name"

#define kExtraMessagingEventArgsCode @"code"
#define kExtraMessagingEventArgsFrom @"from"
#define kExtraMessagingEventArgsDate @"date"
#define kExtraMessagingEventArgsContentType @"contentType"

@interface NgnMessagingEventArgs : NgnEventArgs {
	long sessionId;
	NgnMessagingEventTypes_t eventType;
    NSString* sipPhrase;
    NSData* payload;
}

@property(readonly) long sessionId;
@property(readonly) NgnMessagingEventTypes_t eventType;
@property(readonly) NSString* sipPhrase;
@property(readonly) NSData* payload;

-(NgnMessagingEventArgs*)initWithSessionId: (long)sessionId andEventType: (NgnMessagingEventTypes_t)eventType andPhrase: (NSString*)phrase andPayload: (NSData*)payload;

@end

