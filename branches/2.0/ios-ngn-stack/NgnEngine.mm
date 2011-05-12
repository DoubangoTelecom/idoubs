#import "NgnEngine.h"

#import "NgnSipService.h"
#import "NgnConfigurationService.h"
#import "NgnContactService.h"
#import "NgnHttpClientService.h"
#import "NgnHistoryService.h"
#import "NgnSoundService.h"
#import "NgnNetworkService.h"
#import "NgnStorageService.h"

#if TARGET_OS_IPHONE
#	import "NgnProxyPluginMgr.h"
#endif

#undef TAG
#define kTAG @"NgnEngine///: "
#define TAG kTAG

static NgnEngine* sInstance = nil;
static BOOL sMediaLayerInitialized = NO;

@implementation NgnEngine(Private)

-(void)dummyCoCoaThread {
	NgnNSLog(TAG, @"dummyCoCoaThread()");
}

@end

@implementation NgnEngine

-(NgnEngine*)init{
	if((self = [super init])){
		[NgnEngine initialize];
	}
	return self;
}

-(void)dealloc{
	[self stop];
	
	[mSipService release];
	[mConfigurationService release];
	[mContactService release];
	
	[super dealloc];
}

-(BOOL)start{
	if(mStarted){
		return TRUE;
	}
	BOOL bSuccess = TRUE;
	
	/* http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSAutoreleasePool_Class/Reference/Reference.html
	 Note: If you are creating secondary threads using the POSIX thread APIs instead of NSThread objects, you cannot use Cocoa, including NSAutoreleasePool, unless Cocoa is in multithreading mode.
	 Cocoa enters multithreading mode only after detaching its first NSThread object.
	 To use Cocoa on secondary POSIX threads, your application must first detach at least one NSThread object, which can immediately exit.
	 You can test whether Cocoa is in multithreading mode with the NSThread class method isMultiThreaded.
	 */
	[NSThread detachNewThreadSelector:@selector(dummyCoCoaThread) toTarget:self withObject:nil];
	if([NSThread isMultiThreaded]){
		NgnNSLog(TAG, @"Working in multithreaded mode :)");
	}
	else{
		NgnNSLog(TAG, @"NOT working in multithreaded mode :(");
	}
	
	bSuccess &= [self.configurationService start];
	bSuccess &= [self.contactService start];
	bSuccess &= [self.sipService start];	
	bSuccess &= [self.httpClientService start];
	bSuccess &= [self.historyService start];
	bSuccess &= [self.soundService start];
	bSuccess &= [self.networkService start];
	bSuccess &= [self.storageService start];
	
	mStarted = TRUE;
	return bSuccess;
}

-(BOOL)stop{
	if(!mStarted){
		return TRUE;
	}
	
	BOOL bSuccess = TRUE;
	
	bSuccess &= [self.sipService stop];
	bSuccess &= [self.contactService stop];
	bSuccess &= [self.configurationService stop];
	bSuccess &= [self.httpClientService stop];
	bSuccess &= [self.historyService stop];
	bSuccess &= [self.soundService stop];
	bSuccess &= [self.networkService stop];
	bSuccess &= [self.storageService stop];
	
	mStarted = FALSE;
	return bSuccess;
}

-(NgnBaseService<INgnSipService>*)getSipService{
	if(mSipService == nil){
		mSipService = [[NgnSipService alloc] init];
	}
	return mSipService;
}

-(NgnBaseService<INgnConfigurationService>*)getConfigurationService{
	if(mConfigurationService == nil){
		mConfigurationService = [[NgnConfigurationService alloc] init];
	}
	return mConfigurationService;
}

-(NgnBaseService<INgnContactService>*)getContactService{
#if	TARGET_OS_IPHONE
	if(mContactService == nil){
		mContactService = [[NgnContactService alloc] init];
	}
	return mContactService;
#else
	return nil;
#endif
}

-(NgnBaseService<INgnHttpClientService>*) getHttpClientService{
	if(mHttpClientService == nil){
		mHttpClientService = [[NgnHttpClientService alloc] init];
	}
	return mHttpClientService;
}

-(NgnBaseService<INgnHistoryService>*)getHistoryService{
#if	TARGET_OS_IPHONE
	if(mHistoryService == nil){
		mHistoryService = [[NgnHistoryService alloc] init];
	}
	return mHistoryService;
#else
	return nil;
#endif
}

-(NgnBaseService<INgnSoundService>* )getSoundService{
	if(mSoundService == nil){
		mSoundService = [[NgnSoundService alloc] init];
	}
	return mSoundService;
}

-(NgnBaseService<INgnNetworkService>*)getNetworkService{
	if(mNetworkService == nil){
		mNetworkService = [[NgnNetworkService alloc] init];
	}
	return mNetworkService;
}

-(NgnBaseService<INgnStorageService>*)getStorageService{
	if(mStorageService == nil){
		mStorageService = [[NgnStorageService alloc] init];
	}
	return mStorageService;
}

+(void)initialize{
	if(!sMediaLayerInitialized){
#if TARGET_OS_IPHONE
		[NgnProxyPluginMgr initialize];
#endif
		sMediaLayerInitialized = YES;
	}
}

+(NgnEngine*) getInstance{
	if(sInstance == nil){
		sInstance = [[NgnEngine alloc] init];
	}
	return sInstance;
}

@end
