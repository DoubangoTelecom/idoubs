#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>

class ProxyPlugin;

@interface NgnProxyPlugin : NSObject {
@protected
	uint64_t mId;
	BOOL mValid;
	BOOL mStarted;
	BOOL mPaused;
	BOOL mPrepared;
	
	const ProxyPlugin* mPlugin;
}

@property(readonly,getter=getId) uint64_t id;
@property(readonly,getter=isValid) BOOL valid;
@property(readonly,getter=isStarted) BOOL started;
@property(readonly,getter=isPaused) BOOL paused;
@property(readonly,getter=isPrepared) BOOL prepared;

-(NgnProxyPlugin*) initWithId: (uint64_t)identifier andPlugin: (const ProxyPlugin*)plugin;

-(void)makeInvalidate;
-(BOOL)isValid;
-(BOOL)isStarted;
-(BOOL)isPaused;
-(BOOL)isPrepared;
-(uint64_t)getId;
-(NSNumber*)getIdAsNumber;

@end

#endif /* TARGET_OS_IPHONE */