//
//  SaturationFilter.m
//  Mask_Example
//
//  Created by Harry on 2019/5/15.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "SaturationFilter.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageSaturationFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float saturation;
 
 // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
     lowp vec3 greyScaleColor = vec3(luminance);
     
     gl_FragColor = vec4(mix(greyScaleColor, textureColor.rgb, saturation), textureColor.w);
     
 }
 );
#else
NSString *const kGPUImageSaturationFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float saturation;
 
 // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
 const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     float luminance = dot(textureColor.rgb, luminanceWeighting);
     vec3 greyScaleColor = vec3(luminance);
     
     gl_FragColor = vec4(mix(greyScaleColor, textureColor.rgb, saturation), textureColor.w);
     
 }
 );
#endif

@implementation SaturationFilter

@synthesize saturation = _saturation;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageSaturationFragmentShaderString]))
    {
        return nil;
    }
    
    saturationUniform = [filterProgram uniformIndex:@"saturation"];
    self.saturation = 2.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setSaturation:(CGFloat)newValue;
{
    _saturation = newValue;
    
    [self setFloat:_saturation forUniform:saturationUniform program:filterProgram];
}

@end
