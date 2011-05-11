#import "NgnPhoneNumber.h"


@implementation NgnPhoneNumber

@synthesize number;
@synthesize description;


-(NgnPhoneNumber*) initWithNumber: (NSString*) _number andDescription: (NSString*) _desciption{
	if((self = [super init])){
		self->number = [_number retain];
		self->description = [_desciption retain];
	}
	return self;
}

-(void)dealloc{
	[self->number release];
	[self->description release];
	
	[super dealloc];
}

@end
