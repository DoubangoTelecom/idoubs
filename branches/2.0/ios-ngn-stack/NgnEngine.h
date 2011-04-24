#import <Foundation/Foundation.h>

#import "NgnBaseService.h"
#import "INgnSipService.h"
#import "INgnConfigurationService.h"

@interface NgnEngine : NSObject {
	BOOL mStarted;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
}

-(BOOL)start;
-(BOOL)stop;
-(NgnBaseService<INgnSipService>*)getSipService;
-(NgnBaseService<INgnConfigurationService>*)getConfigurationService;

+(void)initialize;

@end
