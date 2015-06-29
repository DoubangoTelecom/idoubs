/* Copyright (C) 2010-2015, Mamadou DIOP.
 * Copyright (c) 2011-2015, Doubango Telecom. All rights reserved.
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

#import <Foundation/Foundation.h>

#import "iOSVideoProducer.h"
#import "NgnCamera.h"

#import "tinymedia/tmedia_producer.h"

#import "tsk_string.h"
#import "tsk_safeobj.h"
#import "tsk_buffer.h"
#import "tsk_debug.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define kDefaultVideoWidth		352
#define kDefaultVideoHeight		288
#define kDefaultVideoFrameRate	15
#define kDefaultVideoChroma     tmedia_chroma_nv12

#define BLANK_PACKETS_TO_SEND   3

#define NGN_VIDEO_PRODUCER_DEBUG_INFO(FMT, ...) TSK_DEBUG_INFO("[iOSVideoProducer]" FMT, ##__VA_ARGS__)
#define NGN_VIDEO_PRODUCER_DEBUG_ERROR(FMT, ...) TSK_DEBUG_ERROR("[iOSVideoProducer]" FMT, ##__VA_ARGS__)

#if NGN_HAVE_VIDEO_CAPTURE
// maxium size for a blank paket
// AVCaptureSessionPreset1920x1080 x RGB32
static uint8_t kBlankPacketBuffer[(1920 * 1080 * 4)] = { 0 };
#endif /* NGN_HAVE_VIDEO_CAPTURE */

@interface iOSVideoProducer : NSObject
#if NGN_HAVE_VIDEO_CAPTURE
<AVCaptureVideoDataOutputSampleBufferDelegate>
#endif
{
    BOOL mStarted;
    BOOL mPrepared;
    BOOL mPaused;
    BOOL mMuted;
    int mWidth;
    int mHeight;
    int mFps;
#if NGN_HAVE_VIDEO_CAPTURE
    const struct ios_producer_video_s* mWrappedProducer; // Not owner, do not release
    UIView* mPreview;
    AVCaptureSession* mCaptureSession;
    AVCaptureDevice *mCaptureDevice;
    BOOL mFirstFrame;
    BOOL mUseFrontCamera;
    AVCaptureVideoOrientation mOrientation;
    NSTimer* mTimerBlankPackets;
    int mBlankPacketsSent;
    tsk_mutex_handle_t *_mSenderMutex;
    dispatch_queue_t _mSenderQueue;
    tsk_list_t *_mSenderPackets;
#endif /* NGN_HAVE_VIDEO_CAPTURE */
}

-(iOSVideoProducer*) initWithWrappedProducer:(const struct ios_producer_video_s*)wrappedProducer;
-(void)setPreview: (UIView*)preview;
-(void)setMute:(BOOL)muted;
#if NGN_HAVE_VIDEO_CAPTURE
-(void)orientationChanged:(NSNotification *)notification;
-(void)setOrientation:(AVCaptureVideoOrientation)orientation;
-(void)toggleCamera;
-(void)useFrontCamera:(BOOL)front;
-(int)prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps;
-(int)start;
-(int)pause;
-(int)stop;
+(AVCaptureVideoOrientation) deviceCurrentOrientation:(AVCaptureVideoOrientation)defaultOrientation;
#endif /* NGN_HAVE_VIDEO_CAPTURE */
@end

#if NGN_HAVE_VIDEO_CAPTURE
@interface iOSVideoProducer (VideoCapture)
-(BOOL)startVideoCapture;
-(BOOL)stopVideoCapture;
-(BOOL)startPreview;
-(BOOL)stopPreview;
-(void)startBlankPacketsTimer;
-(void)stopBlankPacketsTimer;
-(void)timerBlankPacketsTick:(NSTimer*)timer;
-(void)sendQueuedPacket;
@end
#endif /* NGN_HAVE_VIDEO_CAPTURE */

