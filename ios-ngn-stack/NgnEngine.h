#import <Foundation/Foundation.h>

#import "services/impl/NgnBaseService.h"
#import "services/INgnSipService.h"
#import "services/INgnConfigurationService.h"

@interface NgnEngine : NSObject {
	BOOL mStarted;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
}

@property(readonly) NgnBaseService<INgnSipService>* sipService;
@property(readonly) NgnBaseService<INgnConfigurationService>* configurationService;

-(BOOL)start;
-(BOOL)stop;
-(NgnBaseService<INgnSipService>*)getSipService;
-(NgnBaseService<INgnConfigurationService>*)getConfigurationService;

+(void)initialize;
+(NgnEngine*) getInstance;

@end
