//
//  SaturationFilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/15.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface SaturationFilter : GPUImageFilter
{
    GLint saturationUniform;
}
//饱和度[0.0~2.0] 默认为1.0
@property(readwrite, nonatomic) CGFloat saturation;

@end
