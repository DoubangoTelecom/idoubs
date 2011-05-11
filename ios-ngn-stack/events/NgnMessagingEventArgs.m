#import "NgnMessagingEventArgs.h"


@implementation NgnMessagingEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize sipPhrase;
@synthesize payload;

-(NgnMessagingEventArgs*)initWithSessionId: (long)_sessionId andEventType: (NgnMessagingEventTypes_t)_eventType andPhrase: (NSString*)_phrase andPayload: (NSData*)_payload{
	if((self = [super init])){
		self->sessionId = _sessionId;
		self->eventType = _eventType;
		self->sipPhrase = [_phrase retain];
		self->payload = [_payload retain];
	}
	
	return self;
}

-(void)dealloc{
	[self->sipPhrase release];
	[self->payload release];
	
	[super dealloc];
}

@end
