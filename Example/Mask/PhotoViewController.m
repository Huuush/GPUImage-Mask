//
//  PhotoViewController.m
//  Masks
//
//  Created by Harry on 2019/4/16.
//  Copyright © 2019年 Harry. All rights reserved.
//

#define APP_SCREEN_BOUNDS   [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT   (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH    (APP_SCREEN_BOUNDS.size.width)
#define APP_STATUS_FRAME    [UIApplication sharedApplication].statusBarFrame

typedef NS_ENUM(NSInteger, CameraFlashMode) {
    
    CameraFlashModeAuto,  /**< 自动模式 */
    
    CameraFlashModeOff,  /**< 闪光灯关闭模式 */
    
    CameraFlashModeOn,  /**< 闪光灯打开模式 */

};


#import "PhotoViewController.h"
#import "CollectionViewController.h"
#import "MotionManager.h"
#import <CoreMotion/CoreMotion.h>
#import "AFNetworking.h"
#import "EffectShowController.h"
#import "editRawViewController.h"
#import "LutFilter.h"
#import "SwirlFilter.h"
#import "ContrastFilter.h"
#import "RGBFilter.h"
#import "SaturationFilter.h"

#import "HueFilter.h"

@interface PhotoViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,AVCapturePhotoCaptureDelegate>

@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;
//输出照片
@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
//@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) GPUImageStillCamera *captureCamera;
@property (strong, nonatomic) UIButton *PhotoButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *ChangeCamera;
@property (strong, nonatomic) UIButton *EffectButton;
@property (strong, nonatomic) UIButton *CancelButton;
@property (strong, nonatomic) UIButton *saveToAlbumButton;
@property (strong, nonatomic) UIButton *rawButton;
@property (strong, nonatomic) UIButton *ShaderButton;
@property (strong, nonatomic) UIButton *lutButton;
@property (strong, nonatomic) UIButton *halftoneButton;
@property (strong, nonatomic) UIButton *temButton;

@property (nonatomic, strong) UIView *EffectListView;
//@property (nonatomic)UIImageView *imageView;
@property (nonatomic, strong) GPUImageView *preLayerView;
@property (nonatomic)UIView *focusView; //对焦
@property (nonatomic)BOOL isflashOn;
@property (nonatomic, strong) UIImpactFeedbackGenerator * feedBack;

@property (nonatomic, strong) GPUImageCropFilter *rawFilter;
@property (nonatomic, strong) LutFilter *LutFilter;
@property (nonatomic, strong) ContrastFilter *ContrastFilter;
@property (nonatomic, strong) RGBFilter *RGBFilter;
@property (nonatomic, strong) SaturationFilter *SaturationFilter;
@property (nonatomic, strong) GPUImageHalftoneFilter *HalftoneFilter;


@property (nonatomic, strong) HueFilter *hueFilter;
/* 获取屏幕方向 */
@property (nonatomic, assign) UIDeviceOrientation orientation;
/* 陀螺仪管理 */
@property (nonatomic, strong) MotionManager *motionManager;

@property (nonatomic)BOOL canCa;

@end

@implementation PhotoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    _canCa = [self canUserCamear];
    self.image = [UIImage new];
    if (_canCa) {
        
        [self customCamera];
        [self customUI];
    
    }else{
        return;
    }
    
    
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - 整体UI布局
//自定义界面
- (void)customUI{
    
    self.PhotoButton = [[UIButton alloc] init];
//    self.PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.PhotoButton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.view addSubview:_PhotoButton];
    [self.feedBack prepare];
    [_PhotoButton addTarget:self action:@selector(shotPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.PhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-20);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];
    
    //聚焦动画
    _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.preLayerView addSubview:_focusView];
    _focusView.hidden = YES;
    
    self.ChangeCamera =[[UIButton alloc] init];
