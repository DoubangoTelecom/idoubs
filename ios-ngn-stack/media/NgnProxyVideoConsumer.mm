#if TARGET_OS_IPHONE

#import "NgnProxyVideoConsumer.h"
#import "iOSNgnConfig.h"

#import "ProxyConsumer.h"

#undef TAG
#define kTAG @"NgnProxyVideoConsumer///: "
#define TAG kTAG

#define kDefaultVideoWidth		176
#define kDefaultVideoHeight		144
#define kDefaultVideoFrameRate	15

@interface NgnProxyVideoConsumer(Private)
-(int)drawFrame;
-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps;
-(int) start;
-(int) bufferCopiedWithSize:(unsigned) copiedSize andAvaileSize: (unsigned) availableSize;
-(int) consumeFrame: (const ProxyVideoFrame*) _frame;
-(int) pause;
-(int) stop;
-(int) resizeBitmapContextWithWidth:(int)width andHeight: (int)height;
@end

//
//	C++ callback
//
class _NgnProxyVideoConsumerCallback : public ProxyVideoConsumerCallback
{
public:
	_NgnProxyVideoConsumerCallback(NgnProxyVideoConsumer* consumer){
		mConsumer = [consumer retain];
	}
	
	virtual ~_NgnProxyVideoConsumerCallback(){
		[mConsumer release];
	}
	
	int prepare(int nWidth, int nHeight, int nFps) { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mConsumer prepareWithWidth: nWidth andHeight: nHeight andFps: nFps];
		[pool release];
		return ret;
	}
	
	int consume(const ProxyVideoFrame* _frame) {
		if(_frame){
			return [mConsumer consumeFrame: _frame];
		}
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1; 
	}
	
	int bufferCopied(unsigned nCopiedSize, unsigned nAvailableSize) { 
		return [mConsumer bufferCopiedWithSize: nCopiedSize andAvaileSize: nAvailableSize]; 
	}
	
	int start() { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mConsumer start]; 
		[pool release];
		return ret;
	}
	
	int pause() { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mConsumer pause]; 
		[pool release];
		return ret;
	}
	
	int stop() { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mConsumer stop]; 
		[pool release];
		return ret;
	}
	
private:
	NgnProxyVideoConsumer* mConsumer;
};


//
//	Video Consumer
//

@implementation NgnProxyVideoConsumer

-(NgnProxyVideoConsumer*) initWithId: (uint64_t)identifier andConsumer:(const ProxyVideoConsumer *)_consumer{
	if((self = (NgnProxyVideoConsumer*)[super initWithId: identifier andPlugin: _consumer])){
        _mConsumer = _consumer;
        _mCallback = new _NgnProxyVideoConsumerCallback(self);
		if(_mConsumer){
			const_cast<ProxyVideoConsumer*>(_mConsumer)->setCallback(_mCallback);
		}
		
		_mBufferPtr = tsk_null, _mBufferPtr = tsk_null;
		mBitmapContext = nil;
		mWidth = kDefaultVideoWidth;
		mHeight = kDefaultVideoHeight;
		mFps = kDefaultVideoFrameRate;
	}
	return self;
}

-(void) setDisplay: (UIImageView*)display{
	@synchronized(self){
		[mDisplay release];
		mDisplay = [display retain];
	}
}

-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps{
	NgnNSLog(TAG, @"prepareWithWidth(%i,%i,%i)", width, height, fps);
	if(!_mConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -1;
	}
	
	// resize buffer
	if([self resizeBitmapContextWithWidth: width andHeight: height]){
		TSK_DEBUG_ERROR("resizeBitmapContextWithWidth:%i andHeight:%i has failed", width, height);
		return -1;
	}
	
	// mWidth and and mHeight already updated by resizeBitmap.... 
	mFps = fps;
	mPrepared = YES;
	return 0;
}

-(int) start{
	NgnNSLog(TAG, "start()");
	mStarted = true;
	return 0;
}

