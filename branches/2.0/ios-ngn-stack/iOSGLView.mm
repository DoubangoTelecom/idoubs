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

#import <Foundation/Foundation.h>
#import "iOSGLView.h"
#import "iOSNgnConfig.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define DEFAULT_FPS 60

#define kTAG @"iOSGLView"

typedef struct {
    GLint left;
    GLint top;
    GLint right;
    GLint bottom;
}
RECT;

typedef struct {
    GLint numerator;
    GLint denominator;
}
PAR; // Pixel Aspect Ratio

typedef struct {
    float Position[3];
    float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0},{1,1}},
    {{1, 1, 0},{1,0}},
    {{-1, 1, 0},{0,0}},
    {{-1, -1, 0},{0,1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

#define SOURCE_SHADER_VERTEX \
"attribute vec4 position;" \
"attribute vec2 texCoord;" \
"" \
"varying vec2 texCoordVarying;" \
"" \
"void main()" \
"{" \
"    gl_Position = position;" \
"    texCoordVarying = texCoord;" \
"}" \


#define SOURCE_SHADER_FRAGMENT \
"precision mediump float;" \
"varying vec2 texCoordVarying;" \
"" \
"uniform sampler2D SamplerY; " \
"uniform sampler2D SamplerU;" \
"uniform sampler2D SamplerV;" \
"" \
"const mat3 yuv2rgb = mat3(1, 0, 1.2802,1, -0.214821, -0.380589,1, 2.127982, 0);" \
"" \
"void main() {    " \
"    vec3 yuv = vec3(1.1643 * (texture2D(SamplerY, texCoordVarying).r - 0.0625)," \
"                    texture2D(SamplerU, texCoordVarying).r - 0.5," \
"                    texture2D(SamplerV, texCoordVarying).r - 0.5);" \
"    vec3 rgb = yuv * yuv2rgb;    " \
"    gl_FragColor = vec4(rgb, 1.0);" \
"} " \


static inline GLint Width(const RECT& r);
static inline GLint Height(const RECT& r);
static inline GLint MulDiv(GLint number, GLint numerator, GLint denominator);
static inline RECT CorrectAspectRatio(const RECT& src, const PAR& srcPAR);
static inline RECT LetterBoxRect(const RECT& rcSrc, const RECT& rcDst);

@interface iOSGLView(Private)
- (void)initialize;
- (void)orientationChanged:(NSNotification *)notification;
- (void)setupLayer;
- (void)setupContext;
- (void)setupRenderBuffer;
- (void)setupFrameBuffer;
- (void)render:(CADisplayLink*)displayLink;

- (void)setupVBOs;

- (GLuint)compileShader:(const char*)shaderSource withType:(GLenum)shaderType;
- (void)compileShaders;
- (void)updateSizes;

@end

@implementation iOSGLView {
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
    GLint _viewportX, _viewportY, _viewportW, _viewportH;
    GLint _parNumerator, _parDenominator;
    GLuint _vertexShader, _fragmentShader;
    uint _bufferWidth, _bufferHeight, _bufferSize;
    uint8_t* _buffer;
    GLboolean _animating;
    GLboolean _stopping;
    GLuint _fps;
    GLfloat _aspectRatio;
    GLboolean _fullScreen;
    id<iOSGLViewDelegate> _delegate;
}

- (void)initialize {
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight);
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    [self setupLayer];
    [self setupContext];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self compileShaders];
    [self setupVBOs];
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    
    glGenTextures(1, &_lumaTexture);
    glBindTexture(GL_TEXTURE_2D, _lumaTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glGenTextures(1, &_chromaTextureU);
    glBindTexture(GL_TEXTURE_2D, _chromaTextureU);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glGenTextures(2, &_chromaTextureV);
    glBindTexture(GL_TEXTURE_2D, _chromaTextureV);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
    
    _fps = DEFAULT_FPS;
    _buffer = nil;
    _bufferWidth = _bufferHeight = _bufferSize = 0;
    _viewportX = _viewportY = _viewportW = _viewportH = 0;
    _parNumerator = _parDenominator = 1;
    _animating = GL_FALSE;
    _stopping = GL_FALSE;
    _fullScreen = GL_TRUE; // for backward compatibility
    
    [self addObserver:self forKeyPath:@"bounds" options:0 context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"bounds"]) {
        [self updateSizes];
    }
}

