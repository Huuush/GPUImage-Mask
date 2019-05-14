//
//  HandlerBusiness.m
//  AHC
//
//  Created by zjm on 2017/9/8.
//  Copyright © 2017年 DreamTouch. All rights reserved.
//

#import "HandlerBusiness.h"
#import "YYModel.h"
#import "sys/utsname.h"

#define baseAHCURLString  @"http://127.0.0.1:3000"

@implementation HandlerBusiness

+(void)AFNGETServiceWithApicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete
{
    [BaseHandlerBusiness PostServiceWithBaseUrl:baseAHCURLString Apicode:apicode Parameters:parameters Success:success Failed:failed Complete:complete];
}

@end
