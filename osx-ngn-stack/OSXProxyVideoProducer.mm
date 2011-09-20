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
#if TARGET_OS_MAC

#import "OSXProxyVideoProducer.h"

#import "OSXNgnConfig.h"

#import "ProxyProducer.h"

#undef TAG
#define kTAG @"OSXProxyVideoProducer///: "
#define TAG kTAG

#define kDefaultVideoWidth		352
#define kDefaultVideoHeight		288
#define kDefaultVideoFrameRate	15

#define BLANK_PACKETS_TO_SEND   3

static uint8_t kBlankPacketBuffer[(1920*1080*3)>>1] = { 0 };

@interface NgnProxyVideoProducer(Private)
-(int) prepareWithWidth:(int)width andHeight:(int)height andFps:(int) fps;
-(int) start;
-(int) pause;
-(int) stop;
@end


//
// private implementation
//

@interface NgnProxyVideoProducer (VideoCapture)
- (void)startVideoCapture;
- (void)stopVideoCapture;
- (void)startPreview;
- (void)stopPreview;
- (void)startBlankPacketsTimer;
- (void)stopBlankPacketsTimer;
- (void)timerBlankPacketsTick:(NSTimer*)timer;
@end

@implementation NgnProxyVideoProducer (VideoCapture)

- (void)startVideoCapture
{
	BOOL success;
	NSError *error = nil;
	
	NgnNSLog(TAG,@"Starting Video stream");
	if(mCaptureDevice || mCaptureSession){
		NgnNSLog(TAG,@"Already capturing");
		return;
	}
	
	mCaptureDevice = [[QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo] retain];
	if(!mCaptureDevice){
		NgnNSLog(TAG,@"Failed to get valide capture device");
		return;
	}
	
	success = [mCaptureDevice open:&error];
    if(!success) {
		 NgnNSLog(TAG,@"Failed to open video device(QTMediaTypeVideo): %@", error);
		[mCaptureDevice release];
		mCaptureDevice = nil;
		
		if((mCaptureDevice = [[QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed] retain])){
			success	= [mCaptureDevice open:&error];
			if(!success) {
				[mCaptureDevice release];
				mCaptureDevice = nil;
				return;
			}
		}
    }
	
    QTCaptureDeviceInput *videoInput = [[QTCaptureDeviceInput alloc] initWithDevice:mCaptureDevice];
    if (!videoInput){
        NgnNSLog(TAG,@"Failed to create video input: %@", error);
		[mCaptureDevice release];
		mCaptureDevice = nil;
        return;
    }
	
	mCaptureSession = [[QTCaptureSession alloc] init];
	success = [mCaptureSession addInput:videoInput error:&error];
    if(!success) {
		NgnNSLog(TAG,@"Failed to add video input: %@", error);
		[mCaptureDevice release];
		mCaptureDevice = nil;
		if(mCaptureSession){
			[mCaptureSession release];
			mCaptureSession = nil;
		}
		return;
    }
	
	QTCaptureDecompressedVideoOutput *decompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
	[decompressedVideoOutput setAutomaticallyDropsLateVideoFrames:YES];
	[decompressedVideoOutput setMinimumVideoFrameInterval:(1.0f/(double)mFps)];
	
	NSArray *formats = [NSArray arrayWithObjects:
						 [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8Planar],
						 [NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8],
						 [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB],
						 [NSNumber numberWithUnsignedInt:kCVPixelFormatType_24RGB],						 
						 nil];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              formats, kCVPixelBufferPixelFormatTypeKey,
							  [NSNumber numberWithInt:mWidth], (id)kCVPixelBufferWidthKey,
							  [NSNumber numberWithInt:mHeight], (id)kCVPixelBufferHeightKey,						  
							  
							  nil];
	[decompressedVideoOutput setPixelBufferAttributes:attributes];
	[decompressedVideoOutput setDelegate:self];
	success = [mCaptureSession addOutput:decompressedVideoOutput error:&error];
	if (!success){
        NgnNSLog(TAG,@"Failed to add video output: %@", error);
        return;
    }
	[decompressedVideoOutput release];
	
	mFirstFrame = YES;
	
	if([NSThread currentThread] != [NSThread mainThread]){// from Doubango worker thread?
		[self performSelectorOnMainThread:@selector(startPreview) withObject:nil waitUntilDone:YES];
	}
	else {
		[self startPreview];
	}
	
	NgnNSLog(TAG, @"Video capture started");
}

- (void)stopVideoCapture
{
	if(mCaptureSession){
		[mCaptureSession stopRunning];
		[mCaptureSession release], mCaptureSession = nil;
		NgnNSLog(TAG,@"Video capture stopped");
	}
	[mCaptureDevice release], mCaptureDevice = nil;
	
	if([NSThread currentThread] != [NSThread mainThread]){ // From Doubango worker thread?
		[self performSelectorOnMainThread:@selector(stopPreview) withObject:nil waitUntilDone:YES];
	}
	else {
		[self stopPreview];
	}
}

