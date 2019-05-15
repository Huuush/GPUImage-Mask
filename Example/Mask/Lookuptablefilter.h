//
//  Lookuptablefilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/15.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface Lookuptablefilter : GPUImageTwoInputFilter
{
    GLint intensityUniform;
}
@property(readwrite, nonatomic) CGFloat intensity;

@end
