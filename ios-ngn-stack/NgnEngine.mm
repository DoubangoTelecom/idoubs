#import "NgnEngine.h"

#import "NgnSipService.h"
#import "NgnConfigurationService.h"

static NgnEngine* sInstance = nil;

@implementation NgnEngine (Private)

+(NgnEngine*) getInstance{
	if(sInstance == nil){
		sInstance = [[NgnEngine alloc] init];
	}
	return sInstance;
}
@end

@implementation NgnEngine

-(NgnEngine*)init{
	if((self = [super init])){
	}
	return self;
}

-(void)dealloc{
	[mSipService release];
	[mConfigurationService release];
	[super dealloc];
}

-(BOOL)start{
	if(mStarted){
		return TRUE;
	}
	BOOL bSuccess = TRUE;
	
	bSuccess &= [[self getSipService] start];
	bSuccess &= [[self getConfigurationService] stop];
	
	mStarted = TRUE;
	return bSuccess;
}

-(BOOL)stop{
	if(!mStarted){
		return TRUE;
	}
	
	BOOL bSuccess = TRUE;
	
	bSuccess &= [[self getSipService] stop];
	bSuccess &= [[self getConfigurationService] stop];
	
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

+(void)initialize{
}

@end
