//
//  CompressImg.h
//  Mask_Example
//
//  Created by Harry on 2019/5/14.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompressImg : NSObject
NS_ASSUME_NONNULL_BEGIN

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;


@end

NS_ASSUME_NONNULL_END
