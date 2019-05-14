//
//  CollectionViewCell.m
//  Masks
//
//  Created by Harry on 2019/5/1.
//  Copyright © 2019年 Harry. All rights reserved.
//

#define APP_SCREEN_BOUNDS   [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT   (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH    (APP_SCREEN_BOUNDS.size.width)
#define APP_STATUS_FRAME    [UIApplication sharedApplication].statusBarFrame

#import "CollectionViewCell.h"
#import "AFNetworking.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    //获取到self的frame
    self = [super initWithFrame:frame];
//    if (self != nil) {
    
    self.itemImage = [[UIImageView alloc] init];
    self.itemImage.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    UIImage * i = [UIImage imageNamed:@"IMG_1319.JPG"];
    _itemImage.image = i;
    [self addSubview:self.itemImage];
    return self;
}

@end
