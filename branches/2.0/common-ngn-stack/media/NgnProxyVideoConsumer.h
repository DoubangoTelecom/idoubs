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
#	import <UIKit/UIKit.h>
#	import <AVFoundation/AVFoundation.h>
#   import "iOSGLView.h"
#elif TARGET_OS_MAC
#	import "NgnVideoView.h"
#	import <Cocoa/Cocoa.h>
#	import <QuartzCore/CoreVideo.h>
#	import <QuartzCore/CIContext.h>
#endif

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
	BOOL mFlip;
	
#if TARGET_OS_IPHONE
	iOSGLView* mDisplay;
#elif TARGET_OS_MAC
    CGContextRef mBitmapContext;
	NSObject<NgnVideoView>* mDisplay;
#endif
}

-(NgnProxyVideoConsumer*) initWithId: (uint64_t)identifier andConsumer:(const ProxyVideoConsumer *)_consumer;

#if TARGET_OS_IPHONE
-(void) setDisplay: (iOSGLView*)display;
#elif TARGET_OS_MAC
-(void) setDisplay: (NSObject<NgnVideoView>*)display;
#endif

@end