- (void)startPreview
{
	if(mCaptureSession && mStarted){
		if(mPreview){
			[mPreview setCaptureSession:mCaptureSession];
		}
		if(![mCaptureSession isRunning]){
			[mCaptureSession startRunning];
		}
	}
}

- (void)stopPreview
{
	if(mCaptureSession){
		if([mCaptureSession isRunning]){
			[mCaptureSession stopRunning];
		}
	}
}

- (void)startBlankPacketsTimer
{
	if(!mTimerBlankPackets){
		mBlankPacketsSent = 0;
		mTimerBlankPackets = [NSTimer scheduledTimerWithTimeInterval:0.2
															  target:self
															selector:@selector(timerBlankPacketsTick:)
															userInfo:nil
															 repeats:YES];
	}
}

- (void)stopBlankPacketsTimer
{
	if(mTimerBlankPackets){
		[mTimerBlankPackets invalidate], mTimerBlankPackets = nil;
	}
}

- (void)timerBlankPacketsTick:(NSTimer*)timer
{
	tmedia_producer_t *_producer;
	if((_producer = (tmedia_producer_t *)tsk_object_ref((void*)_mProducer->getWrappedPlugin()))){
		float buffer_size = 0.f;
		switch (TMEDIA_PRODUCER(_producer)->video.chroma) {
			case tmedia_chroma_nv12:
			case tmedia_chroma_yuv420p:
				buffer_size = (mWidth * mHeight * 3)>>1;
				break;
			case tmedia_chroma_uyvy422:
				buffer_size = (mWidth * mHeight)<<1;
				break;
			case tmedia_chroma_rgb24:
				buffer_size = (mWidth * mHeight) * 3;
				break;
			case tmedia_chroma_rgb32:
			default:
				buffer_size = (mWidth * mHeight)<<2;
				break;
		}
		if(buffer_size<sizeof(kBlankPacketBuffer))
		{
			NSLog(@"Sending Blank packet number %d", mBlankPacketsSent);
			if(_producer->enc_cb.callback){
				dispatch_sync(_mSenderQueue, ^{
					tsk_mutex_lock(_mSenderMutex);
					_producer->enc_cb.callback(_producer->enc_cb.callback_data, kBlankPacketBuffer, buffer_size);
					tsk_mutex_unlock(_mSenderMutex);
				});
			}
		}
		else {
			TSK_DEBUG_ERROR("buffer too big");
		}
		
		
		tsk_object_unref(_producer);
	}
	
	if(mBlankPacketsSent++ >= BLANK_PACKETS_TO_SEND){
		[self stopBlankPacketsTimer];
	}
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput 
  didOutputVideoFrame:(CVImageBufferRef)videoFrame
	 withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	   fromConnection:(QTCaptureConnection *)connection
{
	CVReturn status = CVPixelBufferLockBaseAddress(videoFrame, 0);
	
	if(status == 0 && [self isValid]){
		UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(videoFrame);
		size_t buffeSize = CVPixelBufferGetDataSize(videoFrame);
		
		tmedia_producer_t* producer = (tmedia_producer_t*)tsk_object_ref((void*)_mProducer->getWrappedPlugin());
		
		if(mFirstFrame && producer){ // Hope will never change
			// no longer need blank packets
			[self stopBlankPacketsTimer];
			
			// alert the framework about the camera actual size
			tsk_mutex_lock(_mSenderMutex);
			const_cast<ProxyVideoProducer*>(_mProducer)->setActualCameraOutputSize(CVPixelBufferGetWidth(videoFrame), CVPixelBufferGetHeight(videoFrame));
			tsk_mutex_unlock(_mSenderMutex);
			
			int pixelFormat = CVPixelBufferGetPixelFormatType(videoFrame);
			switch (pixelFormat) {
				case kCVPixelFormatType_420YpCbCr8Planar:
					producer->video.chroma = tmedia_chroma_yuv420p;
					NgnNSLog(TAG,@"Capture pixel format=kCVPixelFormatType_420YpCbCr8Planar");
					break;
				case kCVPixelFormatType_422YpCbCr8:
					producer->video.chroma = tmedia_chroma_uyvy422;
					NgnNSLog(TAG,@"Capture pixel format=kCVPixelFormatType_422YpCbCr8");
					break;
				case kCVPixelFormatType_24RGB:
					producer->video.chroma = tmedia_chroma_rgb24;
					NgnNSLog(TAG,@"Capture pixel format=kCVPixelFormatType_24RGB");
					break;
				case kCVPixelFormatType_32ARGB:
					producer->video.chroma = tmedia_chroma_rgb32;
					NgnNSLog(TAG,@"Capture pixel format=kCVPixelFormatType_32ARGB");
					break;
				default:
					producer->video.chroma = tmedia_chroma_rgb32;
					NgnNSLog(TAG,@"Error --> %i not supported as pixelFormat", pixelFormat);
					goto done;
			}
			mFirstFrame = NO;
		}
		
		if(producer){
			dispatch_sync(_mSenderQueue, ^{
				tsk_mutex_lock(_mSenderMutex);
				producer->enc_cb.callback(producer->enc_cb.callback_data, bufferPtr, buffeSize);
				tsk_mutex_unlock(_mSenderMutex);
			});
		}
		
	done:
		tsk_object_unref(producer);
	}
	
	CVPixelBufferUnlockBaseAddress(videoFrame, 0);
}

@end

//
//	C++ callback
//
class _NgnProxyVideoProducerCallback : public ProxyVideoProducerCallback
{
public:
	_NgnProxyVideoProducerCallback(NgnProxyVideoProducer* producer)
	{
		mProducer = [producer retain];
	}
	
	virtual ~_NgnProxyVideoProducerCallback()
	{
		[mProducer release];
	}
	
	int prepare(int nWidth, int nHeight, int nFps) 
	{ 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer prepareWithWidth: nWidth andHeight: nHeight andFps: nFps]; 
		[pool release];
		return ret;
	}
	
	int start() 
	{ 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer start]; 
		[pool release];
		return ret;
	}
	
	int pause() 
	{ 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer pause]; 
		[pool release];
		return ret;
	}
	
	int stop() 
	{ 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer stop]; 
		[pool release];
		return ret;
	}
	