typedef struct ios_producer_video_s
{
    TMEDIA_DECLARE_PRODUCER;
    
    tsk_bool_t b_started;
    tsk_bool_t b_prepared;
    tsk_bool_t b_paused;
    
    iOSVideoProducer* p_producer;
    
    TSK_DECLARE_SAFEOBJ;
}
ios_producer_video_t;




/* ============ Media Producer Interface ================= */

static int _ios_producer_video_set(tmedia_producer_t *p_self, const tmedia_param_t* pc_param)
{
    ios_producer_video_t* p_ios = (ios_producer_video_t*)p_self;
    if (!p_self || !pc_param) {
        NGN_VIDEO_PRODUCER_DEBUG_ERROR("Invalid parameter");
        return -1;
    }
    
    if (pc_param->value_type == tmedia_pvt_int64) {
        if (tsk_striequals(pc_param->key, "local-hwnd") || tsk_striequals(pc_param->key, "preview-hwnd")) {
            UIView* view = reinterpret_cast<UIView*>(*((int64_t*)pc_param->value));
            if (view) {
                assert([view isKindOfClass:[UIView class]]);
            }
            [p_ios->p_producer setPreview:view];
            return 0;
        }
    }
    else if (pc_param->value_type == tmedia_pvt_int32) {
        if (tsk_striequals(pc_param->key, "mute")) {
            BOOL muted = (TSK_TO_INT32((uint8_t*)pc_param->value) != 0);
            [p_ios->p_producer setMute:muted];
            return 0;
        }
        else if (tsk_striequals(pc_param->key, "camera-toggle")) {
            BOOL toggle = (TSK_TO_INT32((uint8_t*)pc_param->value) != 0);
            if (toggle) {
                [p_ios->p_producer toggleCamera];
                return 0;
            }
        }
        else if (tsk_striequals(pc_param->key, "camera-front")) {
            BOOL front = (TSK_TO_INT32((uint8_t*)pc_param->value) != 0);
            [p_ios->p_producer useFrontCamera:front];
            return 0;
        }
    }
    
    NGN_VIDEO_PRODUCER_DEBUG_ERROR("set(name=%s, value_type=%d) not supported", pc_param->key, pc_param->value_type);
    return -2;
}

static int _ios_producer_video_prepare(tmedia_producer_t* p_self, const tmedia_codec_t* pc_codec)
{
    ios_producer_video_t* p_ios = (ios_producer_video_t*)p_self;
    int ret = 0;
    NSAutoreleasePool *pool = nil;
    
    tsk_safeobj_lock(p_ios);
    
    if (p_ios->b_prepared) {
        NGN_VIDEO_PRODUCER_DEBUG_INFO("Already prepared");
        goto bail;
    }
    
    p_self->video.chroma = kDefaultVideoChroma; // request a video chroma converter from I420 to 'kDefaultVideoChroma'
    p_self->video.rotation = 90; // defaults to "Protrait", will be updated at start time
#if NGN_HAVE_VIDEO_CAPTURE
    pool = [[NSAutoreleasePool alloc] init];
    ret = [p_ios->p_producer prepareWithWidth:TMEDIA_CODEC_VIDEO(pc_codec)->out.width andHeight:TMEDIA_CODEC_VIDEO(pc_codec)->out.height andFps:TMEDIA_CODEC_VIDEO(pc_codec)->out.fps]; // prepare
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    p_ios->b_prepared = (ret == 0);
    
bail:
    tsk_safeobj_unlock(p_ios);
    [pool release];
    return ret;
}

static int _ios_producer_video_start(tmedia_producer_t* p_self)
{
    ios_producer_video_t* p_ios = (ios_producer_video_t*)p_self;
    int ret = 0;
    NSAutoreleasePool *pool = nil;
    
    tsk_safeobj_lock(p_ios);
    
    if (p_ios->b_started) {
        NGN_VIDEO_PRODUCER_DEBUG_ERROR("Already started");
        goto bail;
    }
    
    if (!p_ios->b_prepared) {
        NGN_VIDEO_PRODUCER_DEBUG_ERROR("Not prepared");
        ret = -1;
        goto bail;
    }
    
#if NGN_HAVE_VIDEO_CAPTURE
    pool = [[NSAutoreleasePool alloc] init];
    ret = [p_ios->p_producer start];
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    p_ios->b_started = (ret == 0);
    
bail:
    tsk_safeobj_unlock(p_ios);
    [pool release];
    return ret;
}

