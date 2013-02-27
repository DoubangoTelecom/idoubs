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

#import "iOSProxyVideoProducer.h"
#import "iOSNgnConfig.h"

#import "ProxyProducer.h"

#undef TAG
#define kTAG @"NgnProxyVideoProducer///: "
#define TAG kTAG

#define kDefaultVideoWidth		352
#define kDefaultVideoHeight		288
#define kDefaultVideoFrameRate	15

#define BLANK_PACKETS_TO_SEND   3

// maxium size for a blank paket
// under devices without camera there is no way to detect the video stream size
// we also consider that the chroma is NV12 which is the default one on iPhone4 and 3GS
// 1280x720 => AVCaptureSessionPreset1280x720
static uint8_t kBlankPacketBuffer[(1280*720*3)>>1] = { 0 };

@interface NgnProxyVideoProducer(Private)
-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps;
-(int) start;
-(int) pause;
-(int) stop;
@end

#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
@interface NgnProxyVideoProducer (VideoCapture)
- (void)startVideoCapture;
- (void)stopVideoCapture;
- (void)startPreview;
- (void)stopPreview;
- (void)startBlankPacketsTimer;
- (void)stopBlankPacketsTimer;
- (void)timerBlankPacketsTick:(NSTimer*)timer;
- (void)sendQueuedPacket;
@end
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */


//
//	C++ callback
//
class _NgnProxyVideoProducerCallback : public ProxyVideoProducerCallback
{
public:
	_NgnProxyVideoProducerCallback(NgnProxyVideoProducer* producer){
		mProducer = [producer retain];
	}
	
	virtual ~_NgnProxyVideoProducerCallback(){
		[mProducer release];
	}
	
	int prepare(int nWidth, int nHeight, int nFps) { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer prepareWithWidth: nWidth andHeight: nHeight andFps: nFps]; 
		[pool release];
		return ret;
	}
	
	int start() { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer start]; 
		[pool release];
		return ret;
	}
	
	int pause() { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer pause]; 
		[pool release];
		return ret;
	}
	
	int stop() { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		int ret = [mProducer stop]; 
		[pool release];
		return ret;
	}
	
private:
	NgnProxyVideoProducer* mProducer;
};



//
// Video capture
//
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
@implementation NgnProxyVideoProducer(VideoCapture)


- (void)startVideoCapture{
	NgnNSLog(TAG,@"Starting Video stream");
	if(mCaptureDevice || mCaptureSession){
		NgnNSLog(TAG,@"Already capturing");
		return;
	}
	
	mCaptureDevice = mUseFrontCamera ? [[NgnCamera frontFacingCamera] retain] : [[NgnCamera backCamera] retain];
	if(!mCaptureDevice){
		NgnNSLog(TAG,@"Failed to get valide capture device");
		return;
	}
	
	NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:mCaptureDevice error:&error];
    if (!videoInput){
        NgnNSLog(TAG,@"Failed to get video input: %@", error);
		[mCaptureDevice release];
		mCaptureDevice = nil;
        return;
    }
	
    mCaptureSession = [[AVCaptureSession alloc] init];
	if(mHeight <= 144){
		mCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
	}
	else if(mHeight <= 360){
		mCaptureSession.sessionPreset = AVCaptureSessionPresetMedium;
	}
	else if(mHeight <= 480){
		mCaptureSession.sessionPreset = AVCaptureSessionPresetHigh;
	}
	else if(mHeight <= 720){
		mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
	}
	else {
        if([mCaptureDevice supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]){
            mCaptureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        }
        else{
            mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
        }
	}
    
    [mCaptureSession addInput:videoInput];
	
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are 
	// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA. 
	// On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
	// When using libyuv kCVPixelFormatType_32BGRA is faster
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
							  [NSNumber numberWithInt: mWidth], (id)kCVPixelBufferWidthKey,
							  [NSNumber numberWithInt: mHeight], (id)kCVPixelBufferHeightKey,
							  
							  
							  nil];
    avCaptureVideoDataOutput.videoSettings = settings;
    [settings release];
    
    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs.producer.captureoutput", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [mCaptureSession addOutput:avCaptureVideoDataOutput];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    avCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 5){
        avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, mFps);
    }
    else{
        for(int i = 0; i < [[avCaptureVideoDataOutput connections] count]; i++) {
            AVCaptureConnection *captureConnection = [[avCaptureVideoDataOutput connections] objectAtIndex:i];
            captureConnection.videoMinFrameDuration = CMTimeMake(1, mFps);
            captureConnection.videoMaxFrameDuration = CMTimeMake(1, mFps);
        }
    }
