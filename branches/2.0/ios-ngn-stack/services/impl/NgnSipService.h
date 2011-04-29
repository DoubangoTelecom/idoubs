#import <Foundation/Foundation.h>

#import "iOSNgnConfig.h"

#import "NgnBaseService.h"
#import "NgnRegistrationSession.h"
#import "NgnSipPreferences.h"

#import "INgnSipService.h"
#import "INgnConfigurationService.h"

class _NgnSipCallback;

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