static int _ios_producer_video_pause(tmedia_producer_t* p_self)
{
    ios_producer_video_t* p_ios = (ios_producer_video_t*)p_self;
    int ret = 0;
    NSAutoreleasePool *pool = nil;
    
    tsk_safeobj_lock(p_ios);
    
    if (p_ios->b_paused) {
        NGN_VIDEO_PRODUCER_DEBUG_INFO("Already paused");
        goto bail;
    }
#if NGN_HAVE_VIDEO_CAPTURE
    pool = [[NSAutoreleasePool alloc] init];
    ret = [p_ios->p_producer pause];
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    p_ios->b_paused = (ret == 0);
    
bail:
    tsk_safeobj_unlock(p_ios);
    [pool release];
    return ret;
}

static int _ios_producer_video_stop(tmedia_producer_t* p_self)
{
    ios_producer_video_t* p_ios = (ios_producer_video_t*)p_self;
    int ret = 0;
    NSAutoreleasePool *pool = nil;
    
    tsk_safeobj_lock(p_ios);
    
    if (!p_ios->b_started) {
        goto bail;
    }
#if NGN_HAVE_VIDEO_CAPTURE
    pool = [[NSAutoreleasePool alloc] init];
    ret = [p_ios->p_producer stop];
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    p_ios->b_started = tsk_false;
    
bail:
    tsk_safeobj_unlock(p_ios);
    [pool release];
    return ret;
}

//
//      iOS video producer object definition
//
/* constructor */
static tsk_object_t* _ios_producer_video_ctor(tsk_object_t *self, va_list * app)
{
    ios_producer_video_t *p_ios = (ios_producer_video_t *)self;
    if (p_ios) {
        /* init base */
        tmedia_producer_init(TMEDIA_PRODUCER(p_ios));
        /* init self */
        p_ios->p_producer = [[iOSVideoProducer alloc] initWithWrappedProducer:p_ios];
        if (!p_ios->p_producer) {
            NGN_VIDEO_PRODUCER_DEBUG_ERROR("Failed to create proxy video producer");
            return tsk_null;
        }
        TMEDIA_PRODUCER(p_ios)->video.chroma = kDefaultVideoChroma;
        TMEDIA_PRODUCER(p_ios)->video.fps = kDefaultVideoFrameRate;
        TMEDIA_PRODUCER(p_ios)->video.width = kDefaultVideoWidth;
        TMEDIA_PRODUCER(p_ios)->video.height = kDefaultVideoHeight;
        
        tsk_safeobj_init(p_ios);
    }
    return self;
}
/* destructor */
static tsk_object_t* _ios_producer_video_dtor(tsk_object_t * self)
{
    ios_producer_video_t *p_ios = (ios_producer_video_t *)self;
    if (p_ios) {
        /* stop */
        if (p_ios->b_started) {
            _ios_producer_video_stop((tmedia_producer_t*)p_ios);
        }
        
        /* deinit base */
        tmedia_producer_deinit(TMEDIA_PRODUCER(p_ios));
        /* deinit self */
        [p_ios->p_producer release];
        tsk_safeobj_deinit(p_ios);
        
        NGN_VIDEO_PRODUCER_DEBUG_INFO("*** destroyed ***");
    }
    
    return self;
}
/* object definition */
static const tsk_object_def_t ios_producer_video_def_s =
{
    sizeof(ios_producer_video_t),
    _ios_producer_video_ctor,
    _ios_producer_video_dtor,
    tsk_null,
};
/* plugin definition*/
static const tmedia_producer_plugin_def_t ios_producer_video_plugin_def_s =
{
    &ios_producer_video_def_s,
    tmedia_video,
    "iOS video producer",
    
    _ios_producer_video_set,
    _ios_producer_video_prepare,
    _ios_producer_video_start,
    _ios_producer_video_pause,
    _ios_producer_video_stop
};
const tmedia_producer_plugin_def_t *ios_producer_video_plugin_def_t = &ios_producer_video_plugin_def_s;