-(int) bufferCopiedWithSize:(unsigned) copiedSize andAvaileSize: (unsigned) availableSize{	
	if(!mValid || !_mConsumer){
		NgnNSLog(TAG, "Invalid state");
		return -1;
	}
	
	// resize the buffer
	if(_mBufferSize != availableSize){
		NgnNSLog(TAG, "bufferCopiedWithSize(copiedSize=%u,availableSize=%u)", copiedSize, availableSize);
		unsigned _newWidth = const_cast<ProxyVideoConsumer *>(_mConsumer)->getDisplayWidth();
		unsigned _newHeight = const_cast<ProxyVideoConsumer *>(_mConsumer)->getDisplayHeight();
		if(_newWidth<=0 || _newHeight<=0){
			NgnNSLog(TAG,"nCopiedSize=%u and newWidth=%u and newHeight=%u", copiedSize, _newWidth, _newHeight);
			return -1;
		}
		// resize the bitmap context
		if([self resizeBitmapContextWithWidth: _newWidth andHeight: _newHeight]){
			TSK_DEBUG_ERROR("resizeBitmapContextWithWidth:%i andHeight:%i has failed", _newWidth, _newHeight);
			return -1;
		}
		
		// Draw the picture next time
		return 0;
	}
	
	return [self drawFrame];
}

-(int) consumeFrame: (const ProxyVideoFrame*) _frame{
	if(!mValid || !_mBufferPtr || !_mBufferSize){
		TSK_DEBUG_ERROR("Invalid state");
		return -1;
	}
	if(_mBufferPtr){
		memcpy(_mBufferPtr, _frame->fastGetContent(), TSK_MIN(_frame->fastGetSize(), _mBufferSize));
		return [self drawFrame];
	}
	return 0;
}

-(int) pause{
	NgnNSLog(TAG, "pause()");
	mPaused = YES;
	return 0;
}

-(int) stop{
	NgnNSLog(TAG, "stop()");
	mStarted = NO;
	return 0;
}

-(int) resizeBitmapContextWithWidth:(int)width andHeight: (int)height{
	if(!_mConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -1;
	}
	@synchronized(self){
		// release context
		CGContextRelease(mBitmapContext), mBitmapContext = nil;
	
		// realloc the buffer
		unsigned newBufferSize = width * height * 4;
		if(!(_mBufferPtr = (uint8_t*)tsk_realloc(_mBufferPtr, newBufferSize))){
			TSK_DEBUG_ERROR("Failed to realloc buffer with size=%u", newBufferSize);
			_mBufferSize = 0;
			return -1;
		}
		_mBufferSize = newBufferSize;
		// set buffer and request for "bufferCopied()" callback instead of "consume()"
		const_cast<ProxyVideoConsumer*>(_mConsumer)->setConsumeBuffer(_mBufferPtr, _mBufferSize);
	
	
		mWidth = width;
		mHeight = height;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		mBitmapContext = CGBitmapContextCreate(_mBufferPtr, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
		CGColorSpaceRelease(colorSpace);
	
		return 0;
	}
}

-(void)drawVideoFrameOnMainThread:(id)arg{
	@synchronized(self){
		CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
		UIImage *image = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);
		
		mDisplay.image =  image;
	}
}

-(int)drawFrame{
	@synchronized(self){
		if(mBitmapContext && mDisplay){
			[self performSelectorOnMainThread:@selector(drawVideoFrameOnMainThread:) withObject:nil waitUntilDone:NO];
		}
	}
	return 0;
}

-(void)makeInvalidate{
	[super makeInvalidate];
	if(_mConsumer){
		const_cast<ProxyVideoConsumer*>(_mConsumer)->setCallback(tsk_null);
	}
	if(_mCallback){
		delete _mCallback, _mCallback = tsk_null;
	}
}

-(void)dealloc{
	if(_mCallback){
		delete _mCallback, _mCallback = tsk_null;
	}
	_mConsumer = tsk_null; // you're not the owner
	TSK_FREE(_mBufferPtr);
	CGContextRelease(mBitmapContext), mBitmapContext = nil;
	
	[mDisplay release];
	[super dealloc];
}

@end

#endif /* TARGET_OS_IPHONE */
