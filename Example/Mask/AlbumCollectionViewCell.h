//
//  AlbumCollectionViewCell.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef void(^AlbumCollectionViewCellAction)(PHAsset *asset);

@interface AlbumCollectionViewCell : UICollectionViewCell

/// 行数
@property (nonatomic, assign) NSInteger row;
/// 相片
@property (nonatomic, strong) PHAsset *asset;
/// 选中事件
@property (nonatomic, copy) AlbumCollectionViewCellAction selectPhotoAction;
/// 是否被选中
@property (nonatomic, assign) BOOL isSelect;

#pragma mark - 加载图片
-(void)loadImage:(NSIndexPath *)indexPath;

@end
