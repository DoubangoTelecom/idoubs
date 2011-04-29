#import "NgnRegistrationEventArgs.h"

@implementation NgnRegistrationEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize sipCode;
@synthesize sipPhrase;

-(NgnRegistrationEventArgs*)initWithSessionId: (long)sId andEventType: (NgnRegistrationEventTypes_t)type andSipCode: (short)code andSipPhrase: (NSString*)phrase{
	if((self = [super init])){
		self->sessionId = sId;
        self->eventType = type;
        self->sipCode = code;
        self->sipPhrase = [phrase retain];
	}
	return self;
}

-(void)dealloc{
	[self->sipPhrase release];
	[super dealloc];
}

@end
