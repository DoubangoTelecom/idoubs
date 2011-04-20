#import "NgnRegistrationEventArgs.h"

@implementation NgnRegistrationEventArgs

-(NgnRegistrationEventArgs*)initWithId: (long)sessionId andType: (NgnRegistrationEventTypes_t)type andSipCode: (short)sipCode andPhrase: (NSString*)phrase{
	self = [super init];
	if(self){
		mSessionId = sessionId;
        mType = type;
        mSipCode = sipCode;
        mPhrase = [phrase retain];
	}
	return self;
}

-(void)dealloc{
	[mPhrase release];
	[super dealloc];
}

-(long)getSessionId{
	return mSessionId;
}

-(NgnRegistrationEventTypes_t)getEventType{
	return mType;
}

-(short)getSipCode{
	return mSipCode;
}

-(NSString*)getPhrase{
	return mPhrase;
}

@end
