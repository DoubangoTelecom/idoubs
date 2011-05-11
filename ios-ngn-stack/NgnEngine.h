#import <Foundation/Foundation.h>

#import "services/impl/NgnBaseService.h"

#import "services/INgnSipService.h"
#import "services/INgnConfigurationService.h"
#import "services/INgnContactService.h"
#import "services/INgnHttpClientService.h"
#import "services/INgnHistoryService.h"
#import "services/INgnSoundService.h"
#import "services/INgnNetworkService.h"
#import "services/INgnStorageService.h"

@interface NgnEngine : NSObject {
@protected
	BOOL mStarted;
	NgnBaseService<INgnSipService>* mSipService;
	NgnBaseService<INgnConfigurationService>* mConfigurationService;
	NgnBaseService<INgnContactService>* mContactService;
	NgnBaseService<INgnHttpClientService>* mHttpClientService;
	NgnBaseService<INgnHistoryService>* mHistoryService;
	NgnBaseService<INgnSoundService>* mSoundService;
	NgnBaseService<INgnNetworkService>* mNetworkService;
	NgnBaseService<INgnStorageService>* mStorageService;
}

@property(readonly,getter=getSipService) NgnBaseService<INgnSipService>* sipService;
@property(readonly, getter=getConfigurationService) NgnBaseService<INgnConfigurationService>* configurationService;
@property(readonly, getter=getContactService) NgnBaseService<INgnContactService>* contactService;
@property(readonly, getter=getHttpClientService) NgnBaseService<INgnHttpClientService>* httpClientService;
@property(readonly, getter=getHistoryService) NgnBaseService<INgnHistoryService>* historyService;
@property(readonly, getter=getSoundService) NgnBaseService<INgnSoundService>* soundService;
@property(readonly, getter=getNetworkService) NgnBaseService<INgnNetworkService>* networkService;
@property(readonly, getter=getStorageService) NgnBaseService<INgnStorageService>* storageService;

-(BOOL)start;
-(BOOL)stop;
-(NgnBaseService<INgnSipService>*)getSipService;
-(NgnBaseService<INgnConfigurationService>*)getConfigurationService;
-(NgnBaseService<INgnContactService>*)getContactService;
-(NgnBaseService<INgnHttpClientService>*) getHttpClientService;
-(NgnBaseService<INgnHistoryService>*)getHistoryService;
-(NgnBaseService<INgnSoundService>* )getSoundService;
-(NgnBaseService<INgnNetworkService>*)getNetworkService;
-(NgnBaseService<INgnStorageService>*)getStorageService;

+(void)initialize;
+(NgnEngine*) getInstance;

@end
