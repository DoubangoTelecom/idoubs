/* Copyright (C) 2010-2015, Mamadou Diop.
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
#if TARGET_OS_IPHONE

#import "iOSNgnConfig.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NgnCamera : NSObject {
	
}

#if NGN_HAVE_VIDEO_CAPTURE
+ (AVCaptureDevice *)frontFacingCamera;
+ (AVCaptureDevice *)backCamera;
#endif /* NGN_PRODUCER_HAS_VIDEO_CAPTURE */

+ (BOOL) setPreview: (UIView*)preview;

@end

#endif /* TARGET_OS_IPHONE */
