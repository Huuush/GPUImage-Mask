//
//  AlbumModel.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AlbumModel : NSObject

/// 相册
@property (nonatomic, strong) PHAssetCollection *collection;
/// 第一个相片
@property (nonatomic, strong) PHAsset *firstAsset;
/// 第一个相片
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;
/// 相册名
@property (nonatomic, copy) NSString *collectionTitle;
/// 总数
@property (nonatomic, copy) NSString *collectionNumber;
/// 选中的图片
@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectRows;


@end