/************************************************
 @implementation iOSVideoProducer
 ************************************************/

@implementation iOSVideoProducer

-(iOSVideoProducer*) initWithWrappedProducer:(const struct ios_producer_video_s*)wrappedProducer {
    assert(wrappedProducer != NULL);
    [self init];
    mStarted = NO;
    mMuted = NO;
    mPaused = NO;
#if NGN_HAVE_VIDEO_CAPTURE
    mWrappedProducer = wrappedProducer;
    mUseFrontCamera = YES;
    mFirstFrame = YES;
    mOrientation = [iOSVideoProducer deviceCurrentOrientation:AVCaptureVideoOrientationPortrait];
    mBlankPacketsSent = 0;
    _mSenderMutex = tsk_mutex_create_2(tsk_false);
    _mSenderPackets = tsk_list_create();
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    mWidth = kDefaultVideoWidth;
    mHeight = kDefaultVideoHeight;
    mFps = kDefaultVideoFrameRate;
    
    return self;
}

-(int) prepareWithWidth:(int) width andHeight: (int)height andFps: (int) fps{
    NGN_VIDEO_PRODUCER_DEBUG_INFO("prepareWithWidth(%i,%i,%i)", width, height, fps);
    mWidth = width;
    mHeight = height;
    mFps = fps;
    mPrepared = YES;
    return 0;
}

-(int) start {
    NGN_VIDEO_PRODUCER_DEBUG_INFO("start");
    mStarted = YES;
    mPaused = NO;
    
#if NGN_HAVE_VIDEO_CAPTURE
    mFirstFrame = YES;
    // listen to orientation change events
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
    // set orientation
    [self setOrientation:[iOSVideoProducer deviceCurrentOrientation:mOrientation]];
    // create sender queue if not already done
    if (!_mSenderQueue) {
        _mSenderQueue = dispatch_queue_create("org.doubango.sincity.producer.video.sender", NULL);
        dispatch_queue_t high_prio_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_set_target_queue(_mSenderQueue, high_prio_queue);
    }
    // send blank packets
    [self performSelectorOnMainThread:@selector(startBlankPacketsTimer) withObject:nil waitUntilDone:NO];
    // start capture
    [self startVideoCapture];
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    
    return 0;
}

-(int) pause{
    NGN_VIDEO_PRODUCER_DEBUG_INFO("pause");
    mPaused = YES;
    return 0;
}

-(int) stop{
    NGN_VIDEO_PRODUCER_DEBUG_INFO("stop");
    mStarted = NO;
    
#if NGN_HAVE_VIDEO_CAPTURE
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self performSelectorOnMainThread:@selector(stopBlankPacketsTimer) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(stopVideoCapture) withObject:nil waitUntilDone:NO];
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    return 0;
}

-(void)setPreview: (UIView*)preview {
#if NGN_HAVE_VIDEO_CAPTURE
    if (preview == nil) {
        // stop preview
        [self stopPreview];
        if (mPreview) {
            // remove views
            for (UIView *view in mPreview.subviews) {
                [view removeFromSuperview];
            }
            // remove layers
            for (CALayer *ly in mPreview.layer.sublayers) {
                if ([ly isKindOfClass: [AVCaptureVideoPreviewLayer class]]) {
                    [ly removeFromSuperlayer];
                    break;
                }
            }
            [mPreview release], mPreview = nil;
        }
    }
    else if (preview != mPreview) {
        // start preview
        [mPreview release];
        if ((mPreview = [preview retain])) {
            [self startPreview];
        }
    }
#endif
}

-(void)setMute:(BOOL)muted {
    mMuted = muted;
}

