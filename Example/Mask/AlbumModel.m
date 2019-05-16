//
//  AlbumModel.m
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "AlbumModel.h"

@implementation AlbumModel

-(void)setCollection:(PHAssetCollection *)collection {
    _collection = collection;
    
    if ([collection.localizedTitle isEqualToString:@"All Photos"]) {
        self.collectionTitle = @"全部相册";
    } else {
        self.collectionTitle = collection.localizedTitle;
    }
    
    self.collectionTitle = collection.localizedTitle;
    
    // 获得某个相簿中的所有PHAsset对象
    self.assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    
    if (self.assets.count > 0) {
        self.firstAsset = self.assets[0];
    }
    self.collectionNumber = [NSString stringWithFormat:@"%ld", self.assets.count];
}

#pragma mark - Get方法
-(NSMutableArray<NSNumber *> *)selectRows {
    if (!_selectRows) {
        _selectRows = [NSMutableArray array];
    }
    
    return _selectRows;
}

@end
