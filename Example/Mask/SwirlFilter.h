//
//  SwirlFilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/13.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "GPUImageFilter.h"

@interface SwirlFilter : GPUImageFilter
{
    GLint intensityUniform, filterColorUniform;
}

@property(readwrite, nonatomic) CGFloat intensity;
@property(readwrite, nonatomic) GPUVector4 color;

- (void)setColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;

@end
