//
//  HandlerBusiness.h
//  AHC
//
//  Created by zjm on 2017/9/8.
//  Copyright © 2017年 DreamTouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHandlerBusiness.h"

@interface HandlerBusiness : NSObject

/**
 *  Post调用接口 -
 */
+(void)AFNGETServiceWithApicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete;

@end
