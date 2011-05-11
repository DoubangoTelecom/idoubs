#import "NgnSoundService.h"

#undef TAG
#define kTAG @"NgnSoundService///: "
#define TAG kTAG

@implementation NgnSoundService

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
