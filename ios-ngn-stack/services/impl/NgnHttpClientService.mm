#import "INgnHttpClientService.h"
#import "NgnHttpClientService.h"

#undef TAG
#define kTAG @"NgnHttpClientService///: "
#define TAG kTAG

@implementation NgnHttpClientService

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
