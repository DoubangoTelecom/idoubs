#import "NgnSipPreferences.h"
#import "NgnStringUtils.h"

@implementation NgnSipPreferences

@synthesize presence;
@synthesize xcap;
@synthesize presenceRLS;
@synthesize presencePub;
@synthesize presenceSub;
@synthesize mwi;
@synthesize impi;
@synthesize impu;
@synthesize pcscfHost;
@synthesize pcscfPort;
@synthesize transport;
@synthesize ipVersion;
@synthesize ipsecSecAgree;
@synthesize localIp;
@synthesize hackAoR;

-(NSString*)realm{
	return self->realm;
}

-(void) setRealm:(NSString*)value {
	[self->realm release], self->realm = nil;
	if([NgnStringUtils contains:value subString:@":"]){
		self->realm = [[@"sip:" stringByAppendingString:value] retain];
	}
	else{
		self->realm = [value retain];
	}
}

-(void)dealloc{
	[self->impi dealloc];
	[self->impu dealloc];
	[self->realm dealloc];
	[self->pcscfHost dealloc];
	[self->transport dealloc];
	[self->ipVersion dealloc];
	[self->localIp dealloc];
	[super dealloc];
}

@end
