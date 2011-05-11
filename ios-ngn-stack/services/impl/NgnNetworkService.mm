#import "NgnNetworkService.h"

#undef TAG
#define kTAG @"NgnNetworkService///: "
#define TAG kTAG

@implementation NgnNetworkService

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	return YES;
}

@end