#else
	avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, mFps);
#endif
    
	
	// orientation
	//for(int i = 0; i < [[avCaptureVideoDataOutput connections] count]; i++) {
	//	AVCaptureConnection *captureConnection = [[avCaptureVideoDataOutput connections] objectAtIndex:i];
	//	if(captureConnection.supportsVideoOrientation) {
	//		captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
	//	}
	//}
	
	// torch
	//if([mCaptureDevice isTorchModeSupported:AVCaptureTorchModeOn]) {  
	//	[mCaptureDevice lockForConfiguration:nil];  
	//	mCaptureDevice.torchMode=AVCaptureTorchModeOn;  
	//	[mCaptureDevice unlockForConfiguration];  
	//}
	
    [avCaptureVideoDataOutput release];
    dispatch_release(queue);
	
	mFirstFrame = YES;
	
	if([NSThread currentThread] != [NSThread mainThread]){// From Doubango worker thread?
		[self performSelectorOnMainThread:@selector(startPreview) withObject:nil waitUntilDone:YES];
	}
	else {
		[self startPreview];
	}
	
	NgnNSLog(TAG, @"Video capture started");
}

- (void)stopVideoCapture{
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

- (void)startPreview{
	if(mCaptureSession && mPreview && mStarted){
		AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:mCaptureSession];
		previewLayer.frame = mPreview.bounds;
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		if(previewLayer.orientationSupported){
			previewLayer.orientation = mOrientation;
		}
		
		// remove all sublayers and add new one
		if(mPreview){
			for(CALayer *ly in mPreview.layer.sublayers){
				if([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]){
					[ly removeFromSuperlayer];
					break;
				}
			}
			
			[mPreview.layer addSublayer:previewLayer];
		}
		
		if(![mCaptureSession isRunning]){
			[mCaptureSession startRunning];
		}
	}
}

- (void)stopPreview{
	if(mCaptureSession){
		if([mCaptureSession isRunning]){
			[mCaptureSession stopRunning];
		}
	}
	// remove all sublayers
	if(mPreview){
		for(CALayer *ly in mPreview.layer.sublayers){
			if([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]){
				[ly removeFromSuperlayer];
				break;
			}
		}
	}
}

- (void)startBlankPacketsTimer{
	if(!mTimerBlankPackets){
		mBlankPacketsSent = 0;
		mTimerBlankPackets = [NSTimer scheduledTimerWithTimeInterval:0.2
															  target:self
															selector:@selector(timerBlankPacketsTick:)
															userInfo:nil
															 repeats:YES];
	}
}

- (void)stopBlankPacketsTimer{
	if(mTimerBlankPackets){
		[mTimerBlankPackets invalidate], mTimerBlankPackets = nil;
	}
}

