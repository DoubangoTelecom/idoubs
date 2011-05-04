#import "NgnInviteEventArgs.h"


@implementation NgnInviteEventArgs

@synthesize sessionId;
@synthesize eventType;
@synthesize mediaType;
@synthesize sipPhrase;

-(NgnInviteEventArgs*)initWithSessionId: (long)sId andEvenType: (NgnInviteEventTypes_t)eType andMediaType: (NgnMediaType_t)media andSipPhrase: (NSString*)phrase{
	if((self = [super init])){
		self->sessionId = sId;
		self->eventType = eType;
		self->mediaType = media;
        self->sipPhrase = [phrase retain];
	}
	return self;
}

-(void)dealloc{
	[sipPhrase release];
	
	[super dealloc];
}

@end
