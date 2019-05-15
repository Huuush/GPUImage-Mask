//
//  RGBFilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/15.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface RGBFilter : GPUImageFilter
{
    GLint redUniform;
    GLint greenUniform;
    GLint blueUniform;
}

@property (readwrite, nonatomic) CGFloat red;
@property (readwrite, nonatomic) CGFloat green;
@property (readwrite, nonatomic) CGFloat blue;
@end
