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
#import "NgnVideoConsumer.h"

#import "tinymedia/tmedia_consumer.h"

#import "tsk_memory.h"
#import "tsk_string.h"
#import "tsk_safeobj.h"
#import "tsk_debug.h"

#if TARGET_OS_IPHONE
#import "iOSGLView.h"
#endif

#undef TAG
#define kTAG @"NgnVideoConsumer///: "
#define TAG kTAG

#define NGN_VIDEO_CONSUMER_DEBUG_INFO(FMT, ...) TSK_DEBUG_INFO("[NgnVideoConsumer]" FMT, ##__VA_ARGS__)
#define NGN_VIDEO_CONSUMER_DEBUG_ERROR(FMT, ...) TSK_DEBUG_ERROR("[NgnVideoConsumer]" FMT, ##__VA_ARGS__)

@interface SCDisplayOSX : NSObject {
#if TARGET_OS_MAC
    uint8_t* bufferPtr;
#endif
    size_t bufferSize;
    
    int width;
    int height;
    int fps;
    BOOL flipped;
    
    BOOL started;
    BOOL prepared;
    BOOL paused;
    
    const tmedia_consumer_t* consumer;
    
#if TARGET_OS_IPHONE
    iOSGLView* display;
#elif TARGET_OS_MAC
    CGContextRef bitmapContext;
    NSObject<NgnVideoView>* display;
#endif
}

-(SCDisplayOSX*) initWithConsumer: (const tmedia_consumer_t*)consumer;
-(BOOL) isPrepared;
-(BOOL) isStarted;

#if TARGET_OS_IPHONE
-(void) setDisplay: (iOSGLView*)display;
#elif TARGET_OS_MAC
-(void) setDisplay: (NSObject<NgnVideoView>*)display;
#endif

@end

#define kDefaultVideoWidth		176
#define kDefaultVideoHeight		144
#define kDefaultVideoFrameRate	15

@interface SCDisplayOSX(Private)
-(int) drawFrameOnMainThread;
-(int) prepareWithWidth:(int)width_ height:(int)height_ fps:(int)fps_;
-(int) start;
-(int) consumeFrame:(const void*)framePtr size:(unsigned)frameSize;
-(int) pause;
-(int) stop;
-(int) resizeBufferWithWidth:(int)width_ height:(int)height_;
@end

@implementation SCDisplayOSX

-(SCDisplayOSX*) initWithConsumer: (const tmedia_consumer_t*)consumer_ {
    consumer = consumer_;
    bufferPtr = tsk_null, bufferSize = 0;
    width = kDefaultVideoWidth;
    height = kDefaultVideoHeight;
    fps = kDefaultVideoFrameRate;
#if !TARGET_OS_IPHONE
    bitmapContext = nil;
#endif
    return self;
}

-(BOOL) isPrepared {
    return prepared;
}

-(BOOL) isStarted {
    return started;
}

#if TARGET_OS_IPHONE
-(void) setDisplay: (iOSGLView*)display_ {
    if (display != display_) {
        if(display) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [display stopAnimation];
            });
            [display release];
        }
        display = display_ ? [display_ retain] : nil;
        if (display && started) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [display startAnimation];
            });
        }
    }
}
#elif TARGET_OS_MAC
-(void) setDisplay: (NSObject<NgnVideoView>*)display_ {
    [display release];
    display = display_ ? [display_ retain] : nil;
}
#else
#error "Not implemented"
#endif

-(int) prepareWithWidth:(int)width_ height:(int)height_ fps:(int)fps_ {
    NGN_VIDEO_CONSUMER_DEBUG_INFO("prepareWithWidth(%i,%i,%i)", width_, height_, fps_);
    if (!consumer) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Invalid embedded consumer");
        return -1;
    }
    
    // resize buffer
    if ([self resizeBufferWithWidth:width_ height:height_] != 0) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("resizeBitmapContextWithWidth:%i andHeight:%i has failed", width_, height_);
        return -1;
    }
    
    // mWidth and and mHeight already updated by resizeBitmap....
    fps = fps_;
    
