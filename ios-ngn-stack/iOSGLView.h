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
#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface iOSGLView : UIView
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    CADisplayLink* _displayLink;
    GLuint _program;
    GLuint _renderBuffer;
    GLuint _framebuffer;
    GLuint _positionSlot;
    GLuint _texCoordSlot;
    GLuint _lumaUniform, _chromaUniformU, _chromaUniformV;
    GLuint _lumaTexture, _chromaTextureU, _chromaTextureV;
    CGFloat _screenWidth, _screenHeight;
    GLint _textureWidth, _textureHeight;
    GLuint _vertexShader, _fragmentShader;
    uint _bufferWidth, _bufferHeight, _bufferSize;
    uint8_t* _buffer;
    GLboolean _animating;
    GLuint _fps;
}

-(void)setFps:(GLuint)fps;
-(void)startAnimation;
-(void)stopAnimation;
-(void)setOrientation:(UIDeviceOrientation)orientation;
-(void)setBufferYUV:(const uint8_t*)buffer andWidth:(uint)bufferWidth andHeight:(uint)bufferHeight;

@end

#endif /* #if TARGET_OS_IPHONE */