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
#import "YBImageBrowser.h"

@interface CollectionViewCell() <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    
}
@property (nonatomic, strong) UIScrollView *firstView;
@property (nonatomic, strong) YYAnimatedImageView *mainImageView;

@end

@implementation CollectionViewCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    // Initialization code
//
//}

- (instancetype)initWithFrame:(CGRect)frame{
    //获取到self的frame
    self = [super initWithFrame:frame];
    
//    [self.contentView addSubview:self.firstView];
//    [self.firstView addSubview:self.mainImageView];
//    [self addGesture];
    
    self.itemImage = [[UIImageView alloc] init];
    self.itemImage.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    
    [self addSubview:self.itemImage];
    return self;
}

//#pragma mark - gesture
//- (void)addGesture {
//    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapSingle:)];
//    tapSingle.numberOfTapsRequired = 1;
//    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapDouble:)];
//    tapDouble.numberOfTapsRequired = 2;
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPan:)];
//    pan.maximumNumberOfTouches = 1;
//    pan.delegate = self;
//    
//    [tapSingle requireGestureRecognizerToFail:tapDouble];
//    [tapSingle requireGestureRecognizerToFail:pan];
//    [tapDouble requireGestureRecognizerToFail:pan];
//    
//    [self.firstView addGestureRecognizer:tapSingle];
//    [self.firstView addGestureRecognizer:tapDouble];
//    [self.firstView addGestureRecognizer:pan];
//}
//
//#pragma mark - getter
//
//- (UIScrollView *) firstView {
//    if (!_firstView) {
//        _firstView.backgroundColor = [UIColor redColor];
//        _firstView = [UIScrollView new];
//        _firstView.delegate = self;
//        _firstView.showsHorizontalScrollIndicator = NO;
//        _firstView.showsVerticalScrollIndicator = NO;
//        _firstView.decelerationRate = UIScrollViewDecelerationRateFast;
//        _firstView.maximumZoomScale = 1;
//        _firstView.minimumZoomScale = 1;
//        _firstView.alwaysBounceHorizontal = NO;
//        _firstView.alwaysBounceVertical = NO;
//        _firstView.layer.masksToBounds = NO;
//        if (@available(iOS 11.0, *)) {
//            _firstView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
//    }
//    return _firstView;
//}
//
//- (YYAnimatedImageView *) mainImageView {
//    if (!_mainImageView) {
//        _mainImageView = [YYAnimatedImageView new];
//        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _mainImageView.layer.masksToBounds = YES;
//    }
//    return _mainImageView;
//}

//- (YBImageBrowserProgressView *)progressView {
//    if (!_progressView) {
//        _progressView = [YBImageBrowserProgressView new];
//    }
//    return _progressView;
//}
//
//- (UIImageView *)tailoringImageView {
//    if (!_tailoringImageView) {
//        _tailoringImageView = [UIImageView new];
//        _tailoringImageView.contentMode = UIViewContentModeScaleAspectFit;
//    }
//    return _tailoringImageView;
//}

@end
