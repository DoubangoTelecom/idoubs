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

#undef NGN_PRODUCER_HAS_VIDEO_CAPTURE
#define NGN_PRODUCER_HAS_VIDEO_CAPTURE (__IPHONE_OS_VERSION_MIN_REQUIRED >= 40000 && TARGET_OS_EMBEDDED)

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "media/NgnProxyPlugin.h"
#import "media/NgnCamera.h"

#include "tsk_mutex.h"
#include "tsk_list.h"

class ProxyVideoProducer;
class _NgnProxyVideoProducerCallback;

@interface NgnProxyVideoProducer : NgnProxyPlugin 
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
<AVCaptureVideoDataOutputSampleBufferDelegate>
#endif
{
	_NgnProxyVideoProducerCallback* _mCallback;
	const ProxyVideoProducer * _mProducer;
	
	int mWidth;
	int mHeight;
	int mFps;
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
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
	
#endif
}

-(NgnProxyVideoProducer*) initWithId: (uint64_t)identifier andProducer:(const ProxyVideoProducer *)_producer;
-(void)setPreview: (UIView*)preview;
#if NGN_PRODUCER_HAS_VIDEO_CAPTURE
-(void) setOrientation:(AVCaptureVideoOrientation)orientation;
-(void) toggleCamera;
#endif
@end

#endif /* TARGET_OS_IPHONE */
