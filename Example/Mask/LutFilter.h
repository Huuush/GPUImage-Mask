//
//  LutFilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/12.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface LutFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}

@end
