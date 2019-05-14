//
//  MotionManager.h
//  Masks
//
//  Created by Harry on 2019/4/29.
//  Copyright © 2019年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MotionDeviceOrientation)(NSInteger orientation);

@interface MotionManager : NSObject

/**
 开始陀螺仪监测
 
 @param motionDeviceOrientation 陀螺仪监测设备方向回调，获取到设备的方向
 
 **/
- (void)startMotionManager:(MotionDeviceOrientation)motionDeviceOrientation;

@end
