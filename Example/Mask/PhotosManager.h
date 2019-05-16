//
//  PhotosManager.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PhotoModel.h"
#import <Foundation/Foundation.h>

@interface PhotosManager : NSObject

/**
 显示相册
 
 @param viewController 跳转的控制器
 @param maxCount 最大选择图片数量
 @param albumArray 返回的图片数组
 */
+(void)showPhotosManager:(UIViewController *)viewController withMaxImageCount:(NSInteger)maxCount withAlbumArray:(void(^)(NSMutableArray<PhotoModel *> *albumArray))albumArray;

@end