-(void)orientationChanged:(NSNotification *)notification {
    @synchronized(self) {
        [self updateSizes];
    }
}

-(void)setFps:(GLuint)fps {
    _fps = fps;
}

-(void)startAnimation {
    @synchronized(self) {
        if (!_animating) {
            if (!_displayLink) {
                _displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(render:)] retain];
            }
#if 0
            [_displayLink setFrameInterval:(60/_fps)];
#endif
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            _animating = GL_TRUE;
            if (_delegate && [_delegate respondsToSelector:@selector(glviewAnimationStarted)]) {
                [_delegate glviewAnimationStarted];
            }
        }
    }
}

-(void)stopAnimation {
    @synchronized(self) {
        if (_animating) {
            [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            _animating = GL_FALSE;
            _stopping = GL_TRUE;
            if (_context && _buffer && _bufferSize) {
                [EAGLContext setCurrentContext:_context];
                memset(_buffer, 0, _bufferSize);
                [self render:_displayLink];
            }
            _stopping = GL_FALSE;
            if (_delegate && [_delegate respondsToSelector:@selector(glviewAnimationStopped)]) {
                [_delegate glviewAnimationStopped];
            }
        }
    }
}

-(void) setOrientation: (UIDeviceOrientation)orientation {
    // @deprecated
}

-(void)setBufferYUV:(const uint8_t*)buffer width:(uint)bufferWidth height:(uint)bufferHeight {
    @synchronized(self) {
        if (_animating) {
            if (!_buffer || (_bufferWidth != bufferWidth) || (_bufferHeight != bufferHeight)) {
                _bufferSize = ((bufferWidth * bufferHeight * 3) >> 1);
                _buffer = (uint8_t*)realloc(_buffer, _bufferSize);
                if (!_buffer) {
                    _bufferSize = 0;
                    return;
                }
                _bufferWidth = bufferWidth;
                _bufferHeight = bufferHeight;
                [self updateSizes];
                if (_delegate && [_delegate respondsToSelector:@selector(glviewVideoSizeChanged)]) {
                    [_delegate glviewVideoSizeChanged];
                }
            }
            memcpy(_buffer, buffer, _bufferSize);
        }
    }
}

-(void)setDelegate:(id<iOSGLViewDelegate>)delegate {
    @synchronized(self) {
        [_delegate release];
        _delegate = [delegate retain];
    }
}

-(void)setPAR:(int)numerator denominator:(int)denominator {
    @synchronized(self) {
        if (_parNumerator <= 0 || _parDenominator <= 0) {
            NgnNSLog(kTAG, @"Invalid PAR:%d/%d", numerator, denominator);
            assert(0);
        }
        _parNumerator = numerator;
        _parDenominator = denominator;
    }
}

-(void)setFullscreen:(BOOL)fullscreen {
    @synchronized(self) {
        GLboolean _newVal = fullscreen ? GL_TRUE : GL_FALSE;
        if (_newVal != _fullScreen) {
            _fullScreen = _newVal;
            [self updateSizes];
        }
    }
}

-(int) viewportX {
    return _viewportX;
}

-(int) viewportY {
    return _viewportY;
}

-(int) viewportWidth {
    return _viewportW;
}

-(int) viewportHeight {
    return _viewportH;
}

-(int) videoWidth {
    return (int)_bufferWidth;
}

-(int) videoHeight {
    return (int)_bufferHeight;
}

-(BOOL) animating {
    return _animating;
}

- (void)setupVBOs {
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

- (GLuint)compileShader:(const char*)shaderSource withType:(GLenum)shaderType {
    GLuint shaderHandle = glCreateShader(shaderType);
    
    int shaderSourceLen = (int)strlen(shaderSource);
    glShaderSource(shaderHandle, 1, &shaderSource, &shaderSourceLen);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NgnNSLog(kTAG, @"%@", messageString);
        assert(0);
    }
    
    return shaderHandle;
}

- (void)compileShaders {
    _vertexShader = [self compileShader:SOURCE_SHADER_VERTEX withType:GL_VERTEX_SHADER];
    _fragmentShader = [self compileShader:SOURCE_SHADER_FRAGMENT withType:GL_FRAGMENT_SHADER];
    
    _program = glCreateProgram();
    glAttachShader(_program, _vertexShader);
    glAttachShader(_program, _fragmentShader);
    glLinkProgram(_program);
    
    GLint linkSuccess;
    glGetProgramiv(_program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NgnNSLog(kTAG, @"%@", messageString);
        assert(0);
    }
    
    glUseProgram(_program);
    
    _positionSlot = glGetAttribLocation(_program, "position");
    glEnableVertexAttribArray(_positionSlot);
    
    _texCoordSlot = glGetAttribLocation(_program, "texCoord");
    glEnableVertexAttribArray(_texCoordSlot);
    
    _lumaUniform = glGetUniformLocation(_program, "SamplerY");
    _chromaUniformU = glGetUniformLocation(_program, "SamplerU");
    _chromaUniformV = glGetUniformLocation(_program, "SamplerV");
}

- (void)updateSizes {
    @synchronized(self) {
        [EAGLContext setCurrentContext:_context];
        
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, 0);
        glDeleteRenderbuffers(1, &_renderBuffer);
        
        glGenRenderbuffers(1, &_renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_textureWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_textureHeight);
        
        // Viewport
        GLint newVpW, newVpH, newVpX, newVpY;
        if (_fullScreen) {
            newVpW = _textureWidth;
            newVpH = _textureHeight;
            newVpX = 0;
            newVpY = 0;
        }
        else {
            // Aspect Ratio
            RECT rcSrc = { 0, 0, _bufferWidth, _bufferHeight };
            PAR parSrc = { _parNumerator, _parDenominator };
            rcSrc = CorrectAspectRatio(rcSrc, parSrc);
            RECT rcDst = { 0, 0, _textureWidth, _textureHeight };
            RECT rcViewport = LetterBoxRect(rcSrc, rcDst);
            
            newVpW = Width(rcViewport) ;
            newVpH = Height(rcViewport);
            newVpX = rcViewport.left;
            newVpY = rcViewport.top;
        }
        
        if (newVpW != _viewportW || newVpH != _viewportH || newVpX != _viewportX || newVpY != _viewportY) {
            _viewportW = newVpW;
            _viewportH = newVpH;
            _viewportX = newVpX;
            _viewportY = newVpY;
            
            if (_delegate && [_delegate respondsToSelector:@selector(glviewViewportSizeChanged)]) {
                [_delegate glviewViewportSizeChanged];
            }
        }
    }
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NgnNSLog(kTAG, @"Failed to initialize OpenGLES 2.0 context");
        assert(0);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NgnNSLog(kTAG, @"Failed to set current OpenGL context");
        assert(0);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_textureWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_textureHeight);
}

