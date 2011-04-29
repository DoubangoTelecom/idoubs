#import "NgnStackEventArgs.h"

@implementation NgnStackEventArgs

@synthesize eventType;
@synthesize phrase;

-(NgnStackEventArgs*)initWithEventType: (NgnStackEventTypes_t)_eventType andPhrase: (NSString*)_phrase{
	if((self = [super init])){
		self->eventType = _eventType;
        self->phrase = [_phrase retain];
	}
	return self;
}

-(void)dealloc{
	[self->phrase release];
	[super dealloc];
}

@end
