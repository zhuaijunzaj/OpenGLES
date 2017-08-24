//
//  ViewController.m
//  OpenGLES
//
//  Created by 朱爱俊 on 2017/8/24.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import "LearingView.h"
@interface ViewController ()<GLKViewDelegate>
@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) GLKBaseEffect* mEffect;
@property (nonatomic , strong) LearingView*   myView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myView = (LearingView*)self.view;
    
//    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    GLKView *view = (GLKView*)self.view;
//    view.delegate = self;
//    view.context = self.mContext;
//    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
//    [EAGLContext setCurrentContext:self.mContext];
//    
//    GLfloat squareVertextData[]=
//    {1,-0.5,0,1.0,0,
//    1,0.5,0,1,1,
//    0,0.5,0,0,1,
//     1,-0.5,0,1.0,0,
//    0,0.5,0,0,1.0,
//    0,-0.5,0,0,0,
//        0,-0.5,0,1,0,
//        0,0.5,0,0,0,
//        -1,0.5,0,0,1,
//        0,-0.5,0,1,0,
//        -1,0.5,0,0,1,
//        -1,-0.5,0,1,1,
//    };
//    GLuint buffer;
//    glGenBuffers(1, &buffer);
//    glBindBuffer(GL_ARRAY_BUFFER, buffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertextData), squareVertextData, GL_STATIC_DRAW);
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+0);
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+3);
//    
//    
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
//    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@(1)};
//    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
//    
//    self.mEffect = [[GLKBaseEffect alloc] init];
//    self.mEffect.texture2d0.enabled = GL_TRUE;
//    self.mEffect.texture2d0.name = textureInfo.name;
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 12);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
