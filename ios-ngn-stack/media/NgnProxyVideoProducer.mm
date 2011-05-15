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

#import "NgnProxyVideoProducer.h"
#import "iOSNgnConfig.h"

#import "ProxyProducer.h"

#undef TAG
#define kTAG @"NgnProxyVideoProducer///: "
#define TAG kTAG

#define kDefaultVideoWidth		176
#define kDefaultVideoHeight		144
#define kDefaultVideoFrameRate	15

@interface NgnProxyVideoProducer(Private)
-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps;
-(int) start;
-(int) pause;
-(int) stop;
@end

#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
@interface NgnProxyVideoProducer (VideoCapture)
- (AVCaptureDevice *)frontFacingCamera;
- (void)startVideoCapture;
- (void)stopVideoCapture;
- (void)startPreview;
- (void)stopPreview;
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

- (AVCaptureDevice *)frontFacingCamera{
	NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras){
        if (device.position == AVCaptureDevicePositionFront){
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (void)startVideoCapture{
	NgnNSLog(TAG,@"Starting Video stream");
	if(mCaptureDevice || mCaptureSession){
		NgnNSLog(TAG,@"Already capturing");
		return;
	}
	
	if(!(mCaptureDevice = [[self frontFacingCamera] retain])){
		NgnNSLog(TAG,@"Failed to get valide capture device");
		return;
	}
	
	NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice: mCaptureDevice error:&error];
    if (!videoInput){
        NgnNSLog(TAG,@"Failed to get video input: %@", error);
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
	else {
		mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
	}
    [mCaptureSession addInput:videoInput];
	
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are 
	// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA. 
	// On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
	//
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                             // [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
							  [NSNumber numberWithInt: mWidth], (id)kCVPixelBufferWidthKey,
                              [NSNumber numberWithInt: mHeight], (id)kCVPixelBufferHeightKey,
							  
							  
							  nil];
    avCaptureVideoDataOutput.videoSettings = settings;
    [settings release];
    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, mFps);
	avCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [mCaptureSession addOutput: avCaptureVideoDataOutput];
    [avCaptureVideoDataOutput release];
    dispatch_release(queue);
	
	mFirstFrame = YES;
	
	[self startPreview];
	
	NgnNSLog(TAG, @"Video capture started");
}

- (void)stopVideoCapture{
	if(mCaptureSession){
		[mCaptureSession stopRunning];
		[mCaptureSession release], mCaptureSession = nil;
		NgnNSLog(TAG,@"Video capture stopped");
	}
	[mCaptureDevice release], mCaptureDevice = nil;
	
	if(mPreview){
		for (UIView *view in mPreview.subviews) {
			[view removeFromSuperview];
		}
	}
}

- (void)startPreview{
	if(mCaptureSession && mPreview && mStarted){
		AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: mCaptureSession];
		previewLayer.frame = mPreview.bounds;
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		previewLayer.orientation = AVCaptureVideoOrientationPortrait;
		
		[mPreview.layer addSublayer: previewLayer];
	 
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
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess){
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
		
		// FIXME: http://code.google.com/p/idoubs/issues/detail?id=27&q=UInt8
		bufferPtr += 16 * sizeof(UInt8);
		
		tmedia_producer_t* producer = (tmedia_producer_t*)tsk_object_ref((void*)_mProducer->getWrappedPlugin());
		
		if(mFirstFrame && producer){ // Hope will never change
			producer->video.width = CVPixelBufferGetWidth(pixelBuffer);
			producer->video.height = CVPixelBufferGetHeight(pixelBuffer);
			
			int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
			switch (pixelFormat) {
				case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
					producer->video.chroma = tmedia_nv12; // iPhone 3GS or 4
					NgnNSLog(TAG,@"Capture pixel format=NV12");
					break;
				case kCVPixelFormatType_422YpCbCr8:
					producer->video.chroma = tmedia_uyvy422; // iPhone 3
					NgnNSLog(TAG,@"Capture pixel format=UYUY422");
					break;
				default:
					producer->video.chroma = tmedia_rgb32;
					NgnNSLog(TAG,@"Capture pixel format=RGB32");
					break;
			}
			mFirstFrame = NO;
		}
		
		// Send data over the network
		if(producer && bufferPtr && buffeSize && producer->enc_cb.callback){
			producer->enc_cb.callback(producer->enc_cb.callback_data, bufferPtr, buffeSize);
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
		mFirstFrame = YES;
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
	[self stopVideoCapture];
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
	[mPreview release];
	if((mPreview = [preview retain])){
		[self startPreview];
	}
	else {
		[self stopPreview];
	}

#endif
}

-(void)dealloc{
	if(_mCallback){
		delete _mCallback, _mCallback = tsk_null;
	}
	_mProducer = tsk_null; // you're not the owner
	
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
	[mCaptureSession release];
	[mCaptureDevice release];
	[mPreview release];
#endif
	
	[super dealloc];
}

@end

#endif /* TARGET_OS_IPHONE */