+(AVCaptureVideoOrientation) deviceCurrentOrientation:(AVCaptureVideoOrientation)defaultOrientation {
    switch ([UIDevice currentDevice].orientation) {
        case UIInterfaceOrientationPortrait: return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown: return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft: return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight: return AVCaptureVideoOrientationLandscapeRight;
        case UIDeviceOrientationFaceUp: return AVCaptureVideoOrientationPortrait; // TODO: not sure
        case UIDeviceOrientationFaceDown:  return AVCaptureVideoOrientationPortraitUpsideDown; // TODO: not sure
        default:
        case UIDeviceOrientationUnknown:
            return defaultOrientation;
    }
}

#if NGN_HAVE_VIDEO_CAPTURE

-(void)orientationChanged:(NSNotification *)notification {
    [self setOrientation:[iOSVideoProducer deviceCurrentOrientation:mOrientation]];
}

-(void) setOrientation: (AVCaptureVideoOrientation)orientation{
    if (mOrientation != orientation) {
        mOrientation = orientation;
        if (mPreview) {
            for(CALayer *ly in mPreview.layer.sublayers) {
                if ([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                    AVCaptureVideoPreviewLayer* previewLayer = (AVCaptureVideoPreviewLayer*)ly;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
                    BOOL orientationSupported = [[previewLayer connection] isVideoOrientationSupported];
#else
                    BOOL orientationSupported = previewLayer.orientationSupported;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 */
                    if (orientationSupported) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
                        [previewLayer.connection setVideoOrientation:mOrientation];
#else
                        previewLayer.orientation = mOrientation;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 */
                    }
                }
            }
        }
    }
    switch (mOrientation) {
        case AVCaptureVideoOrientationPortrait:
        case AVCaptureVideoOrientationPortraitUpsideDown:
            TMEDIA_PRODUCER(mWrappedProducer)->video.rotation = 90;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            TMEDIA_PRODUCER(mWrappedProducer)->video.rotation = mUseFrontCamera ? 180 : 0;
            break;
        default:
            TMEDIA_PRODUCER(mWrappedProducer)->video.rotation = mUseFrontCamera ? 0 : 180;
            break;
    }
}

-(void) toggleCamera {
    [self useFrontCamera:!mUseFrontCamera];
}

-(void)useFrontCamera:(BOOL)front {
    if (mUseFrontCamera != front) {
        mUseFrontCamera = front;
        if (mCaptureDevice && mCaptureSession && [mCaptureSession isRunning]) {
            [self stopVideoCapture];
            [self startVideoCapture];
        }
    }
}

#endif /* NGN_HAVE_VIDEO_CAPTURE */

-(void)dealloc {
    
#if NGN_HAVE_VIDEO_CAPTURE
    mWrappedProducer = nil; // you're not the owner
    [mCaptureSession release];
    [mCaptureDevice release];
    [mPreview release];
    if (mTimerBlankPackets) {
        [mTimerBlankPackets invalidate], mTimerBlankPackets = nil;
    }
    if (_mSenderQueue) {
        dispatch_release(_mSenderQueue), _mSenderQueue = nil;
    }
    if (_mSenderMutex) {
        tsk_mutex_destroy(&_mSenderMutex);
    }
    TSK_OBJECT_SAFE_FREE(_mSenderPackets);
#endif /* NGN_HAVE_VIDEO_CAPTURE */
    
    [super dealloc];
    
    NGN_VIDEO_PRODUCER_DEBUG_INFO("*** dealloc ***");
}

@end /* @implementation iOSVideoProducer */


/************************************************
 @implementation iOSVideoProducer(VideoCapture)
 ************************************************/
#if NGN_HAVE_VIDEO_CAPTURE
@implementation iOSVideoProducer(VideoCapture)