- (void)render:(CADisplayLink*)displayLink {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    @synchronized(self) {
        if (!_animating && !_stopping) {
            return;
        }
        
        glClear(GL_COLOR_BUFFER_BIT);
        glViewport(_viewportX, _viewportY, _viewportW, _viewportH);
        
        if (_buffer && _bufferSize) {
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, _lumaTexture);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _bufferWidth, _bufferHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, _buffer);
            glUniform1i(_lumaUniform, 0);
            
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, _chromaTextureU);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _bufferWidth>>1, _bufferHeight>>1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &_buffer[_bufferWidth * _bufferHeight]);
            glUniform1i(_chromaUniformU, 1);
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, _chromaTextureV);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _bufferWidth>>1, _bufferHeight>>1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &_buffer[(_bufferWidth * _bufferHeight) + ((_bufferWidth>>1) * (_bufferHeight>>1)) ]);
            glUniform1i(_chromaUniformV, 2);
        }
        
        glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
        
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

- (void)dealloc {
    [EAGLContext setCurrentContext:_context];
    [self stopAnimation];
    
    glDeleteRenderbuffers(1, &_renderBuffer);
    glDeleteRenderbuffers(1, &_framebuffer);
    
    glDeleteShader(_fragmentShader);
    glDeleteShader(_vertexShader);
    
    glDeleteTextures(1, &_lumaTexture);
    glDeleteTextures(1, &_chromaTextureU);
    glDeleteTextures(1, &_chromaTextureV);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    [_displayLink release];
    [_context release], _context = nil;
    
    [_delegate release], _delegate = nil;
    
    if (_buffer) {
        free(_buffer), _buffer = nil;
    }
    [super dealloc];
}

