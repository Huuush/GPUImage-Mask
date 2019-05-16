//
//  PhotoManager.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoModel;

typedef void(^PhotoMangerChoiceCountChange)(NSInteger choiceCount);


@interface PhotoManager : NSObject

/// 可选的的最大数量
@property (nonatomic, assign) NSInteger maxCount;
/// 已选数量
@property (nonatomic, assign) NSInteger choiceCount;
/// 已选图片
@property (nonatomic, strong) NSMutableArray<PhotoModel *> *photoModelList;
/// 选择图片变化
@property (nonatomic, copy) PhotoMangerChoiceCountChange choiceCountChange;

/**
 单例
 
 @return 返回对象
 */
+(PhotoManager*)standardPhotoManger;

@end