- (void)timerBlankPacketsTick:(NSTimer*)timer{
	tmedia_producer_t *_producer;
	if((_producer = (tmedia_producer_t *)tsk_object_ref((void*)_mProducer->getWrappedPlugin()))){
		float buffer_size = 0.f;
		switch (TMEDIA_PRODUCER(_producer)->video.chroma) {
			case tmedia_chroma_nv12:
				buffer_size = (mWidth * mHeight * 3)>>1;
				break;
			case tmedia_chroma_uyvy422:
				buffer_size = (mWidth * mHeight)<<1;
				break;
			case tmedia_chroma_rgb32:
				buffer_size = (mWidth * mHeight)<<2;
				break;
		}
		if(buffer_size<sizeof(kBlankPacketBuffer)){
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

-(void)sendQueuedPacket{
	tsk_list_lock(_mSenderPackets);
	tsk_list_item_t *item = tsk_list_pop_first_item(_mSenderPackets);
    tsk_list_unlock(_mSenderPackets);
    
	if(item){
		tmedia_producer_t* _wrapped_producer = (tmedia_producer_t*)tsk_object_ref((void*)_mProducer->getWrappedPlugin());
		if(_wrapped_producer && _wrapped_producer->is_started){
			_wrapped_producer->enc_cb.callback(_wrapped_producer->enc_cb.callback_data, TSK_BUFFER_DATA(item->data), TSK_BUFFER_SIZE(item->data));
		}
        tsk_object_unref(_wrapped_producer);
		TSK_OBJECT_SAFE_FREE(item);
	}
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection 
{
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess){
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
		
		// http://code.google.com/p/idoubs/issues/detail?id=27&q=UInt8
        //static const size_t pad = (sizeof(UInt8) << 4);
		//bufferPtr += pad;
		
		tmedia_producer_t* producer = (tmedia_producer_t*)tsk_object_ref((void*)_mProducer->getWrappedPlugin());
		
		if(mFirstFrame && producer){ // Hope will never change
			// no longer need blank packets
			[self stopBlankPacketsTimer];
			
			// alert the framework about the camera actual size
			tsk_mutex_lock(_mSenderMutex);
			const_cast<ProxyVideoProducer*>(_mProducer)->setActualCameraOutputSize(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
			tsk_mutex_unlock(_mSenderMutex);
			
			int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
			switch (pixelFormat) {
				case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
					producer->video.chroma = tmedia_chroma_nv12; // iPhone 3GS or 4
					NgnNSLog(TAG,@"Capture pixel format=NV12");
					break;
				case kCVPixelFormatType_422YpCbCr8:
					producer->video.chroma = tmedia_chroma_uyvy422; // iPhone 3
					NgnNSLog(TAG,@"Capture pixel format=UYUY422");
					break;
				default:
					producer->video.chroma = tmedia_chroma_rgb32;
					NgnNSLog(TAG,@"Capture pixel format=RGB32");
					break;
			}
			mFirstFrame = NO;
		}
		
		// create new packet and push it into the queue
		tsk_buffer_t *_packet = tsk_buffer_create(bufferPtr, buffeSize);
		tsk_list_push_back_data(_mSenderPackets, (void**)&_packet);
		TSK_OBJECT_SAFE_FREE(_packet);
		
		// send data over the network
		if(producer && bufferPtr && buffeSize && producer->enc_cb.callback){
			dispatch_sync(_mSenderQueue, ^{
                [self sendQueuedPacket];
			});
        }
		
		tsk_object_unref(producer);
		
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);         
    }
}

@end

#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */



//
// Video producer
//

@implementation NgnProxyVideoProducer

-(NgnProxyVideoProducer*) initWithId: (uint64_t)identifier andProducer:(const ProxyVideoProducer *)_producer{
	if((self = (NgnProxyVideoProducer*)[super initWithId: identifier andPlugin: _producer])){
		_mProducer = _producer;
        _mCallback = new _NgnProxyVideoProducerCallback(self);
		if(_mProducer){
			const_cast<ProxyVideoProducer*>(_mProducer)->setCallback(_mCallback);
		}
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
		mUseFrontCamera = YES;
		mFirstFrame = YES;
		mOrientation = AVCaptureVideoOrientationPortrait;
		mBlankPacketsSent = 0;
		_mSenderMutex = tsk_mutex_create_2(tsk_false);
		_mSenderPackets = tsk_list_create();
#endif
		mWidth = kDefaultVideoWidth;
		mHeight = kDefaultVideoHeight;
		mFps = kDefaultVideoFrameRate;
	}
	return self;
}

-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps{
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

-(int) start{
	NgnNSLog(TAG, "start()");
	mStarted = YES;
	
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	if(_mProducer){
		switch (mOrientation) {
			case AVCaptureVideoOrientationPortrait: 
			case AVCaptureVideoOrientationPortraitUpsideDown:
				const_cast<ProxyVideoProducer*>(_mProducer)->setRotation(90);
				break;
			default:
				const_cast<ProxyVideoProducer*>(_mProducer)->setRotation(0);
				break;
		}
		
		// send blank packets
		[self performSelectorOnMainThread:@selector(startBlankPacketsTimer) withObject:nil waitUntilDone:NO];
	}
	if(!_mSenderQueue){
		_mSenderQueue = dispatch_queue_create("org.doubango.idoubs.producer.sender", NULL);
		dispatch_queue_t high_prio_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		dispatch_set_target_queue(_mSenderQueue, high_prio_queue);
	}
	[self startVideoCapture];
#endif
	return 0;
}

-(int) pause{
	NgnNSLog(TAG, "pause()");
	mPaused = true;
	return 0;
}

-(int) stop{
	NgnNSLog(TAG, "stop()");
	mStarted = NO;
	
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	[self performSelectorOnMainThread:@selector(stopBlankPacketsTimer) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(stopVideoCapture) withObject:nil waitUntilDone:NO];
#endif
	return 0;
}

-(void)makeInvalidate{
	[super makeInvalidate];
	if(_mProducer){
		const_cast<ProxyVideoProducer*>(_mProducer)->setCallback(tsk_null);
	}
	if(_mCallback){
		delete _mCallback, _mCallback = tsk_null;
	}
}

-(void)setPreview: (UIView*)preview{
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	
	if(preview == nil){
		// stop preview
		[self stopPreview];
		if(mPreview){
			// remove views
			for (UIView *view in mPreview.subviews) {
				[view removeFromSuperview];
			}
			// remove layers
			for(CALayer *ly in mPreview.layer.sublayers){
				if([ly isKindOfClass: [AVCaptureVideoPreviewLayer class]]){
					[ly removeFromSuperlayer];
					break;
				}
			}
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
	
#endif
}

#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
-(void) setOrientation: (AVCaptureVideoOrientation)orientation{
	if(mOrientation != orientation){
		mOrientation = orientation;
		[self stopPreview];
		[self startPreview];
	}
	if(_mProducer){
		switch (mOrientation) {
			case AVCaptureVideoOrientationPortrait: 
			case AVCaptureVideoOrientationPortraitUpsideDown:
				const_cast<ProxyVideoProducer*>(_mProducer)->setRotation(90);
				break;
			default:
				const_cast<ProxyVideoProducer*>(_mProducer)->setRotation(0);
				break;
		}
	}
}

-(void) toggleCamera{
	mUseFrontCamera = !mUseFrontCamera;
	if(mCaptureDevice && mCaptureSession && [mCaptureSession isRunning]){
		[self stopVideoCapture];
		[self startVideoCapture];
	}
}
#endif

-(void)dealloc{
	if(_mCallback){
		delete _mCallback, _mCallback = tsk_null;
	}
	_mProducer = tsk_null; // you're not the owner
	
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	[mCaptureSession release];
	[mCaptureDevice release];
	[mPreview release];
	if(mTimerBlankPackets){
		[mTimerBlankPackets invalidate], mTimerBlankPackets = nil;
	}
	if(_mSenderQueue){
		dispatch_release(_mSenderQueue);
	}
	if(_mSenderMutex){
		tsk_mutex_destroy(&_mSenderMutex);
	}
	TSK_OBJECT_SAFE_FREE(_mSenderPackets);
#endif
	
	[super dealloc];
}

@end

#endif /* TARGET_OS_IPHONE */
