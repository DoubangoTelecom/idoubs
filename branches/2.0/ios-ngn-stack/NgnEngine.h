#import <Foundation/Foundation.h>

#import "services/impl/NgnBaseService.h"

#import "services/INgnSipService.h"
#import "services/INgnConfigurationService.h"
#import "services/INgnContactService.h"

@interface NgnEngine : NSObject {
@protected
	BOOL mStarted;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	NgnBaseService<INgnContactService>* mContactService;
}

@property(readonly,getter=getSipService) NgnBaseService<INgnSipService>* sipService;
@property(readonly, getter=getConfigurationService) NgnBaseService<INgnConfigurationService>* configurationService;
@property(readonly, getter=getContactService) NgnBaseService<INgnContactService>* contactService;

-(BOOL)start;
-(BOOL)stop;
-(NgnBaseService<INgnSipService>*)getSipService;
-(NgnBaseService<INgnConfigurationService>*)getConfigurationService;
-(NgnBaseService<INgnContactService>*)getContactService;

+(void)initialize;
+(NgnEngine*) getInstance;

@end
