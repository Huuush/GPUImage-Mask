//
//  BaseHandlerBusiness.m
//  AHC
//
//  Created by zjm on 2017/9/8.
//  Copyright © 2017年 DreamTouch. All rights reserved.
//

#import "BaseHandlerBusiness.h"
#import "YYModel.h"
#import "sys/utsname.h"

static BaseHandlerBusiness *_sharedReal = nil;
static dispatch_once_t onceTokenReal;

@implementation BaseHandlerBusiness

+ (void)GETServiceWithBaseUrl:(NSString *)baseUrl Apicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete{
    
    dispatch_once(&onceTokenReal, ^{
        _sharedReal = [[BaseHandlerBusiness alloc] init];
        _sharedReal.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",nil];
        _sharedReal.requestSerializer = [AFJSONRequestSerializer serializer];
        
        _sharedReal.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    if (parameters==nil) {
        parameters = @{};
    }
    
    //todo
    NSMutableDictionary *muteParam = [[NSMutableDictionary alloc] init];
//    [muteParam setObject:apicode forKey:@"apicode"];
    [muteParam setObject:parameters forKey:@"args"];
    [muteParam setObject:@"" forKey:@"token"];
    
    NSMutableURLRequest *request  =[_sharedReal.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@%@",baseUrl,apicode] parameters:[muteParam mutableCopy] error:nil];
    [[_sharedReal dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary *  _Nullable responseObject, NSError * _Nullable error) {
        if (complete!=nil) {
            complete();
        }
        if (error) {
            if (failed!=nil){
                failed(@"网络错误",@"网络错误或接口调用失败");
            }
            return;
        }
       
            NSString *modelStr = [AHCApiClient mapModel][apicode];
            if (modelStr!=nil && ![modelStr isEqualToString:@""]) {
                Class cla = NSClassFromString(modelStr);
                if (!cla) {
                }
                success([cla yy_modelWithJSON:responseObject[@"obj"]],responseObject[@"msg"][@"prompt"]);
            }
            else{
                success(responseObject,@"SUCCESS");
            }
    }] resume];
    
    
}


@end
