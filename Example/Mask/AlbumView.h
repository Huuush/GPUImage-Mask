//
//  AlbumView.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumModel;

@interface AlbumView : UIView

/**
 显示相册列表
 
 @param assetCollectionList 相册对象列表
 @param navigationBarMaxY navigationBarMaxY的最大值
 @param complete 返回结果
 */
+(void)showAlbumView:(NSMutableArray<AlbumModel *> *)assetCollectionList navigationBarMaxY:(CGFloat)navigationBarMaxY complete:(void(^)(AlbumModel *albumModel))complete;

@end
