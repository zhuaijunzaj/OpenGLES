//
//  LearingView.m
//  OpenGLES
//
//  Created by 朱爱俊 on 2017/8/24.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "LearingView.h"
#import <OpenGLES/ES2/gl.h>

@interface LearingView ()
@property (nonatomic, strong) EAGLContext* myContext;
@property (nonatomic, strong) CAEAGLLayer* myEagLayer;
@property (nonatomic, assign) GLuint       myProgram;
@property (nonatomic, assign) GLuint       myColorRenderBuffer;
@property (nonatomic, assign) GLuint       myColorFrameBuffer;
@end
@implementation LearingView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void)setupLayer
{
    self.myEagLayer = (CAEAGLLayer*)self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.myEagLayer.opaque = YES;
    self.myEagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@(NO),kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupLayer];
    
    [self setupContext];
    
    [self destoryRenderBuffer];
    
    [self setupRenderBuffer];
    
    [self setuoFrameBuffer];
    
    [self render];

}
-(void)render
{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x*scale,
               self.frame.origin.y*scale,
               self.frame.size.width*scale,
               self.frame.size.height*scale);
    NSString *vertfile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString *fragfile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"];
    
    self.myProgram = [self loadShaders:vertfile frag:fragfile];
    glLinkProgram(self.myProgram);
    
    GLint linkSuccess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE){
        return;
    }
    glUseProgram(self.myProgram);
    
    GLfloat attrArr[]={
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,

    };
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint postion = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(postion, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat*)*5, NULL);
    glEnableVertexAttribArray(postion);
    
    GLuint textCoor = glGetAttribLocation(self.myProgram,"textCoordinate");
    glVertexAttribPointer(postion, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat*)*5, (float*)NULL+3);
    glEnableVertexAttribArray(textCoor);
    
    [self setupContext];
    
    GLuint rorate = glGetUniformLocation(self.myProgram, "rotateMatrix");
    float radians = 90 * M_PI / 180.0f;
    float s = sin(radians);
    float c = cos(radians);
    
    //z轴旋转矩阵
    GLfloat zRotation[16] = { //
        c, -s, 0, 0.2, //
        s, c, 0, 0,//
        0, 0, 1.0, 0,//
        0.0, 0, 0, 1.0//
    };
    glUniformMatrix4fv(rorate, 1, GL_FALSE, zRotation);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}
-(GLuint)loadShaders:(NSString*)vert frag:(NSString*)frag
{
    GLuint verShaders,fragShaders;
    GLint program = glCreateProgram();
    [self complieShader:&verShaders type:GL_VERTEX_SHADER file:vert];
    [self complieShader:&fragShaders type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShaders);
    glAttachShader(program, fragShaders);
    return program;
}
-(void)complieShader:(GLuint*)shader type:(GLenum)type file:(NSString*)file
{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar*)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}
-(void)setupContext
{
    self.myContext =[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.myContext];
}
-(void)destoryRenderBuffer
{
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
}
-(void)setupRenderBuffer
{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}
-(void)setuoFrameBuffer
{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorFrameBuffer);
}

-(void)setupTexture
{
    CGImageRef spriteImage = [[UIImage imageNamed:@"for_test"] CGImage];
    if (!spriteImage) return;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte *spriteData = (GLubyte*)calloc(width*height*4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0,GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glBindTexture(GL_TEXTURE_2D, 0);
    free(spriteData);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
