//
//  EffectShowController.m
//  Mask_Example
//
//  Created by Harry on 2019/5/12.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#define APP_SCREEN_BOUNDS   [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT   (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH    (APP_SCREEN_BOUNDS.size.width)
#define APP_STATUS_FRAME    [UIApplication sharedApplication].statusBarFrame
#import "EffectShowController.h"
#import "PhotoViewController.h"

@interface EffectShowController ()
@property(nonatomic, strong) UIButton *backBotton;
@property(nonatomic, strong) UIButton *saveBotton;
@property(nonatomic, strong) UIImageView *ShowView;
@end

@implementation EffectShowController

- (void)viewDidLoad {
    [super viewDidLoad];
    _ShowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-130)];
    _ShowView.image = _EffectedImg;
    _ShowView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_ShowView];
    
    self.backBotton = [[UIButton alloc] init];
    //    self.PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBotton setBackgroundImage:[UIImage imageNamed:@"Focus Icon"] forState:UIControlStateNormal];
    [self.view addSubview:_backBotton];
    [_backBotton addTarget:self action:@selector(backToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.backBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(67);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-70);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    self.saveBotton = [[UIButton alloc] init];
    //    self.PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveBotton setBackgroundImage:[UIImage imageNamed:@"Focus Icon"] forState:UIControlStateNormal];
    [self.view addSubview:_saveBotton];
    [_saveBotton addTarget:self action:@selector(savePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.saveBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-67);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-70);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    
}

- (void) backToCamera {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) savePicture{
    
}
#pragma mark - 保存到相册和数据库  注意要根据不同tag换滤镜
- (void) saveToAblum {
    //根据拍摄时的屏幕方向，调整图片方向
//    switch (self.orientation) {
//        case UIDeviceOrientationLandscapeLeft:
//            _image = [self.customFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
//            break;
//        case UIDeviceOrientationLandscapeRight:
//            _image = [self.customFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationDown];
//            break;
//        case UIDeviceOrientationPortraitUpsideDown:
//            _image = [self.customFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationLeft];
//            break;
//        default:
//            break;
//    }
    
    [self saveImageToPhotoAlbum:_EffectedImg];
    
#pragma mark - 预览相册区域加载最新照片
    
}

#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
