/* Copyright (c) 2012, Doubango Telecom. All rights reserved.
 *
 * Contact: Tech <tech(at)doubango(dot)org>
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
#ifndef IOS_NGN_IOS_GLVIEW_H
#define IOS_NGN_IOS_GLVIEW_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSNgnConfig.h"

@protocol iOSGLViewDelegate <NSObject>
@optional
-(void) glviewAnimationStarted;
-(void) glviewAnimationStopped;
-(void) glviewVideoSizeChanged;
-(void) glviewViewportSizeChanged;
@end

@interface iOSGLView : UIView {
}

-(void)setFps:(GLuint)fps;
-(void)startAnimation;
-(void)stopAnimation;
-(void)setOrientation:(UIDeviceOrientation)orientation  __attribute__ ((deprecated));
-(void)setBufferYUV:(const uint8_t*)buffer width:(uint)bufferWidth height:(uint)bufferHeight;
-(void)setDelegate:(id<iOSGLViewDelegate>)delegate;
-(void)setPAR:(int)numerator denominator:(int)denominator;
-(void)setFullscreen:(BOOL)fullscreen;
@property(readonly) int viewportX;
@property(readonly) int viewportY;
@property(readonly) int viewportWidth;
@property(readonly) int viewportHeight;
@property(readonly) int videoWidth;
@property(readonly) int videoHeight;
@property(readonly) BOOL animating;
@end

#endif /* IOS_NGN_IOS_GLVIEW_H */
