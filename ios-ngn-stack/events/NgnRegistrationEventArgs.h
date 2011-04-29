#import <Foundation/Foundation.h>
#import "NgnEventArgs.h"

#define kNgnRegistrationEventArgs_Name @"NgnRegistrationEventArgs_Name"

typedef enum NgnRegistrationEventTypes_e {
	REGISTRATION_OK,
    REGISTRATION_NOK,
    REGISTRATION_INPROGRESS,
    UNREGISTRATION_OK,
    UNREGISTRATION_NOK,
    UNREGISTRATION_INPROGRESS
}
NgnRegistrationEventTypes_t;

@interface NgnRegistrationEventArgs : NgnEventArgs {
	long sessionId;
	NgnRegistrationEventTypes_t eventType;
	short sipCode;
	NSString* sipPhrase;
}

-(NgnRegistrationEventArgs*)initWithSessionId: (long)sessionId andEventType: (NgnRegistrationEventTypes_t)type andSipCode: (short)sipCode andSipPhrase: (NSString*)phrase;

@property(readonly) long sessionId;
@property(readonly) NgnRegistrationEventTypes_t eventType;
@property(readonly) short sipCode;
@property(readonly,retain) NSString* sipPhrase;

@end