//    self.ChangeCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.ChangeCamera setBackgroundImage:[UIImage imageNamed:@"Change Camera Icon"] forState:UIControlStateNormal];
    [_ChangeCamera addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_ChangeCamera];
    [self.ChangeCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-30);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    self.preAlbum = [[UIButton alloc] init];
    [self.preAlbum setBackgroundImage:[UIImage imageNamed:@"Latest Image Icon"] forState:UIControlStateNormal];
    [_preAlbum addTarget:self action:@selector(inToAlbum) forControlEvents:UIControlEventTouchUpInside];
    _preAlbum.layer.cornerRadius = 5;
    _preAlbum.layer.borderWidth = 3.0f;
    _preAlbum.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:_preAlbum];
    [self.preAlbum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-30);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    self.flashButton = [[UIButton alloc] init];
    //设置记住flashmode
    [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(FlashOn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(20);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(10);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    self.EffectButton = [[UIButton alloc] init];
    [self.EffectButton setBackgroundImage:[UIImage imageNamed:@"滤镜"] forState:UIControlStateNormal];
    [_EffectButton addTarget:self action:@selector(OpenEffectlist) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_EffectButton];
    [self.EffectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-20);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(20);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
}
#pragma mark - 初始化相机
- (void)customCamera{
    self.view.backgroundColor = [UIColor blackColor];
    self.captureCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    self.captureCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.captureCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    self.preLayerView = [[GPUImageView alloc] init];
    [self.view addSubview:_preLayerView];
    [self.preLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(0);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(40);
        make.width.mas_equalTo(APP_SCREEN_WIDTH);
        make.height.mas_equalTo(APP_SCREEN_HEIGHT-130);
    }];
    [self.preLayerView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    self.preLayerView.userInteractionEnabled = YES;
    // 初始化滤镜
    self.effectTag = 1;
    
//    GPUImageColorMatrixFilter *halftone = [[GPUImageColorMatrixFilter alloc] init];//kexing  jia!!!
////    halftone.distance = 0.1;
////    halftone.slope = 0.2;
//    halftone.colorMatrix = (GPUMatrix4x4){
//        {1.f, 0.f, 0.5f, 0.f},
//        {0.f, 1.f, 0.4f, 0.f},
//        {0.4f, 0.f, 1.f, 0.f},
//        {0.f, 0.f, 0.f, 1.f}
//    };
    [_captureCamera addTarget:self.rawFilter];
//    [self.rawFilter addTarget:halftone];
//    [halftone addTarget:_preLayerView];
    [self.rawFilter addTarget:_preLayerView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.preLayerView addGestureRecognizer:tapGesture];

    
    
}

#pragma mark - 闪光灯失效
- (void)FlashOn{

}


- (void)changeCamera{

    [self.captureCamera rotateCamera];

}

//- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    for ( AVCaptureDevice *device in devices )
//        if ( device.position == position ) return device;
//    return nil;
//}

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    NSLog(@"dianji");
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
    self.EffectListView.hidden = YES;
}


