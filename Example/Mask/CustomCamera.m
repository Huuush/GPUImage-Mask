//
//  CustomCamera.m
//  Mask_Example
//
//  Created by Harry on 2019/5/14.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "CustomCamera.h"

static void* ISOContext;
static void* ISOAdjustingContext;
static void* FocusAdjustingContext;
static void* ExposureTargetOffsetContext;

@implementation CustomCamera

- (instancetype)init
{
    if (self = [super init]) {
        [self registerObserver];
    }
    return self;
}

- (void)registerObserver
{
    [self.inputCamera addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:&ISOContext];
    [self.inputCamera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:&FocusAdjustingContext];
    [self.inputCamera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&ISOAdjustingContext];
    [self.inputCamera addObserver:self forKeyPath:@"exposureTargetOffset" options:NSKeyValueObservingOptionNew context:&ExposureTargetOffsetContext];
}

#pragma mark - 闪光灯
- (AVCaptureFlashMode)currentFlashModel
{
    return [self inputCamera].flashMode;
}

- (void)setFlashModel:(AVCaptureFlashMode)flashModel
{
    if ([self inputCamera].flashMode == flashModel) {
        return;
    }
    
    if ([[self inputCamera] isFlashModeSupported:flashModel]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].flashMode = flashModel;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"key = %@", keyPath);
    
    if (&ISOContext == context) {
        if (_ISOChangeBlock) {
            _ISOChangeBlock([change[NSKeyValueChangeNewKey] floatValue]);
        }
    }else if (&ISOAdjustingContext == context) {
        if (_ISOAdjustingBlock) {
            _ISOAdjustingBlock([change[NSKeyValueChangeNewKey] boolValue]);
        }
    }else if (&FocusAdjustingContext == context) {
        if (_FocusAdjustingBlock) {
            _FocusAdjustingBlock([change[NSKeyValueChangeNewKey] boolValue]);
        }
    }else if (&ExposureTargetOffsetContext == context) {
        
    }
}

@end
