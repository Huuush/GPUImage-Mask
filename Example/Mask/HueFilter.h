//
//  HueFilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface HueFilter : GPUImageFilter
{
    GLint hueAdjustUniform;
    
}
@property (nonatomic, readwrite) CGFloat hue;
@end
