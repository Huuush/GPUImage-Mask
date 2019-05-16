//
//  AlbumTableView.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlbumModel;

typedef void(^AlbumTableViewSelectAction)(AlbumModel *albumModel);
@interface AlbumTableView : UITableView

/// 相册数组
@property (nonatomic, strong) NSMutableArray<AlbumModel *> *assetCollectionList;
/// 选择的相册
@property (nonatomic, copy) AlbumTableViewSelectAction selectAction;

@end