#if TARGET_OS_IPHONE
    if (display) {
        [display setFps:fps_]; // OpenGL framerate
    }
#elif TARGET_OS_MAC
#endif
    
    prepared = YES;
    return 0;
}

-(int) start {
    NGN_VIDEO_CONSUMER_DEBUG_INFO("start()");
    started = true;
    if (display) {
#if TARGET_OS_IPHONE
        dispatch_async(dispatch_get_main_queue(), ^{
            [display startAnimation];
        });
#endif
    }
    return 0;
}

-(int) consumeFrame:(const void*)framePtr size:(unsigned)frameSize {
    // size comparaison is detected: chroma change or width/height change
    // width/height comparaison is to detect: (width,heigh) swapping which would keep size unchanged
    unsigned _frameWidth = (unsigned)TMEDIA_CONSUMER(consumer)->video.display.width;
    unsigned _frameHeight = (unsigned)TMEDIA_CONSUMER(consumer)->video.display.height;
    if (frameSize != bufferSize || width != _frameWidth || height != _frameHeight) {
        NGN_VIDEO_CONSUMER_DEBUG_INFO("Incoming frame size changed: %u->%u, %u->%u, %u->%u", (unsigned)bufferSize, frameSize, width, _frameWidth, height, _frameHeight);
        // resize buffer
        if ([self resizeBufferWithWidth:_frameWidth height:_frameHeight] != 0) {
            NGN_VIDEO_CONSUMER_DEBUG_ERROR("resizeBufferWithWidth:%i andHeight:%i has failed", _frameWidth, _frameHeight);
            return -1;
        }
    }
    if (display) {
#if TARGET_OS_IPHONE
        [display setBufferYUV:(const uint8_t*)framePtr width:width height:height];
#elif TARGET_OS_MAC
        if (mBitmapContext) {
            memcpy(bufferPtr, framePtr, frameSize);
            CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
            [display setCurrentImage:imageRef];
            CGImageRelease(imageRef);
        }
#endif
    }
    return 0;
}

-(int) pause {
    NGN_VIDEO_CONSUMER_DEBUG_INFO("pause()");
    paused = YES;
    if (display) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [display stopAnimation];
        });
    }
    return 0;
}

-(int) stop{
    NGN_VIDEO_CONSUMER_DEBUG_INFO("stop()");
    started = NO;
    if (display) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [display stopAnimation];
        });
    }
    return 0;
}

-(int) resizeBufferWithWidth:(int)width_ height:(int)height_ {
    if (!consumer) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Invalid embedded consumer");
        return -1;
    }
    int ret = 0;
    // realloc the buffer
#if TARGET_OS_IPHONE
    unsigned newBufferSize = (width_ * height_ * 3) >> 1; // NV12
#elif TARGET_OS_MAC
    unsigned newBufferSize = (width_ * height_) << 2; // RGB32
    if (!(bufferPtr = (uint8_t*)tsk_realloc(bufferPtr, newBufferSize))) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Failed to realloc buffer with size=%u", newBufferSize);
        bufferSize = 0;
        return -1;
    }
#endif
    bufferSize = newBufferSize;
    width = width_;
    height = height_;
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
    // release context
    CGContextRelease(mBitmapContext), mBitmapContext = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    mBitmapContext = CGBitmapContextCreate(_mBufferPtr, width_, height_, 8, width_ * 4, colorSpace,
                                           kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
#endif
    
    return ret;
}

-(void)dealloc {
    consumer = tsk_null; // you're not the owner
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
    TSK_FREE(bufferPtr);
    CGContextRelease(mBitmapContext), bitmapContext = nil;
#endif
    bufferSize = 0;
    
    if (display) {
        [display release];
        display = nil;
    }
    
    [super dealloc];
    
    NGN_VIDEO_CONSUMER_DEBUG_INFO("*** dealloc ***");
}

@end


typedef struct ngn_consumer_video_s {
    TMEDIA_DECLARE_CONSUMER;
    
    SCDisplayOSX* display;
    
    TSK_DECLARE_SAFEOBJ;
}
ngn_consumer_video_t;

