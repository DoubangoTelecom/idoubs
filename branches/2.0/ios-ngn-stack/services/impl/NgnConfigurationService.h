#import <Foundation/Foundation.h>

#import "iOSNgnConfig.h"
#import "services/impl/NgnBaseService.h"
#import "services/INgnConfigurationService.h"

@interface NgnConfigurationService : NgnBaseService<INgnConfigurationService> {
	NSUserDefaults* mPrefs;
}
@end
