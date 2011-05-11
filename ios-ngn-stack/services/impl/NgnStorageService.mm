#import "NgnStorageService.h"

#undef TAG
#define kTAG @"NgnStorageService///: "
#define TAG kTAG

@implementation NgnStorageService

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
