#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "NgnProxyPlugin.h"

class ProxyVideoConsumer;
class _NgnProxyVideoConsumerCallback;

@interface NgnProxyVideoConsumer : NgnProxyPlugin {
	_NgnProxyVideoConsumerCallback* _mCallback;
	const ProxyVideoConsumer * _mConsumer;
	
	uint8_t* _mBufferPtr;
	size_t _mBufferSize;
	
	int mWidth;
	int mHeight;
	int mFps;
	
	UIImageView* mDisplay;
	CGContextRef mBitmapContext;
}

-(NgnProxyVideoConsumer*) initWithId: (uint64_t)identifier andConsumer:(const ProxyVideoConsumer *)_consumer;
-(void) setDisplay: (UIImageView*)display;

@end

#endif /* TARGET_OS_IPHONE */
