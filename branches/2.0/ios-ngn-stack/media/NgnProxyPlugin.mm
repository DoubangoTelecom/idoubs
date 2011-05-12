#if TARGET_OS_IPHONE

#import "NgnProxyPlugin.h"

#import "ProxyPluginMgr.h"

@implementation NgnProxyPlugin

-(NgnProxyPlugin*) initWithId: (uint64_t)identifier andPlugin: (const ProxyPlugin*)plugin{
	if((self = [super init])){
		mId = identifier;
		mPlugin = plugin;
		mValid = true;
	}
	return self;
}

-(void)makeInvalidate{
	mValid = NO;
}

-(BOOL)isValid{
	return mValid;
}

-(BOOL)isStarted{
	return mStarted;
}

-(BOOL)isPaused{
	return mPaused;
}

-(BOOL)isPrepared{
	return mPrepared;
}

-(uint64_t)getId{
	return mId;
}

-(NSNumber*)getIdAsNumber{
	return [NSNumber numberWithLong: mId];
}

-(void)dealloc{
	mPlugin = tsk_null; // you're not the owner of this object (this why it's 'const')
	
	[super dealloc];
}

@end

#endif /* TARGET_OS_IPHONE */
