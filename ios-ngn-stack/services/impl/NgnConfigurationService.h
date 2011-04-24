#import <Foundation/Foundation.h>

#import "NgnBaseService.h"
#import "INgnConfigurationService.h"

@interface NgnConfigurationService : NgnBaseService<INgnConfigurationService> {
	NSUserDefaults* mPrefs;
}
@end
