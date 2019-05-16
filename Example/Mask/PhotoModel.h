//
//  PhotoModel.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^PhotoModelAction)(void);

@interface PhotoModel : NSObject

/// 相片
@property (nonatomic, strong) PHAsset *asset;
/// 高清图
@property (nonatomic, strong) UIImage *highDefinitionImage;
/// 获取图片成功事件
@property (nonatomic, copy) PhotoModelAction getPictureAction;


@end
