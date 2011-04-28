#import <Foundation/Foundation.h>

#import "NgnBaseService.h"
#import "INgnSipService.h"
#import "NgnRegistrationSession.h"

class _NgnSipCallback;

@interface NgnSipService : NgnBaseService <INgnSipService>{
	_NgnSipCallback* _mSipCallback;
	NgnRegistrationSession* mRegistrationSession;
}

@end
