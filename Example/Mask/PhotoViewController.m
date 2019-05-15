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
#import "LutFilter.h"
#import "EffectShowController.h"
#import "SwirlFilter.h"
#import "ContrastFilter.h"
#import "RGBFilter.h"
#import "SaturationFilter.h"

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
@property (nonatomic, strong) UIView *EffectListView;
//@property (nonatomic)UIImageView *imageView;
@property (nonatomic, strong) GPUImageView *preLayerView;
@property (nonatomic)UIView *focusView; //对焦
@property (nonatomic)BOOL isflashOn;

@property (nonatomic, strong) GPUImageCropFilter *rawFilter;
@property (nonatomic, strong) LutFilter *LutFilter;
@property (nonatomic, strong) ContrastFilter *ContrastFilter;
@property (nonatomic, strong) RGBFilter *RGBFilter;
@property (nonatomic, strong) SaturationFilter *SaturationFilter;

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
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-25);
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
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-35);
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
    
//    self.CancelButton = [[UIButton alloc] init];
//    //    self.CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.CancelButton setTitle:@"取消" forState:UIControlStateNormal];
//    [_CancelButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_CancelButton];
//    self.CancelButton.hidden = YES;
//    [self.CancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.view.mas_left).mas_offset(30);
//        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-30);
//        make.width.mas_equalTo(50);
//        make.height.mas_equalTo(50);
//    }];
    
//    self.saveToAlbumButton = [[UIButton alloc] init];
//    [self.saveToAlbumButton setTitle:@"保存" forState:UIControlStateNormal];
//    [self.saveToAlbumButton addTarget:self action:@selector(saveToAblum) forControlEvents:UIControlEventTouchUpInside];
//    self.preAlbum.layer.cornerRadius = 3;
//    self.preAlbum.layer.masksToBounds = YES;
//    [self.view addSubview:_saveToAlbumButton];
//    self.saveToAlbumButton.hidden = YES;
//    [self.saveToAlbumButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.view.mas_right).mas_offset(-30);
//        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-30);
//        make.width.mas_equalTo(50);
//        make.height.mas_equalTo(50);
//    }];
    
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
        make.top.mas_equalTo(self.view.mas_top).mas_offset(0);
        make.width.mas_equalTo(APP_SCREEN_WIDTH);
        make.height.mas_equalTo(APP_SCREEN_HEIGHT-130);
    }];
    [self.preLayerView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    self.preLayerView.userInteractionEnabled = YES;
    // 初始化滤镜
    self.effectTag = 1;
    [_captureCamera addTarget:self.rawFilter];
    [self.rawFilter addTarget:_preLayerView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.preLayerView addGestureRecognizer:tapGesture];
    
    
    
    //原生AVFoundation
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    //self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //使用设备初始化输入
    //self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];

    //生成输出对象
    //self.output = [[AVCaptureMetadataOutput alloc] init];
    //self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];

    //生成会话，用来结合输入输出
//    self.session = [[AVCaptureSession alloc]init];
//    if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
//
//        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
//
//    }
//    if ([self.session canAddInput:self.input]) {
//        [self.session addInput:self.input];
//    }
//
//    if ([self.session canAddOutput:self.ImageOutPut]) {
//        [self.session addOutput:self.ImageOutPut];
//    }
    
    //[self setUpPreviewLayer];
    
    
}

#pragma mark - 闪光灯失效
- (void)FlashOn{
    if ([self.captureCamera inputCamera].flashMode == AVCaptureFlashModeOff)
    {
        NSError *error;
        [[self.captureCamera inputCamera] lockForConfiguration:&error];
        [self.captureCamera inputCamera].flashMode = AVCaptureFlashModeOn;
        [[self.captureCamera inputCamera] unlockForConfiguration];
        return ;
    }
    else if([self.captureCamera inputCamera].flashMode == AVCaptureFlashModeOn)
    {
        NSError *error;
        [[self.captureCamera inputCamera] lockForConfiguration:&error];
        [self.captureCamera inputCamera].flashMode = AVCaptureFlashModeAuto;
        [[self.captureCamera inputCamera] unlockForConfiguration];
        return ;
    }
    if([self.captureCamera inputCamera].flashMode == AVCaptureFlashModeAuto)
    {
        NSError *error;
        [[self.captureCamera inputCamera] lockForConfiguration:&error];
        [self.captureCamera inputCamera].flashMode = AVCaptureFlashModeOff;
        [[self.captureCamera inputCamera] unlockForConfiguration];
        return ;
    }
//    //修改前必须先锁定
//    [self.captureCamera.inputCamera lockForConfiguration:nil];
//
//    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
//    if ([self.captureCamera.inputCamera hasFlash]) {
//        self.captureCamera.inputCamera.flashMode = AVCaptureFlashModeOff;
//
//        if (self.captureCamera.inputCamera.flashMode == AVCaptureFlashModeOff) {
//            self.captureCamera.inputCamera.flashMode = AVCaptureFlashModeOn;
//
//            [_flashButton setBackgroundImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
//        } else if (self.captureCamera.inputCamera.flashMode == AVCaptureFlashModeOn) {
//            self.captureCamera.inputCamera.flashMode = AVCaptureFlashModeAuto;
//            [_flashButton setBackgroundImage:[UIImage imageNamed:@"flash_auto"] forState:UIControlStateNormal];
//        } else if (self.captureCamera.inputCamera.flashMode == AVCaptureFlashModeAuto) {
//            self.captureCamera.inputCamera.flashMode = AVCaptureFlashModeOff;
//            [_flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
//        }
//
//    } else {
//
//        NSLog(@"设备不支持闪光灯");
//    }
//    [self.captureCamera.inputCamera unlockForConfiguration];
}


