//
//  CustomCamera.h
//  Mask_Example
//
//  Created by Harry on 2019/5/14.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface CustomCamera : GPUImageStillCamera
@property(nullable, nonatomic, copy) void(^ISOChangeBlock)(float ISO);
@property(nullable, nonatomic, copy) void(^ISOAdjustingBlock)(BOOL adjust);
@property(nullable, nonatomic, copy) void(^FocusAdjustingBlock)(BOOL adjust);

// Flash
- (AVCaptureFlashMode)currentFlashModel;
- (void)setFlashModel:(AVCaptureFlashMode)flashModel;

@end