private:
	NgnProxyVideoProducer* mProducer;
};


//
// default implementation
//
//

@implementation NgnProxyVideoProducer

-(NgnProxyVideoProducer*) initWithId: (uint64_t)identifier andProducer:(const ProxyVideoProducer *)_producer
{
	if((self = (NgnProxyVideoProducer*)[super initWithId: identifier andPlugin: _producer])){
		_mProducer = _producer;
        _mCallback = new _NgnProxyVideoProducerCallback(self);
		if(_mProducer){
			const_cast<ProxyVideoProducer*>(_mProducer)->setCallback(_mCallback);
		}
		mBlankPacketsSent = 0;
		_mSenderMutex = tsk_mutex_create_2(tsk_false);

		mWidth = kDefaultVideoWidth;
		mHeight = kDefaultVideoHeight;
		mFps = kDefaultVideoFrameRate;
	}
	return self;
}

-(int) prepareWithWidth:(int)width andHeight:(int)height andFps:(int) fps
{
	NgnNSLog(TAG, @"prepareWithWidth(%i,%i,%i)", width, height, fps);
	if(!_mProducer){
		TSK_DEBUG_ERROR("Invalid embedded consumer");
		return -1;
	}
	
	mWidth = width;
	mHeight = height;
	mFps = fps;
	mPrepared = YES;
	
	return 0;
}

-(int) start
{
	NgnNSLog(TAG, "start()");
	mStarted = YES;
		
	// send blank packets
	[self performSelectorOnMainThread:@selector(startBlankPacketsTimer) withObject:nil waitUntilDone:NO];
	
	// start video capture
	[self performSelectorOnMainThread:@selector(startVideoCapture) withObject:nil waitUntilDone:NO];
	
	if(!_mSenderQueue){
		_mSenderQueue = dispatch_queue_create("org.doubango.idoubs.producer.sender", NULL);
		dispatch_queue_t high_prio_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		dispatch_set_target_queue(_mSenderQueue, high_prio_queue);
	}
	
	return 0;
}

-(int) pause
{
	NgnNSLog(TAG, "pause()");
	mPaused = true;
	return 0;
}

-(int) stop
{
	NgnNSLog(TAG, "stop()");
	mStarted = NO;
	
	[self performSelectorOnMainThread:@selector(stopBlankPacketsTimer) withObject:nil waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(stopVideoCapture) withObject:nil waitUntilDone:NO];
	return 0;
}

-(void)makeInvalidate
{
	[super makeInvalidate];
	if(_mProducer){
		const_cast<ProxyVideoProducer*>(_mProducer)->setCallback(tsk_null);
	}
	if(_mCallback){
		delete _mCallback, _mCallback = tsk_null;
	}
}

-(void)setPreview:(QTCaptureView*)preview
{
	if(preview == nil){
		// stop preview
		[self stopPreview];
		if(mPreview){
			[mPreview release], mPreview = nil;
		}
	}
	else {
		// start preview
		[mPreview release];
		if((mPreview = [preview retain])){
			[self startPreview];
		}
	}
}

-(void)dealloc
{
	if(_mCallback){
		delete _mCallback, _mCallback = tsk_null;
	}
	_mProducer = tsk_null; // you're not the owner
	
	if(_mSenderQueue){
		dispatch_release(_mSenderQueue);
	}
	if(_mSenderMutex){
		tsk_mutex_destroy(&_mSenderMutex);
	}
	
	
	[mCaptureSession release];
	[mCaptureDevice release];
	[mPreview release];
	
	
	[super dealloc];
}

@end

#endif /* TARGET_OS_MAC */
