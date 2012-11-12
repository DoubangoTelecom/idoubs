/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
#if TARGET_OS_IPHONE
#	import "iOSNgnConfig.h"
#elif TARGET_OS_MAC
#	import "OSXNgnConfig.h"
#endif

#import "NgnProxyVideoConsumer.h"

#import "ProxyConsumer.h"

#undef TAG
#define kTAG @"NgnProxyVideoConsumer///: "
#define TAG kTAG

#define kDefaultVideoWidth		176
#define kDefaultVideoHeight		144
#define kDefaultVideoFrameRate	15

@interface NgnProxyVideoConsumer(Private)
-(int)drawFrameOnMainThread;
-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps;
-(int) start;
-(int) bufferCopiedWithSize:(unsigned) copiedSize andAvaileSize: (unsigned) availableSize;
-(int) consumeFrame: (const ProxyVideoFrame*) _frame;
-(int) pause;
-(int) stop;
-(int) resizeBufferWithWidth:(int)width andHeight: (int)height;
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
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mConsumer bufferCopiedWithSize: nCopiedSize andAvaileSize: nAvailableSize];
		[pool release];
		return ret;
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
		mWidth = kDefaultVideoWidth;
		mHeight = kDefaultVideoHeight;
		mFps = kDefaultVideoFrameRate;
#if !TARGET_OS_IPHONE
		mBitmapContext = nil;
#endif
	}
	return self;
}

#if TARGET_OS_IPHONE
-(void) setDisplay: (iOSGLView*)display{
	@synchronized(self){
		[mDisplay release];
		mDisplay = [display retain];
	}
}
#elif TARGET_OS_MAC
-(void) setDisplay: (NSObject<NgnVideoView>*)display{
	@synchronized(self){		
		[mDisplay release];
		mDisplay = [display retain];
	}
}
#endif

-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps{
	NgnNSLog(TAG, @"prepareWithWidth(%i,%i,%i)", width, height, fps);
	if(!_mConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -1;
	}
    
	// resize buffer
	if([self resizeBufferWithWidth: width andHeight: height]){
		TSK_DEBUG_ERROR("resizeBitmapContextWithWidth:%i andHeight:%i has failed", width, height);
		return -1;
	}
	
	// mWidth and and mHeight already updated by resizeBitmap.... 
	mFps = fps;
    
#if TARGET_OS_IPHONE
    if(mDisplay){
        [mDisplay setFps:mFps]; // OpenGL framerate
    }
#elif TARGET_OS_MAC
#endif
    
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
    
    // size comparaison is detect: chroma change or width/height change
    // width/height comparaison is to detect: (width,heigh) swapping which would keep size unchanged
    unsigned _frameWidth = const_cast<ProxyVideoConsumer *>(_mConsumer)->getDisplayWidth();
    unsigned _frameHeight = const_cast<ProxyVideoConsumer *>(_mConsumer)->getDisplayHeight();
    if(_mBufferSize != availableSize || (mWidth != _frameWidth) || (mHeight != _frameHeight)){
		NgnNSLog(TAG, "bufferCopiedWithSize(copiedSize=%u,availableSize=%u)", copiedSize, availableSize);
		if(_frameWidth<=0 || _frameHeight<=0){
			NgnNSLog(TAG,"nCopiedSize=%u and newWidth=%u and newHeight=%u", copiedSize, _frameWidth, _frameHeight);
			return -1;
		}
		// resize buffer
		if([self resizeBufferWithWidth:_frameWidth andHeight: _frameHeight]){
			TSK_DEBUG_ERROR("resizeBufferWithWidth:%i andHeight:%i has failed", _frameWidth, _frameHeight);
			return -1;
		}
		// Draw the picture next time
		return 0;
	}
	
#if TARGET_OS_IPHONE
    if(mDisplay) [mDisplay setBufferYUV:_mBufferPtr andWidth:mWidth andHeight:mHeight];
     return 0;
#else
    if(mBitmapContext && mDisplay){
        CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
        [mDisplay setCurrentImage:imageRef];
        CGImageRelease(imageRef);
    }
#endif
    return 0;
}

-(int) consumeFrame: (const ProxyVideoFrame*) _frame{
	if(!mValid || !_mBufferPtr || !_mBufferSize){
		TSK_DEBUG_ERROR("Invalid state");
		return -1;
	}
	if(_mBufferPtr && mDisplay){
		memcpy(_mBufferPtr, _frame->getBufferPtr(), TSK_MIN(_frame->getBufferSize(), _mBufferSize));
		
#if TARGET_OS_IPHONE
        [mDisplay setBufferYUV:_mBufferPtr andWidth:mWidth andHeight:mHeight];
#elif TARGET_OS_MAC
        if(mBitmapContext){
            CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
            [mDisplay setCurrentImage:imageRef];
            CGImageRelease(imageRef);
        }
#endif
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

-(int) resizeBufferWithWidth:(int)width andHeight: (int)height{
	if(!_mConsumer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -1;
	}
	int ret = 0;
	@synchronized(self){
		// realloc the buffer
#if TARGET_OS_IPHONE
        unsigned newBufferSize = (width * height * 3) >> 1; // NV12
#elif TARGET_OS_MAC
		unsigned newBufferSize = (width * height) << 2; // RGB32
#endif
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
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
        // release context
		CGContextRelease(mBitmapContext), mBitmapContext = nil;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		mBitmapContext = CGBitmapContextCreate(_mBufferPtr, width, height, 8, width * 4, colorSpace, 
											   kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
		CGColorSpaceRelease(colorSpace);
#endif
	}
	
	return ret;
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
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
	CGContextRelease(mBitmapContext), mBitmapContext = nil;
#endif
	
	[mDisplay release];
	
	[super dealloc];
}

@end