- (BOOL)startVideoCapture{
    NGN_VIDEO_PRODUCER_DEBUG_INFO("Starting Video stream");
    if (mCaptureDevice || mCaptureSession) {
        NGN_VIDEO_PRODUCER_DEBUG_INFO("Already capturing");
        return YES;
    }
    
    mCaptureDevice = mUseFrontCamera ? [[NgnCamera frontFacingCamera] retain] : [[NgnCamera backCamera] retain];
    if (!mCaptureDevice) {
        NGN_VIDEO_PRODUCER_DEBUG_ERROR("Failed to get valide capture device");
        return NO;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:mCaptureDevice error:&error];
    if (!videoInput){
        NGN_VIDEO_PRODUCER_DEBUG_ERROR("Failed to get video input: %s", error.localizedDescription.UTF8String);
        [mCaptureDevice release];
        mCaptureDevice = nil;
        return NO;
    }
    
    mCaptureSession = [[AVCaptureSession alloc] init];
    
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
    
    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs.producer.video.captureoutput", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [mCaptureSession addOutput:avCaptureVideoDataOutput];
    
    // preset should be set after "addInput" and "addOutput"
    int videoBytes = mHeight * mWidth;
    NSString *sessionPreset = AVCaptureSessionPresetLow;
    if (videoBytes >= (352 * 288)) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
        sessionPreset = AVCaptureSessionPreset352x288;
#else
        sessionPreset = AVCaptureSessionPresetMedium;
#endif
    }
    if (videoBytes >= (640 * 480)) {
        sessionPreset = AVCaptureSessionPreset640x480;
    }
    if (videoBytes >= (1280 * 720) || videoBytes >= (1024 * 768)) { // XGA: GE preferred size
        sessionPreset = AVCaptureSessionPreset1280x720;
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
    if (videoBytes >= (1920 * 1080)) {
        sessionPreset = AVCaptureSessionPreset1920x1080;
    }
#endif
    if ([mCaptureDevice supportsAVCaptureSessionPreset:sessionPreset]) {
        NGN_VIDEO_PRODUCER_DEBUG_INFO("For output video(%dx%d) we selected %s preset", mWidth, mHeight, [sessionPreset UTF8String]);
        mCaptureSession.sessionPreset = sessionPreset;
    }
    else {
        NGN_VIDEO_PRODUCER_DEBUG_ERROR("%s not supported as preset, fallback to %s", [sessionPreset UTF8String], [AVCaptureSessionPresetMedium UTF8String]);
        mCaptureSession.sessionPreset = AVCaptureSessionPresetMedium;
    }
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
    avCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0 // [5-6[
        avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, mFps);
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0 */
    }
    else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        NSError *error = nil;
        [mCaptureSession beginConfiguration];
        [mCaptureDevice lockForConfiguration:&error];
        if (error == nil) {
            float bestFps = mFps;
            float bestDiff = FLT_MAX;
            
            for (AVFrameRateRange * range in [mCaptureDevice activeFormat].videoSupportedFrameRateRanges) {
                NGN_VIDEO_PRODUCER_DEBUG_INFO("videoSupportedFrameRateRanges=[%f - %f]", range.minFrameRate, range.maxFrameRate);
                float fps = TSK_CLAMP(range.minFrameRate, mFps, range.maxFrameRate);
                float diff =  fps > mFps ? (fps - mFps) : (mFps - fps); // abs(diff)
                if (diff < bestDiff) {
                    bestFps = fps;
                    if (diff == 0) {
                        goto best_fps_found;
                    }
                    bestDiff = diff;
                }
            }
            
        best_fps_found:
            NGN_VIDEO_PRODUCER_DEBUG_INFO("requested fps=%d, best fps=%f", mFps, bestFps);
            @try {
                [mCaptureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, bestFps)];
                [mCaptureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, bestFps)];
            }
            @catch(NSException * e) {
                NGN_VIDEO_PRODUCER_DEBUG_ERROR("Failed to set frame rate: %s", error.localizedDescription.UTF8String);
            }
        }
        else {
            NGN_VIDEO_PRODUCER_DEBUG_ERROR("lockForConfiguration failed: %s", error.localizedDescription.UTF8String);
        }
        [mCaptureDevice unlockForConfiguration];
        [mCaptureSession commitConfiguration];
