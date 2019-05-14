//
//  ContrastFilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/14.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface ContrastFilter : GPUImageFilter

{
    GLint contrastUniform;
}

/** Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
 */
@property(readwrite, nonatomic) CGFloat contrast;

@end
