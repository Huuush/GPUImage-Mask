//
//  SwirlFilter.m
//  Mask_Example
//
//  Created by Harry on 2019/5/13.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "SwirlFilter.h"

NSString *const kSwirlFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;

 
 //原色
 void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = outputColor;
}
 );

@implementation SwirlFilter

//@synthesize center = _center;
//@synthesize radius = _radius;
//@synthesize angle = _angle;

- (instancetype)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kSwirlFragmentShaderString]))
    {
        return nil;
    }
//    radiusUniform = [filterProgram uniformIndex:@"radius"];
//    angleUniform = [filterProgram uniformIndex:@"angle"];
//    centerUniform = [filterProgram uniformIndex:@"center"];
//
//    self.radius = 0.5;
//    self.angle = 1.0;
//    self.center = CGPointMake(0.5, 0.5);
    
    return self;
}

#pragma mark -
#pragma mark Accessors

//- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
//{
//    [super setInputRotation:newInputRotation atIndex:textureIndex];
//    [self setCenter:self.center];
//}
//
//- (void)setRadius:(CGFloat)newValue;
//{
//    _radius = newValue;
//    [GPUImageContext useImageProcessingContext];
//    [self setFloat:_radius forUniform:radiusUniform program:filterProgram];
//}
//
//- (void)setAngle:(CGFloat)newValue;
//{
//    _angle = newValue;
//    
//    [self setFloat:_angle forUniform:angleUniform program:filterProgram];
//}
//
//- (void)setCenter:(CGPoint)newValue;
//{
//    _center = newValue;
//    
//    CGPoint rotatedPoint = [self rotatedPoint:_center forRotation:inputRotation];
//    [self setPoint:rotatedPoint forUniform:centerUniform program:filterProgram];
//}

@end