#else
        for(int i = 0; i < [[avCaptureVideoDataOutput connections] count]; i++) {
            AVCaptureConnection *captureConnection = [[avCaptureVideoDataOutput connections] objectAtIndex:i];
            captureConnection.videoMinFrameDuration = CMTimeMake(1, mFps);
            captureConnection.videoMaxFrameDuration = CMTimeMake(1, mFps);
        }
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0 */
    }
#else
    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, mFps);
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 */
    
    [avCaptureVideoDataOutput release];
    dispatch_release(queue);
    
    mFirstFrame = YES;
    
    if ([NSThread currentThread] != [NSThread mainThread]) { // From Doubango worker thread?
        [self performSelectorOnMainThread:@selector(startPreview) withObject:nil waitUntilDone:YES];
    }
    else {
        [self startPreview];
    }
    
    NGN_VIDEO_PRODUCER_DEBUG_INFO("Video capture started");
    return YES;
}

- (BOOL)stopVideoCapture{
    if (mCaptureSession) {
        [mCaptureSession stopRunning];
        [mCaptureSession release], mCaptureSession = nil;
        NGN_VIDEO_PRODUCER_DEBUG_INFO("Video capture stopped");
    }
    [mCaptureDevice release], mCaptureDevice = nil;
    
    if ([NSThread currentThread] != [NSThread mainThread]) { // From Doubango worker thread?
        [self performSelectorOnMainThread:@selector(stopPreview) withObject:nil waitUntilDone:YES];
    }
    else {
        [self stopPreview];
    }
    return YES;
}

- (BOOL)startPreview {
    if (mCaptureSession && mPreview && mStarted) {
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:mCaptureSession];
        previewLayer.frame = mPreview.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        BOOL orientationSupported = [[previewLayer connection] isVideoOrientationSupported];
#else
        BOOL orientationSupported = previewLayer.orientationSupported;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 */
        if (orientationSupported) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
            [previewLayer.connection setVideoOrientation:mOrientation];
#else
            previewLayer.orientation = mOrientation;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 */
        }
        
        // remove all sublayers and add new one
        for(CALayer *ly in mPreview.layer.sublayers) {
            if ([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                [ly removeFromSuperlayer];
                break;
            }
        }
        
        [mPreview.layer addSublayer:previewLayer];
        
        if (![mCaptureSession isRunning]) {
            [mCaptureSession startRunning];
        }
    }
    
    return YES;
}