- (void)changeCamera{
//    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
//    if (cameraCount > 1) {
//        NSError *error;
//
//        CATransition *animation = [CATransition animation];
//
//        animation.duration = .5f;
//
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//
//        animation.type = @"oglFlip";
//        AVCaptureDevice *newCamera = nil;
//        AVCaptureDeviceInput *newInput = nil;
//        AVCaptureDevicePosition position = [[_input device] position];
//        if (position == AVCaptureDevicePositionFront){
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
//            animation.subtype = kCATransitionFromLeft;
//        }
//        else {
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
//            animation.subtype = kCATransitionFromRight;
//        }
//
//        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
//        [self.previewLayer addAnimation:animation forKey:nil];
//        if (newInput != nil) {
//            [self.session beginConfiguration];
//            [self.session removeInput:_input];
//            if ([self.session canAddInput:newInput]) {
//                [self.session addInput:newInput];
//                self.input = newInput;
//
//            } else {
//                [self.session addInput:self.input];
//            }
//
//            [self.session commitConfiguration];
//
//        } else if (error) {
//            NSLog(@"toggle carema failed, error = %@", error);
//        }
//
//    }

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
    if (self.effectTag == 1) {
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
        [self.captureCamera capturePhotoAsImageProcessedUpToFilter:self.SaturationFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
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

#pragma mark - AVFoundation原生截取照片
- (void) shutterCamera
{
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    //block 回调函数
    //__weak __typeof(self)weakSelf = self;
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }

        [self.captureCamera stopCameraCapture];
        
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        _image = [UIImage imageWithData:imageData];
        
        //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
        [self.motionManager startMotionManager:^(NSInteger orientation) {
            self.orientation = orientation;
            NSLog(@"设备方向：%ld",orientation);
        }];
        //开始图像处理
//        GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:_image];
//
////        //渲染图片
//        [self.customFilter forceProcessingAtSizeRespectingAspectRatio:_image.size];
//        [self.customFilter useNextFrameForImageCapture];
////        // 把滤镜串联在图片输入组件之后
//        [sourcePicture addTarget:self.customFilter];
//        [sourcePicture processImage];
////
////        //图像处理结束
//        UIImage *newImage = [self.customFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationRight];
//        _image = newImage;
        
        
        //预览层显示图片
//        self.imageView = [[UIImageView alloc] initWithFrame:self.previewLayer.frame];
//        self.imageView.image = newImage;
//        [self.view insertSubview:_imageView belowSubview:_PhotoButton];
        
//        self.imageView.layer.masksToBounds = YES;
//        self.imageView.image = image;
//        NSLog(@"image size = %@",NSStringFromCGSize(self.image.size));
    }];
    
}