/* ============ Media Consumer Interface ================= */
static int ngn_consumer_video_set(tmedia_consumer_t *self, const tmedia_param_t* param)
{
    int ret = 0;
    ngn_consumer_video_t* p_display = (ngn_consumer_video_t*)self;
    (void)(p_display);
    
    if (!self || !param) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Invalid parameter");
        return -1;
    }
    
    if (param->value_type == tmedia_pvt_int64) {
        if (tsk_striequals(param->key, "remote-hwnd")) {
            NGN_VIDEO_CONSUMER_DEBUG_INFO("Set remote handle where to display video");
#if TARGET_OS_IPHONE
            iOSGLView* view = reinterpret_cast<iOSGLView*>(*((int64_t*)param->value));
            if (view) {
                assert([view isKindOfClass:[iOSGLView class]]);
            }
#elif TARGET_OS_MAC
            NgnVideoView* view = reinterpret_cast<NgnVideoView*>(*((int64_t*)param->value));
            if (view) {
                assert([view isKindOfClass:[NgnVideoView class]]);
            }
#endif
            tsk_safeobj_lock(p_display);
            [p_display->display setDisplay:view];
            tsk_safeobj_unlock(p_display);
        }
    }
    else if (param->value_type == tmedia_pvt_int32) {
        if (tsk_striequals(param->key, "fullscreen")) {
            NGN_VIDEO_CONSUMER_DEBUG_INFO("Enable/disable fullscreen");
        }
    }
    
    return ret;
}


static int ngn_consumer_video_prepare(tmedia_consumer_t* self, const tmedia_codec_t* codec)
{
    ngn_consumer_video_t* p_display = (ngn_consumer_video_t*)self;
    int ret = 0;
    
    if (!p_display || !codec || !codec->plugin) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Invalid parameter");
        return -1;
    }
    
    tsk_safeobj_lock(p_display);
    
    TMEDIA_CONSUMER(p_display)->video.fps = TMEDIA_CODEC_VIDEO(codec)->in.fps;
    TMEDIA_CONSUMER(p_display)->video.in.width = TMEDIA_CODEC_VIDEO(codec)->in.width;
    TMEDIA_CONSUMER(p_display)->video.in.height = TMEDIA_CODEC_VIDEO(codec)->in.height;
    
    NGN_VIDEO_CONSUMER_DEBUG_INFO("prepare(w=%zu, h=%zu, fps=%u)", TMEDIA_CONSUMER(p_display)->video.in.width,TMEDIA_CONSUMER(p_display)->video.in.height, TMEDIA_CONSUMER(p_display)->video.fps);
    
    ret = [p_display->display prepareWithWidth:(int)TMEDIA_CONSUMER(p_display)->video.in.width height:(int)TMEDIA_CONSUMER(p_display)->video.in.height fps:(int)TMEDIA_CONSUMER(p_display)->video.fps];
    if (ret != 0) {
        goto bail;
    }
    
bail:
    tsk_safeobj_unlock(p_display);
    
    return ret;
}

static int ngn_consumer_video_start(tmedia_consumer_t* self)
{
    ngn_consumer_video_t* p_display = (ngn_consumer_video_t*)self;
    int ret = 0;
    
    NGN_VIDEO_CONSUMER_DEBUG_INFO("start");
    
    if (!p_display) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Invalid parameter");
        return -1;
    }
    
    tsk_safeobj_lock(p_display);
    
    if (![p_display->display isPrepared]) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Not prepared");
        ret = -2;
        goto bail;
    }
    
    if ([p_display->display isStarted]) {
        NGN_VIDEO_CONSUMER_DEBUG_INFO("Already started");
        goto bail;
    }
    
    ret = [p_display->display start];
    
bail:
    tsk_safeobj_unlock(p_display);
    return ret;
}

