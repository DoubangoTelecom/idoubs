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

#import "iOSGLView.h"

#define DEFAULT_FPS 15

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

#define GL_RENDER(IGNORE_ANIMATING) \
if((!_animating && !IGNORE_ANIMATING) || [UIApplication sharedApplication].applicationState != UIApplicationStateActive){ \
return; \
} \
 \
@synchronized(self){ \
    glClear(GL_COLOR_BUFFER_BIT); \
     \
    glViewport(0, 0, _textureWidth, _textureHeight); \
     \
    if(_buffer && _bufferSize){ \
        glActiveTexture(GL_TEXTURE0); \
        glBindTexture(GL_TEXTURE_2D, _lumaTexture); \
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _bufferWidth, _bufferHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, _buffer); \
        glUniform1i(_lumaUniform, 0); \
         \
        glActiveTexture(GL_TEXTURE1); \
        glBindTexture(GL_TEXTURE_2D, _chromaTextureU); \
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _bufferWidth>>1, _bufferHeight>>1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &_buffer[_bufferWidth * _bufferHeight]); \
        glUniform1i(_chromaUniformU, 1); \
        glActiveTexture(GL_TEXTURE2); \
        glBindTexture(GL_TEXTURE_2D, _chromaTextureV); \
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _bufferWidth>>1, _bufferHeight>>1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &_buffer[(_bufferWidth * _bufferHeight) + ((_bufferWidth>>1) * (_bufferHeight>>1)) ]); \
        glUniform1i(_chromaUniformV, 2); \
    } \
     \
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0); \
     \
    [_context presentRenderbuffer:GL_RENDERBUFFER]; \
} \



@interface iOSGLView(Private)
- (void)setupLayer;
- (void)setupContext;
- (void)setupRenderBuffer; 
- (void)setupFrameBuffer;
- (void)render:(CADisplayLink*)displayLink;

- (void)setupVBOs;

- (GLuint)compileShader:(const char*)shaderSource withType:(GLenum)shaderType;
- (void)compileShaders;

@end

@implementation iOSGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
        _animating = GL_FALSE;
    }
    return self;
}

-(void)setFps:(GLuint)fps{
    
    _fps = fps;
}

-(void)startAnimation{
    
    @synchronized(self){
        if(!_animating){
            if(!_displayLink){
                _displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(render:)] retain];
            }
            [_displayLink setFrameInterval:(60/_fps)];
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            _animating = GL_TRUE;
        }
    }
}

-(void)stopAnimation{
    
    @synchronized(self){
        if(_animating){
            [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            _animating = GL_FALSE;
            if(_context && _buffer && _bufferSize){
                [EAGLContext setCurrentContext:_context];
                memset(_buffer, 0, _bufferSize);
                GL_RENDER(GL_TRUE);
            }
        }
    }
}

-(void) setOrientation: (UIDeviceOrientation)orientation{
   @synchronized(self){
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
    }
}

-(void)setBufferYUV:(const uint8_t*)buffer andWidth:(uint)bufferWidth andHeight:(uint)bufferHeight{
    
    if(_animating){
        if(!_buffer || (_bufferWidth != bufferWidth) || (_bufferHeight != bufferHeight)){
            @synchronized(self){
                _bufferSize = ((bufferWidth * bufferHeight * 3) >> 1);
                _buffer = (uint8_t*)realloc(_buffer, _bufferSize);
                if(!_buffer){
                    return;
                }
                _bufferWidth = bufferWidth;
                _bufferHeight = bufferHeight;
            }
        }
        
        memcpy(_buffer, buffer, _bufferSize);
    }
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
    
    int shaderSourceLen = strlen(shaderSource);
    glShaderSource(shaderHandle, 1, &shaderSource, &shaderSourceLen);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
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
        NSLog(@"%@", messageString);
        exit(1);
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
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
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
    GL_RENDER(GL_FALSE);
}

- (void)dealloc
{
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
    
    if(_buffer){
        free(_buffer), _buffer = nil;
    }
    [super dealloc];
}

@end

#endif /* TARGET_OS_IPHONE */