#pragma mark - 滤镜listview
- (void) OpenEffectlist {
    [self.preLayerView addSubview:self.EffectListView];
    UIButton *rawBotton = [[UIButton alloc] init];
    [rawBotton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.EffectListView addSubview:rawBotton];
    [rawBotton addTarget:self action:@selector(openRaw) forControlEvents:UIControlEventTouchUpInside];
    [rawBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.EffectListView.mas_left).mas_offset(100);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *shaderBotton = [[UIButton alloc] init];
    [shaderBotton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.EffectListView addSubview:shaderBotton];
    [shaderBotton addTarget:self action:@selector(openShader) forControlEvents:UIControlEventTouchUpInside];
    [shaderBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rawBotton.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *lutBotton = [[UIButton alloc] init];
    [lutBotton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.EffectListView addSubview:lutBotton];
    [lutBotton addTarget:self action:@selector(openLut) forControlEvents:UIControlEventTouchUpInside];
    [lutBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(shaderBotton.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *outRedBotton = [[UIButton alloc] init];
    [outRedBotton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.EffectListView addSubview:outRedBotton];
    [outRedBotton addTarget:self action:@selector(openOutRed) forControlEvents:UIControlEventTouchUpInside];
    [outRedBotton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lutBotton.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.EffectListView.mas_top).mas_offset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
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

- (UIView *) EffectListView {
    if(!_EffectListView){
        _EffectListView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, APP_SCREEN_WIDTH, 80)];
        _EffectListView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
        
    }
    return _EffectListView;
}


//重置图片方向
//- (void)resetImageWithOrientation:(UIImageOrientation)imageOrientation {
//
//    //横屏拍摄的时候，旋转图片
//    UIImage *image = [UIImage imageWithCGImage:_image.CGImage scale:1.0 orientation:imageOrientation];
//    _imageView.image = image;
//
//    //将横屏拍摄的图片旋转至竖屏，并调整imageview的尺寸
//    CGFloat width = self.view.frame.size.width;
//
//    CGFloat height = image.size.height * width / image.size.width;
//    CGRect frame = _imageView.frame;
//    frame.size.height = height;
//    _imageView.frame = frame;
//    _imageView.center = self.view.center;
//
//}

//修正图片方向
//- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
//{
//    long double rotate = 0.0;
//    CGRect rect;
//    float translateX = 0;
//    float translateY = 0;
//    float scaleX = 1.0;
//    float scaleY = 1.0;
//
//    switch (orientation) {
//        case UIImageOrientationLeft:
//            rotate = M_PI_2;
//            rect = CGRectMake(0, 0, image.size.height, image.size.width);
//            translateX = 0;
//            translateY = -rect.size.width;
//            scaleY = rect.size.width/rect.size.height;
//            scaleX = rect.size.height/rect.size.width;
//            break;
//        case UIImageOrientationRight:
//            rotate = 33 * M_PI_2;
//            rect = CGRectMake(0, 0, image.size.height, image.size.width);
//            translateX = -rect.size.height;
//            translateY = 0;
//            scaleY = rect.size.width/rect.size.height;
//            scaleX = rect.size.height/rect.size.width;
//            break;
//        case UIImageOrientationDown:
//            rotate = M_PI;
//            rect = CGRectMake(0, 0, image.size.width, image.size.height);
//            translateX = -rect.size.width;
//            translateY = -rect.size.height;
//            break;
//        default:
//            rotate = 0.0;
//            rect = CGRectMake(0, 0, image.size.width, image.size.height);
//            translateX = 0;
//            translateY = 0;
//            break;
//    }
//
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    //做CTM变换
//    CGContextTranslateCTM(context, 0.0, rect.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextRotateCTM(context, rotate);
//    CGContextTranslateCTM(context, translateX, translateY);
//
//    CGContextScaleCTM(context, scaleX, scaleY);
//    //绘制图片
//    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
//
//    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
//
//    return newPic;
//}

//- (UIImage *)fixOrientation:(UIImage *)aImage {
//
//    // No-op if the orientation is already correct
//    if (aImage.imageOrientation == UIImageOrientationUp)
//        return aImage;
//
//    // We need to calculate the proper transformation to make the image upright.
//    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
//    CGAffineTransform transform = CGAffineTransformIdentity;
//
//    switch (aImage.imageOrientation) {
//        case UIImageOrientationDown:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
//            transform = CGAffineTransformRotate(transform, M_PI);
//            break;
//
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
//            break;
//
//        case UIImageOrientationRight:
//            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
//            break;
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
//            transform = CGAffineTransformRotate(transform, -M_PI_2);
//            break;
//        default:
//            break;
//    }
//
//    switch (aImage.imageOrientation) {
//        case UIImageOrientationUpMirrored:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//        default:
//            break;
//    }
//    // Now we draw the underlying CGImage into a new context, applying the transform
//    // calculated above.
//    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
//                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
//                                             CGImageGetColorSpace(aImage.CGImage),
//                                             CGImageGetBitmapInfo(aImage.CGImage));
//    CGContextConcatCTM(ctx, transform);
//    switch (aImage.imageOrientation) {
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRight:
//            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
//            break;
//        case UIImageOrientationRightMirrored:
//            // Grr...
//            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
//            break;
//
//        default:
//            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
//            break;
//    }
//
//    // And now we just create a new UIImage from the drawing context
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//    UIImage *img = [UIImage imageWithCGImage:cgimg];
//    CGContextRelease(ctx);
//    CGImageRelease(cgimg);
//    return img;
//}

- (MotionManager *)motionManager {
    if(!_motionManager) {
        _motionManager = [[MotionManager alloc] init];
    }
    return _motionManager;
}

#pragma mark - 选择滤镜
- (void) openRaw {
    self.effectTag = 1;
    [self.captureCamera removeAllTargets];
    [_captureCamera addTarget:self.rawFilter];
    [self.rawFilter addTarget:_preLayerView];
}

- (void) openShader {
    self.effectTag = 2;
    [self.captureCamera removeAllTargets];
    GPUImageGrayscaleFilter * grayfliter = [[GPUImageGrayscaleFilter alloc] init];
    _ContrastFilter = [[ContrastFilter alloc] init];
    [_captureCamera addTarget:grayfliter];
    [grayfliter addTarget:_ContrastFilter];
    [_ContrastFilter addTarget:_preLayerView];
    
}

- (void) openLut{
    self.effectTag = 3;
    [self.captureCamera removeAllTargets];
    [self.captureCamera addTarget:self.LutFilter];
    [self.LutFilter addTarget:_preLayerView];
}

- (void) openOutRed{
    self.effectTag = 4;
    [self.captureCamera removeAllTargets];
    [self.captureCamera addTarget:self.RGBFilter];
    [self.RGBFilter addTarget:self.SaturationFilter];
    [self.SaturationFilter addTarget:_preLayerView];
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