- (BOOL)stopPreview {
    if (mCaptureSession) {
        if ([mCaptureSession isRunning]) {
            [mCaptureSession stopRunning];
        }
    }
    // remove all sublayers
    if (mPreview) {
        for (CALayer *ly in mPreview.layer.sublayers) {
            if ([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                [ly removeFromSuperlayer];
                break;
            }
        }
    }
    return YES;
}

- (void)startBlankPacketsTimer {
    if (!mTimerBlankPackets) {
        mBlankPacketsSent = 0;
        mTimerBlankPackets = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                              target:self
                                                            selector:@selector(timerBlankPacketsTick:)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

- (void)stopBlankPacketsTimer {
    if (mTimerBlankPackets) {
        [mTimerBlankPackets invalidate], mTimerBlankPackets = nil;
    }
}

- (void)timerBlankPacketsTick:(NSTimer*)timer {
    tmedia_producer_t *_producer;
    if ((_producer = (tmedia_producer_t *)tsk_object_ref(TSK_OBJECT(mWrappedProducer)))) {
        float buffer_size = 0.f;
        switch (_producer->video.chroma) {
            case tmedia_chroma_nv12:
                buffer_size = (mWidth * mHeight * 3)>>1;
                break;
            case tmedia_chroma_uyvy422:
                buffer_size = (mWidth * mHeight)<<1;
                break;
            case tmedia_chroma_rgb32:
                buffer_size = (mWidth * mHeight)<<2;
                break;
            default:
                NGN_VIDEO_PRODUCER_DEBUG_ERROR("Invalid chroma");
                break;
        }
        if (buffer_size > 0 && buffer_size < sizeof(kBlankPacketBuffer)) {
            NGN_VIDEO_PRODUCER_DEBUG_INFO("Sending Blank packet number %d", mBlankPacketsSent);
            if (_producer->enc_cb.callback) {
                dispatch_sync(_mSenderQueue, ^ {
                    tsk_mutex_lock(_mSenderMutex);
                    _producer->enc_cb.callback(_producer->enc_cb.callback_data, kBlankPacketBuffer, buffer_size);
                    tsk_mutex_unlock(_mSenderMutex);
                });
            }
        }
        else {
            NGN_VIDEO_PRODUCER_DEBUG_ERROR("Invalid buffer size:%f", buffer_size);
        }
        tsk_object_unref(_producer);
    }
    
    if (mBlankPacketsSent++ >= BLANK_PACKETS_TO_SEND) {
        [self stopBlankPacketsTimer];
    }
}

-(void)sendQueuedPacket{
    tsk_list_lock(_mSenderPackets);
    tsk_list_item_t *item = tsk_list_pop_first_item(_mSenderPackets);
    tsk_list_unlock(_mSenderPackets);
    
    if (item) {
        tmedia_producer_t* _wrapped_producer = (tmedia_producer_t*)tsk_object_ref(TSK_OBJECT(mWrappedProducer));
        if (_wrapped_producer && _wrapped_producer->is_started) {
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
        
        tmedia_producer_t* producer = (tmedia_producer_t*)tsk_object_ref(TSK_OBJECT(mWrappedProducer));
        
        if (mFirstFrame && producer) { // Hope size and chroma will never change
            // no longer need blank packets
            [self stopBlankPacketsTimer];
            
            // alert the framework about the camera actual size and fps
            tsk_mutex_lock(_mSenderMutex);
            if ([mCaptureDevice respondsToSelector:@selector(activeVideoMaxFrameDuration)]) {
                float fps = [mCaptureDevice activeVideoMaxFrameDuration].timescale / [mCaptureDevice activeVideoMaxFrameDuration].value;
                NGN_VIDEO_PRODUCER_DEBUG_INFO("Capture fps=%f", fps);
                // TODO: https://code.google.com/p/sincity/issues/detail?id=10&thanks=10&ts=1434682715
                // producer->video.fps = fps
            }
            
            producer->video.width = CVPixelBufferGetWidth(pixelBuffer);
            producer->video.height = CVPixelBufferGetHeight(pixelBuffer);
            tsk_mutex_unlock(_mSenderMutex);
            
            int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
            switch (pixelFormat) {
                case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                    producer->video.chroma = tmedia_chroma_nv12; // iPhone 3GS or 4
                    NGN_VIDEO_PRODUCER_DEBUG_INFO("Capture pixel format=NV12");
                    break;
                case kCVPixelFormatType_422YpCbCr8:
                    producer->video.chroma = tmedia_chroma_uyvy422; // iPhone 3
                    NGN_VIDEO_PRODUCER_DEBUG_INFO("Capture pixel format=UYUY422");
                    break;
                default:
                    producer->video.chroma = tmedia_chroma_rgb32;
                    NGN_VIDEO_PRODUCER_DEBUG_INFO("Capture pixel format=RGB32");
                    break;
            }
            mFirstFrame = NO;
        }
        
        if (!mMuted && !mPaused) {
            // create new packet and push it into the queue
            tsk_buffer_t *_packet = tsk_buffer_create(bufferPtr, buffeSize);
            tsk_list_push_back_data(_mSenderPackets, (void**)&_packet);
            TSK_OBJECT_SAFE_FREE(_packet);
            
            // send data over the network
            if (producer && bufferPtr && buffeSize && producer->enc_cb.callback) {
                dispatch_sync(_mSenderQueue, ^{
                    [self sendQueuedPacket];
                });
            }
        }
        
        tsk_object_unref(producer);
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
}

@end /* @implementation iOSVideoProducer(VideoCapture) */

#endif /* NGN_HAVE_VIDEO_CAPTURE */
