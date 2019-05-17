//
//  editRawViewController.m
//  Mask_Example
//
//  Created by Harry on 2019/5/15.
//  Copyright © 2019年 Huuush. All rights reserved.
//
#define APP_SCREEN_BOUNDS   [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT   (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH    (APP_SCREEN_BOUNDS.size.width)
#define APP_STATUS_FRAME    [UIApplication sharedApplication].statusBarFrame

#import "editRawViewController.h"
#import "GPUImage.h"
#import "LutFilter.h"
#import "SwirlFilter.h"
#import "ContrastFilter.h"
#import "RGBFilter.h"
#import "SaturationFilter.h"

@interface editRawViewController ()
@property(nonatomic,strong) UIButton *shaderButton;
@property(nonatomic,strong) UIButton *lutButton;
@property(nonatomic,strong) UIButton *backButton;
@property(nonatomic,strong) UIButton *okButton;

@property (nonatomic, strong) GPUImageCropFilter *rawFilter;
@property (nonatomic, strong) LutFilter *LutFilter;
@property (nonatomic, strong) ContrastFilter *ContrastFilter;
@property (nonatomic, strong) RGBFilter *RGBFilter;
@property (nonatomic, strong) SaturationFilter *SaturationFilter;

@end

@implementation editRawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageView];
    self.imageView.image = _imagefrompick;
    [self loadUI];
    
    // Do any additional setup after loading the view.
}

-(void) loadUI{
    self.backButton = [[UIButton alloc] init];
    //    self.PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.view addSubview:_backButton];
    //    [self.feedBack prepare];
    [_backButton addTarget:self action:@selector(backToAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(30);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-20);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];
    
    self.shaderButton = [[UIButton alloc] init];
    //    self.PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shaderButton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.view addSubview:_shaderButton];
    //    [self.feedBack prepare];
    [_shaderButton addTarget:self action:@selector(addLut) forControlEvents:UIControlEventTouchUpInside];
    [self.shaderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backButton.mas_right).mas_offset(20);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-20);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];
    
    self.lutButton = [[UIButton alloc] init];
    //    self.PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lutButton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.view addSubview:_lutButton];
    //    [self.feedBack prepare];
    [_lutButton addTarget:self action:@selector(addLut) forControlEvents:UIControlEventTouchUpInside];
    [self.lutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.shaderButton.mas_right).mas_offset(20);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-20);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];
    
    //第三个滤镜
    
    self.okButton = [[UIButton alloc] init];
    //    self.PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.okButton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.view addSubview:_okButton];
    //    [self.feedBack prepare];
    [_okButton addTarget:self action:@selector(completeedit) forControlEvents:UIControlEventTouchUpInside];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lutButton.mas_right).mas_offset(90);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-20);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];
    
}

-(void) addLut {
    GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:self.imagefrompick];
    [self.LutFilter forceProcessingAtSizeRespectingAspectRatio:self.imagefrompick.size];
    [sourcePicture addTarget:self.LutFilter];
    [sourcePicture processImage];
    [self.LutFilter useNextFrameForImageCapture];
    UIImage *newImage = [self.LutFilter imageFromCurrentFramebuffer];
    _imagefrompick = newImage;
    _imageView.image = newImage;
}

-(void) completeedit{
    // pop 网络传输
}

-(UIImageView *) imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-130)];
    }
    return _imageView;
}

- (LutFilter *)LutFilter {
    if (!_LutFilter) {
        _LutFilter = [[LutFilter alloc] init];
    }
    return _LutFilter;
}

- (GPUImageCropFilter *) rawFilter{
    if (!_rawFilter) {
        _rawFilter = [[GPUImageCropFilter alloc] init];
    }
    return _rawFilter;
}

- (RGBFilter * ) RGBFilter{
    if (!_RGBFilter) {
        _RGBFilter = [[RGBFilter alloc] init];
    }
    return _RGBFilter;
}

-(SaturationFilter *) SaturationFilter{
    if (!_SaturationFilter) {
        _SaturationFilter = [[SaturationFilter alloc] init];
    }
    return _SaturationFilter;
}

-(void) backToAlbum{
    
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