@end /* iOSGLView */

static inline GLint Width(const RECT& r)
{
    return r.right - r.left;
}

static inline GLint Height(const RECT& r)
{
    return r.bottom - r.top;
}

static inline GLint MulDiv(GLint number, GLint numerator, GLint denominator)
{
    if (denominator != 0) {
        GLint64 x = (GLint64)number * (GLint64)numerator;
        x /= (GLint64)denominator;
        return (GLint)x;
    }
    return 0;
}

//-----------------------------------------------------------------------------
// CorrectAspectRatio
//
// Converts a rectangle from the source's pixel aspect ratio (PAR) to 1:1 PAR.
// Returns the corrected rectangle.
//
// For example, a 720 x 486 rect with a PAR of 9:10, when converted to 1x1 PAR,
// is stretched to 720 x 540.
// Copyright (C) Microsoft
//-----------------------------------------------------------------------------

static inline RECT CorrectAspectRatio(const RECT& src, const PAR& srcPAR)
{
    // Start with a rectangle the same size as src, but offset to the origin (0,0).
    RECT rc = {0, 0, src.right - src.left, src.bottom - src.top};
    
    if ((srcPAR.numerator != 1) || (srcPAR.denominator != 1)) {
        // Correct for the source's PAR.
        
        if (srcPAR.numerator > srcPAR.denominator) {
            // The source has "wide" pixels, so stretch the width.
            rc.right = MulDiv(rc.right, srcPAR.numerator, srcPAR.denominator);
        }
        else if (srcPAR.numerator < srcPAR.denominator) {
            // The source has "tall" pixels, so stretch the height.
            rc.bottom = MulDiv(rc.bottom, srcPAR.denominator, srcPAR.numerator);
        }
        // else: PAR is 1:1, which is a no-op.
    }
    return rc;
}

//-------------------------------------------------------------------
// LetterBoxDstRect
//
// Takes a src rectangle and constructs the largest possible
// destination rectangle within the specifed destination rectangle
// such thatthe video maintains its current shape.
//
// This function assumes that pels are the same shape within both the
// source and destination rectangles.
// Copyright (C) Microsoft
//-------------------------------------------------------------------

static inline RECT LetterBoxRect(const RECT& rcSrc, const RECT& rcDst)
{
    // figure out src/dest scale ratios
    int iSrcWidth  = Width(rcSrc);
    int iSrcHeight = Height(rcSrc);
    
    int iDstWidth  = Width(rcDst);
    int iDstHeight = Height(rcDst);
    
    int iDstLBWidth;
    int iDstLBHeight;
    
    if (MulDiv(iSrcWidth, iDstHeight, iSrcHeight) <= iDstWidth) {
        
        // Column letter boxing ("pillar box")
        
        iDstLBWidth  = MulDiv(iDstHeight, iSrcWidth, iSrcHeight);
        iDstLBHeight = iDstHeight;
    }
    else {
        
        // Row letter boxing.
        
        iDstLBWidth  = iDstWidth;
        iDstLBHeight = MulDiv(iDstWidth, iSrcHeight, iSrcWidth);
    }
    
    
    // Create a centered rectangle within the current destination rect
    
    RECT rc;
    
    rc.left = rcDst.left + ((iDstWidth - iDstLBWidth) >> 1);
    rc.top = rcDst.top + ((iDstHeight - iDstLBHeight) >> 1);
    rc.right = rc.left + iDstLBWidth;
    rc.bottom = rc.top + iDstLBHeight;
    
    return rc;
}