- (void)focusAtPoint:(CGPoint)point{
    
    CGSize size = self.view.bounds.size;
    //关键
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.captureCamera.inputCamera lockForConfiguration:&error]) {
        
        if ([self.captureCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.captureCamera.inputCamera setFocusPointOfInterest:focusPoint];
            [self.captureCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        if ([self.captureCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {
            [self.captureCamera.inputCamera setExposurePointOfInterest:focusPoint];
            [self.captureCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        [self.captureCamera.inputCamera unlockForConfiguration];
        
        //对焦图片
//        UIImage * focusImage = [UIImage imageNamed:@"Focus Icon.png"];
//        _focusView.layer.contents = (id) focusImage.CGImage;
//        // 如果需要背景透明加上下面这句
//        _focusView.layer.backgroundColor = [UIColor clearColor].CGColor;
        
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
    
}

#pragma mark - GPUImage拍照
-(void) shotPhoto{
    NSLog(@"hhh");

    [self.feedBack impactOccurred];

    if (self.effectTag == 1)
    {
        [self.captureCamera capturePhotoAsImageProcessedUpToFilter:self.rawFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
//                //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
//                [self.motionManager startMotionManager:^(NSInteger orientation) {
//                self.orientation = orientation;
//                NSLog(@"设备方向：%ld",orientation);
//                }];
            _image = processedImage;
            EffectShowController *evc = [[EffectShowController alloc] init];
            evc.EffectedImg = _image;
            evc.effectTag = _effectTag;

            [self.navigationController pushViewController:evc animated:YES];
        }];
    }
    else if(self.effectTag == 2)
    {

        [self.captureCamera capturePhotoAsImageProcessedUpToFilter:self.ContrastFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            //                //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
            //                [self.motionManager startMotionManager:^(NSInteger orientation) {
            //                self.orientation = orientation;
            //                NSLog(@"设备方向：%ld",orientation);
            //                }];
            _image = processedImage;
            EffectShowController *evc = [[EffectShowController alloc] init];
            evc.EffectedImg = _image;
            evc.effectTag = _effectTag;

            [self.navigationController pushViewController:evc animated:YES];
        }];
    }
    else if(self.effectTag == 3)
    {
        [self.captureCamera capturePhotoAsImageProcessedUpToFilter:self.LutFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            //                //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
            //                [self.motionManager startMotionManager:^(NSInteger orientation) {
            //                self.orientation = orientation;
            //                NSLog(@"设备方向：%ld",orientation);
            //                }];
            _image = processedImage;
            EffectShowController *evc = [[EffectShowController alloc] init];
            evc.EffectedImg = _image;
            evc.effectTag = _effectTag;

            [self.navigationController pushViewController:evc animated:YES];
        }];
    }
    else if(self.effectTag == 4)
    {

        [self.captureCamera capturePhotoAsImageProcessedUpToFilter:self.HalftoneFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            //                //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
            //                [self.motionManager startMotionManager:^(NSInteger orientation) {
            //                self.orientation = orientation;
            //                NSLog(@"设备方向：%ld",orientation);
            //                }];
            _image = processedImage;
            EffectShowController *evc = [[EffectShowController alloc] init];
            evc.EffectedImg = _image;
            evc.effectTag = _effectTag;
            [self.navigationController pushViewController:evc animated:YES];
        }];
    }
    
    [self.captureCamera stopCameraCapture];
    
}

#pragma mark - 滤镜listview
- (void) OpenEffectlist {
    [self.preLayerView addSubview:self.EffectListView];
    
    [self.EffectListView addSubview:self.rawButton];
    [self.rawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.EffectListView.mas_left).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(2);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    [self.EffectListView addSubview:self.ShaderButton];
    [self.ShaderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rawButton.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(2);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    [self.EffectListView addSubview:self.lutButton];
    [self.lutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.ShaderButton.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(2);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(30);
    }];
    [self.EffectListView addSubview:self.halftoneButton];
    [self.halftoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lutButton.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(2);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    [self.EffectListView addSubview:self.temButton];
    [self.temButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.halftoneButton.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(2);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    if (_EffectListView.hidden == NO) {
        _EffectListView.hidden = YES;
    }
    else{
        _EffectListView.hidden = NO;
    }
}

-(void) inToAlbum{
    CollectionViewController *cvc = [[CollectionViewController alloc] init];
    cvc.effectTag = _effectTag;
    [self presentViewController:cvc animated:YES completion:nil];
}


#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 100) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
}

#pragma mark - lazyload 滤镜

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

-(SaturationFilter *) SaturationFilter{
    if (!_SaturationFilter) {
        _SaturationFilter = [[SaturationFilter alloc] init];
    }
    return _SaturationFilter;
}

-(GPUImageHalftoneFilter *) HalftoneFilter{
    if (!_HalftoneFilter) {
        _HalftoneFilter = [GPUImageHalftoneFilter new];
    }
    return _HalftoneFilter;
}

- (UIView *) EffectListView {
    if(!_EffectListView){
        _EffectListView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 30)];
        _EffectListView.backgroundColor = [UIColor blackColor];
    }
    return _EffectListView;
}

- (UIImpactFeedbackGenerator *) feedBack{
    if (!_feedBack) {
        _feedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return _feedBack;
}

- (UIButton *) rawButton{
    if (!_rawButton) {
        _rawButton = [UIButton new];
        [_rawButton setTitle:@"无滤镜" forState:UIControlStateNormal];
        _rawButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rawButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_rawButton addTarget:self action:@selector(openRaw) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rawButton;
}

- (UIButton *) ShaderButton{
    if (!_ShaderButton) {
        _ShaderButton = [UIButton new];
        [_ShaderButton setTitle:@"黑白" forState:UIControlStateNormal];
        _ShaderButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_ShaderButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_ShaderButton addTarget:self action:@selector(openShader) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ShaderButton;
}

- (UIButton *) lutButton{
    if (!_lutButton) {
        _lutButton = [UIButton new];
        [_lutButton setTitle:@"富士·胶片" forState:UIControlStateNormal];
        _lutButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_lutButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_lutButton addTarget:self action:@selector(openLutFilter) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lutButton;
}

- (UIButton *) halftoneButton{
    if (!_halftoneButton) {
        _halftoneButton = [UIButton new];
        [_halftoneButton setTitle:@"半色调" forState:UIControlStateNormal];
        _halftoneButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_halftoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_halftoneButton addTarget:self action:@selector(openhalftone) forControlEvents:UIControlEventTouchUpInside];
    }
    return _halftoneButton;
}

- (UIButton *) temButton{
    if (!_temButton) {
        _temButton = [UIButton new];
        [_temButton setTitle:@"色温" forState:UIControlStateNormal];
        _temButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_temButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_temButton addTarget:self action:@selector(opentem) forControlEvents:UIControlEventTouchUpInside];
    }
    return _temButton;
}
- (MotionManager *)motionManager {
    if(!_motionManager) {
        _motionManager = [[MotionManager alloc] init];
    }
    return _motionManager;
}

#pragma mark - 选择滤镜
- (void) openRaw {
    self.effectTag = 1;
    self.rawButton.selected = !self.rawButton.selected;
    self.ShaderButton.selected = NO;
    self.lutButton.selected = NO;
    self.halftoneButton.selected = NO;
    self.temButton.selected = NO;
    
    [self.rawButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_feedBack impactOccurred];
    [self.captureCamera removeAllTargets];
    [_captureCamera addTarget:self.rawFilter];
    [self.rawFilter addTarget:_preLayerView];
}

- (void) openShader {
    self.effectTag = 2;
    self.ShaderButton.selected = !self.ShaderButton.selected;
    self.rawButton.selected = NO;
    self.lutButton.selected = NO;
    self.halftoneButton.selected = NO;
    self.temButton.selected = NO;
    
    [self.ShaderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_feedBack impactOccurred];
    [self.captureCamera removeAllTargets];
    GPUImageGrayscaleFilter * grayfliter = [[GPUImageGrayscaleFilter alloc] init];
    _ContrastFilter = [[ContrastFilter alloc] init];
    [_captureCamera addTarget:grayfliter];
    [grayfliter addTarget:_ContrastFilter];
    [_ContrastFilter addTarget:_preLayerView];
}

- (void) openLutFilter{
    self.effectTag = 3;
    self.lutButton.selected = !self.lutButton.selected;
    self.rawButton.selected = NO;
    self.ShaderButton.selected = NO;
    self.halftoneButton.selected = NO;
    self.temButton.selected = NO;
    
    [self.lutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_feedBack impactOccurred];
    [self.captureCamera removeAllTargets];
    [self.captureCamera addTarget:self.LutFilter];
    [self.LutFilter addTarget:_preLayerView];
}

- (void) openhalftone{
    self.effectTag = 4;
    self.halftoneButton.selected = !self.halftoneButton.selected;
    self.rawButton.selected = NO;
    self.ShaderButton.selected = NO;
    self.lutButton.selected = NO;
    self.temButton.selected = NO;
    
    [self.halftoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_feedBack impactOccurred];
    [self.captureCamera removeAllTargets];
//    self.HalftoneFilter = [GPUImageHalftoneFilter new];
    [self.captureCamera addTarget:self.HalftoneFilter];
//    [self.HalftoneFilter addTarget:self.ContrastFilter];
//    self.ContrastFilter.contrast = 1.5;
    [self.HalftoneFilter addTarget:_preLayerView];
}

- (void) opentem{
    self.effectTag = 5;
    self.temButton.selected = !self.temButton.selected;
    self.rawButton.selected = NO;
    self.ShaderButton.selected = NO;
    self.lutButton.selected = NO;
    self.halftoneButton.selected = NO;
    
    [self.temButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_feedBack impactOccurred];
    [self.captureCamera removeAllTargets];
    GPUImageWhiteBalanceFilter *WhiteBalanceFilter = [GPUImageWhiteBalanceFilter new];
    GPUImageContrastFilter * contrastFilter = [GPUImageContrastFilter new];
    contrastFilter.contrast = 0.7;
    WhiteBalanceFilter.temperature = 4000;
//    self.ContrastFilter.contrast = 0.7;
    [self.captureCamera addTarget:WhiteBalanceFilter];
    [WhiteBalanceFilter addTarget:contrastFilter];
    [contrastFilter addTarget:_preLayerView];
}

- (void)WhiteBallence{
    if ([self.captureCamera.inputCamera lockForConfiguration:nil]) {
        //自动白平衡
        if ([self.captureCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.captureCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.captureCamera.inputCamera unlockForConfiguration];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(self.captureCamera){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            [self.captureCamera startCameraCapture];
        });
        [self WhiteBallence];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    if(self.captureCamera){
        [self.captureCamera stopCameraCapture];
//    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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




