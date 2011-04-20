#import <Foundation/Foundation.h>
#import "NgnEventArgs.h"

#define kNgnRegistrationEventArgs_Name = @"NgnRegistrationEventArgs_Name";

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
	long mSessionId;
	NgnRegistrationEventTypes_t mType;
	short mSipCode;
	NSString* mPhrase;
}

-(NgnRegistrationEventArgs*)initWithId: (long)sessionId andType: (NgnRegistrationEventTypes_t)type andSipCode: (short)sipCode andPhrase: (NSString*)phrase;
-(long)getSessionId;
-(NgnRegistrationEventTypes_t)getEventType;
-(short)getSipCode;
-(NSString*)getPhrase;

@end
