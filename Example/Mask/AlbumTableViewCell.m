//
//  AlbumTableViewCell.m
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "AlbumModel.h"
#import "PhotoModel.h"

#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface AlbumTableViewCell()

/// 相册首图
@property (nonatomic, strong) UIImageView *albumImageView;
/// 相册名
@property (nonatomic, strong) UILabel *albumNameLabel;
/// 相册数量
@property (nonatomic, strong) UILabel *albumNumberLabel;

@end

@implementation AlbumTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupCell];
    }
    
    return self;
}

/// 设置相册列表样式
-(void)setupCell {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.albumImageView.frame = CGRectMake(15, 5, 70, 70);
    self.albumNameLabel.frame = CGRectMake(95, 15, 200, 20);
    self.albumNumberLabel.frame = CGRectMake(95, 40, 200, 20);
}

#pragma mark - Set方法
-(void)setAlbumModel:(AlbumModel *)albumModel {
    _albumModel = albumModel;
    
    self.albumNameLabel.text = albumModel.collectionTitle;
    self.albumNumberLabel.text = albumModel.collectionNumber;
}

/// 加载图片
-(void)loadImage:(NSIndexPath *)index {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    __weak typeof(self) weakSelf = self;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.albumModel.firstAsset targetSize:CGSizeMake(kScreenWidth / 2, kScreenWidth / 2) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (weakSelf.row == index.row) {
            weakSelf.albumImageView.image = result;
        }
    }];
}

#pragma mark - Get方法
-(UIImageView *)albumImageView {
    if (!_albumImageView) {
        _albumImageView = [[UIImageView alloc] init];
        _albumImageView.contentMode = UIViewContentModeScaleAspectFill;
        _albumImageView.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_albumImageView];
    }
    
    return _albumImageView;
}

-(UILabel *)albumNameLabel {
    if (!_albumNameLabel) {
        _albumNameLabel = [[UILabel alloc] init];
        _albumNameLabel.font = [UIFont systemFontOfSize:16];
        
        [self.contentView addSubview:_albumNameLabel];
    }
    
    return _albumNameLabel;
}

-(UILabel *)albumNumberLabel {
    if (!_albumNumberLabel) {
        _albumNumberLabel = [[UILabel alloc] init];
        _albumNumberLabel.font = [UIFont systemFontOfSize:12];
        _albumNumberLabel.textColor = [UIColor lightTextColor];
        
        [self.contentView addSubview:_albumNumberLabel];
    }
    
    return _albumNumberLabel;
}
@end