static int ngn_consumer_video_consume(tmedia_consumer_t* self, const void* buffer, tsk_size_t size, const tsk_object_t* proto_hdr)
{
    ngn_consumer_video_t* p_display = (ngn_consumer_video_t*)self;
    if (p_display && buffer && size) {
        tsk_safeobj_lock(p_display);
        int ret = [p_display->display consumeFrame:buffer size:(unsigned)size];
        tsk_safeobj_unlock(p_display);
        return ret;
    }
    return -1;
}

static int ngn_consumer_video_pause(tmedia_consumer_t* self)
{
    ngn_consumer_video_t* p_display = (ngn_consumer_video_t*)self;
    int ret = 0;
    
    NGN_VIDEO_CONSUMER_DEBUG_INFO("pause");
    
    if (!p_display) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Invalid parameter");
        return -1;
    }
    
    tsk_safeobj_lock(p_display);
    
    ret = [p_display->display pause];
    
bail:
    tsk_safeobj_unlock(p_display);
    return ret;
}

static int ngn_consumer_video_stop(tmedia_consumer_t* self)
{
    ngn_consumer_video_t* p_display = (ngn_consumer_video_t*)self;
    int ret = 0;
    
    NGN_VIDEO_CONSUMER_DEBUG_INFO("stop");
    
    if (!p_display) {
        NGN_VIDEO_CONSUMER_DEBUG_ERROR("Invalid parameter");
        return -1;
    }
    
    tsk_safeobj_lock(p_display);
    
    if (![p_display->display isStarted]) {
        goto bail;
    }
    
    ret = [p_display->display stop];
    
bail:
    tsk_safeobj_unlock(p_display);
    return ret;
}

/* constructor */
static tsk_object_t* ngn_consumer_video_ctor(tsk_object_t * self, va_list * app)
{
    ngn_consumer_video_t *p_display = (ngn_consumer_video_t *)self;
    if (p_display) {
        /* init base */
        tmedia_consumer_init(TMEDIA_CONSUMER(p_display));
#if TARGET_OS_IPHONE /* opengl-es */
        TMEDIA_CONSUMER(p_display)->video.display.chroma = tmedia_chroma_yuv420p;
#else
        TMEDIA_CONSUMER(p_display)->video.display.chroma = tmedia_chroma_rgb32;
#endif
        // Display doesn't need resizing and we want to always match the viewport
        TMEDIA_CONSUMER(p_display)->video.display.auto_resize = tsk_true;
        
        /* init self */
        p_display->display = [[SCDisplayOSX alloc] initWithConsumer:TMEDIA_CONSUMER(p_display)];
        if (!p_display->display) {
            return tsk_null;
        }
        tsk_safeobj_init(p_display);
    }
    return self;
}
/* destructor */
static tsk_object_t* ngn_consumer_video_dtor(tsk_object_t * self)
{
    ngn_consumer_video_t *p_display = (ngn_consumer_video_t *)self;
    if (p_display) {
        /* stop */
        ngn_consumer_video_stop(TMEDIA_CONSUMER(p_display));
        
        /* deinit base */
        tmedia_consumer_deinit(TMEDIA_CONSUMER(p_display));
        /* deinit self */
        if (p_display->display) {
            [p_display->display release];
            p_display->display = nil;
        }
        tsk_safeobj_deinit(p_display);
        
        NGN_VIDEO_CONSUMER_DEBUG_INFO("*** destroyed ***");
    }
    
    return self;
}
/* object definition */
static const tsk_object_def_t ngn_consumer_video_def_s = {
    sizeof(ngn_consumer_video_t),
    ngn_consumer_video_ctor,
    ngn_consumer_video_dtor,
    tsk_null,
};
/* plugin definition*/
static const tmedia_consumer_plugin_def_t ngn_consumer_video_plugin_def_s = {
    &ngn_consumer_video_def_s,
    
    tmedia_video,
    "OSX/iOS video consumer",
    
    ngn_consumer_video_set,
    ngn_consumer_video_prepare,
    ngn_consumer_video_start,
    ngn_consumer_video_consume,
    ngn_consumer_video_pause,
    ngn_consumer_video_stop
};
const tmedia_consumer_plugin_def_t *ngn_consumer_video_plugin_def_t = &ngn_consumer_video_plugin_def_s;