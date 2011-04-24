#import <Foundation/Foundation.h>

#import "NgnBaseService.h"
#import "INgnSipService.h"

class NgnSipCallback;

@interface NgnSipService : NgnBaseService <INgnSipService>{
	NgnSipCallback* mSipCallback;
}

@end
