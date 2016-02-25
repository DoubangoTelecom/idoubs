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
# import "NgnCamera.h"

#if TARGET_OS_IPHONE

//
//	Private
//
@interface NgnCamera (Private)

#if NGN_HAVE_VIDEO_CAPTURE
+ (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position;
#endif /* NGN_HAVE_VIDEO_CAPTURE */

@end /* NGN_HAVE_VIDEO_CAPTURE */

@implementation NgnCamera (Private)

#if NGN_HAVE_VIDEO_CAPTURE

+ (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras){
        if (device.position == position){
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#endif /* NGN_HAVE_VIDEO_CAPTURE */

@end


//
//	Default implementation
//
@implementation NgnCamera

#if NGN_HAVE_VIDEO_CAPTURE

+ (AVCaptureDevice *)frontFacingCamera{
    return [NgnCamera cameraAtPosition:AVCaptureDevicePositionFront];
}

+ (AVCaptureDevice *)backCamera{
    return [NgnCamera cameraAtPosition:AVCaptureDevicePositionBack];
}

#endif /* NGN_HAVE_VIDEO_CAPTURE */

+ (BOOL) setPreview: (UIView*)preview{
#if NGN_HAVE_VIDEO_CAPTURE
    static UIView* sPreview = nil;
    static AVCaptureSession* sCaptureSession = nil;
    
    if(preview == nil){
        // stop preview
        if(sCaptureSession && [sCaptureSession isRunning]){
            [sCaptureSession stopRunning];
        }
        // remove all sublayers
        if(sPreview){
            for(CALayer *ly in sPreview.layer.sublayers){
                if([ly isKindOfClass: [AVCaptureVideoPreviewLayer class]]){
                    [ly removeFromSuperlayer];
                    break;
                }
            }
        }
        return YES;
    }
    
    if (!sCaptureSession) {
        NSError *error = nil;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice: [NgnCamera frontFacingCamera] error:&error];
        if (!videoInput){
            NgnNSLog(@"NgnCamera", @"Failed to get video input: %@", (error && error.description) ? error.description : @"unknown");
            return NO;
        }
        
        sCaptureSession = [[AVCaptureSession alloc] init];
        [sCaptureSession addInput:videoInput];
    }
    
    // start capture if not already done or view did changed
    if (sPreview != preview || ![sCaptureSession isRunning]) {
        [sPreview release];
        sPreview = [preview retain];
        
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: sCaptureSession];
        previewLayer.frame = sPreview.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        BOOL orientationSupported = [[previewLayer connection] isVideoOrientationSupported];
#else
        BOOL orientationSupported = previewLayer.orientationSupported;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 */
        if (orientationSupported) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
            AVCaptureVideoOrientation newOrientation = [[previewLayer connection] videoOrientation];
#else
            AVCaptureVideoOrientation newOrientation = previewLayer.orientation;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 */
            switch ([UIDevice currentDevice].orientation) {
                case UIInterfaceOrientationPortrait: newOrientation = AVCaptureVideoOrientationPortrait; break;
                case UIInterfaceOrientationPortraitUpsideDown: newOrientation = AVCaptureVideoOrientationPortraitUpsideDown; break;
                case UIInterfaceOrientationLandscapeLeft: newOrientation = AVCaptureVideoOrientationLandscapeLeft; break;
                case UIInterfaceOrientationLandscapeRight: newOrientation = AVCaptureVideoOrientationLandscapeRight; break;
                default:
                case UIDeviceOrientationUnknown:
                case UIDeviceOrientationFaceUp:
                case UIDeviceOrientationFaceDown:
                    break;
            }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
            [previewLayer.connection setVideoOrientation:newOrientation];
#else
            previewLayer.orientation = newOrientation;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0 */
        }
        
        [sPreview.layer addSublayer: previewLayer];
        [sCaptureSession startRunning];
    }
    
    return YES;
#else
    return NO;
#endif /* NGN_HAVE_VIDEO_CAPTURE */
}

@end

#endif /* TARGET_OS_IPHONE */
