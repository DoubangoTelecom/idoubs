#import <Foundation/Foundation.h>

#import "iOSNgnConfig.h"

#import "NgnBaseService.h"
#import "NgnSipPreferences.h"

#import "INgnSipService.h"
#import "INgnConfigurationService.h"

class _NgnSipCallback;
@class NgnRegistrationSession;

@interface NgnSipService : NgnBaseService <INgnSipService>{
	_NgnSipCallback* _mSipCallback;
	NgnRegistrationSession* sipRegSession;
	NgnSipPreferences* sipPreferences;
	NgnBaseService<INgnConfigurationService>*mConfigurationService;
	NgnSipStack* sipStack;
}

@property(readonly) NgnRegistrationSession* sipRegSession;
@property(readonly) NgnSipPreferences* sipPreferences;
@property(readonly) NgnSipStack* sipStack;

@end
