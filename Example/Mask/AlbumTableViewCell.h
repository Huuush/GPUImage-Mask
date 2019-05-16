//
//  AlbumTableViewCell.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumModel;

@interface AlbumTableViewCell : UITableViewCell

/// 相册
@property (nonatomic, strong) AlbumModel *albumModel;
/// 行数
@property (nonatomic, assign) NSInteger row;

/// 加载图片
-(void)loadImage:(NSIndexPath *)index;

@end
