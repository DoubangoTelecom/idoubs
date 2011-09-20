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
 */
#import "UIVideoView.h"

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>

@implementation UIVideoView

+ (NSOpenGLPixelFormat *)defaultPixelFormat
{
    static NSOpenGLPixelFormat *pf;
	
    if (pf == nil)
    {		
		static const NSOpenGLPixelFormatAttribute attr[] = {
			NSOpenGLPFAAccelerated,
			NSOpenGLPFANoRecovery,
			NSOpenGLPFAFullScreen,
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFAColorSize, 32,
			0
		};
		
		pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr];
    }
	
    return pf;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	lock = [[NSRecursiveLock alloc] init];
}

- (void)dealloc
{
    [contextOptions release];
    [image release];
    [context release];
	[lock release];
	
    [super dealloc];
}

- (void)setContextOptions:(NSDictionary *)dict
{
    [contextOptions release];
    contextOptions = [dict retain];
	
    [context release];
    context = nil;
}

-(void)setCurrentImage:(CGImageRef)imageRef
{
	[lock lock];
	
	[image release];
	image = [[CIImage alloc] initWithCGImage:imageRef];
	
	[lock unlock];

	[self setNeedsDisplay:YES];
}

- (void)setFullScreen:(BOOL)fullscreen
{
	if(fullscreen){
		[[self openGLContext] makeCurrentContext];
		[[self openGLContext] setFullScreen];
	}
}

- (void)clear
{
	[lock lock];
	
	[image release];
	image = nil;
	
	[lock unlock];
	
	[self setNeedsDisplay:YES];
}

- (void)prepareOpenGL
{
    GLint parm = 1;
	
    [[self openGLContext] setValues:&parm forParameter:NSOpenGLCPSwapInterval];
	
    glDisable (GL_ALPHA_TEST);
    glDisable (GL_DEPTH_TEST);
    glDisable (GL_SCISSOR_TEST);
    glDisable (GL_BLEND);
    glDisable (GL_DITHER);
    glDisable (GL_CULL_FACE);
    glColorMask (GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask (GL_FALSE);
    glStencilMask (0);
    glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
    glHint (GL_TRANSFORM_HINT_APPLE, GL_FASTEST);
}

- (void)viewBoundsDidChange:(NSRect)bounds
{
    /* For subclasses. */
}

- (void)updateMatrices
{
    NSRect r = [self bounds];
	
    if (!NSEqualRects (r, lastBounds))
    {
		[[self openGLContext] update];
		
		glViewport (0, 0, r.size.width, r.size.height);
		
		glMatrixMode (GL_PROJECTION);
		glLoadIdentity ();
		glOrtho (0, r.size.width, 0, r.size.height, -1, 1);
		
		glMatrixMode (GL_MODELVIEW);
		glLoadIdentity ();
		
		lastBounds = r;
		
		[self viewBoundsDidChange:r];
    }
}

- (void)drawRect:(NSRect)r
{
    CGRect ir, rr;
    CGImageRef cgImage;
	
    [[self openGLContext] makeCurrentContext];
	
    if (context == nil)
    {
		NSOpenGLPixelFormat *pf;
		
		pf = [self pixelFormat];
		if (pf == nil)
			pf = [[self class] defaultPixelFormat];
		
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_6
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		context = [[CIContext contextWithCGLContext:CGLGetCurrentContext() 
										 pixelFormat:(CGLPixelFormatObj)[pf CGLPixelFormatObj] 
										  colorSpace:colorSpace 
											 options:[NSDictionary dictionaryWithObjectsAndKeys:
													  (id)colorSpace,kCIContextOutputColorSpace,
													  (id)colorSpace,kCIContextWorkingColorSpace,nil]
					 ] retain];
		CGColorSpaceRelease(colorSpace);
#else
		context = [[CIContext contextWithCGLContext:CGLGetCurrentContext()
										 pixelFormat:(CGLPixelFormatObj)[pf CGLPixelFormatObj]
											 options:contextOptions] retain];
#endif
    }
	
    ir = CGRectIntegral (*(CGRect *)&r);
	
	[lock lock];
	
    if ([NSGraphicsContext currentContextDrawingToScreen]){
		[self updateMatrices];
		
		if (image != nil){
			// (w/h)=ratio=>
			// 1) h=w/ratio
			// and
			// 2) w=h*ratio
			float w = [self bounds].size.width;
			float h = [self bounds].size.height;
			float ratio = [image extent].size.width / [image extent].size.height;
			float _w = (w/ratio) > h ? (h * ratio) : w;
			float _h = (_w/ratio) > h ? h : (_w/ratio);
			rr = CGRectMake([self bounds].size.width > _w ? ([self bounds].size.width - _w)/2 : 0.f, 
							[self bounds].size.height > _h ? ([self bounds].size.height - _h)/2 : 0.f, 
							_w, 
							_h);
		
		}
		else {
			rr = CGRectMake([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width, [self bounds].size.height);
		}
		
		glScissor (ir.origin.x, ir.origin.y, ir.size.width, ir.size.height);
		glEnable (GL_SCISSOR_TEST);
		
		glClear (GL_COLOR_BUFFER_BIT);
		
		if (image != nil){
			[context drawImage:image inRect:rr fromRect:[image extent]];
		}
		
		glDisable (GL_SCISSOR_TEST);
		
		//glFlush();//single buffer
		glSwapAPPLE();//double buffer
    }
    else{
		if (image != nil){
			cgImage = [context createCGImage:image fromRect:ir];
			
			if (cgImage != NULL){
				CGContextDrawImage ((CGContext*)[[NSGraphicsContext currentContext]
									 graphicsPort], ir, cgImage);
				CGImageRelease (cgImage);
			}
		}
    }
	
	[lock unlock];
}

@end
