//
//  OrangeLUTFilter.h
//  Mask_Example
//
//  Created by Harry on 2019/5/23.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface OrangeLUTFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}

@end
