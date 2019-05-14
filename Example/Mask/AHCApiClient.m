//
//  AHCApiClient.m
//  AHC
//
//  Created by zjm on 2017/9/8.
//  Copyright © 2017年 DreamTouch. All rights reserved.
//

#import "AHCApiClient.h"

@implementation AHCApiClient

//TODO：接口
//*---------------------- http:// -----------------*/
//
//NSString *const ApiCodeRegister           = @"Register";
//NSString *const ApiCodeLogin              = @"/mobile/common/login";
//NSString *const ApiCodeGetProvinceList    = @"/mobile/common/getProvinceList";
//NSString *const ApiCodeGetGetHotelList    = @"/mobile/hotel/getHotelList";
//NSString *const ApiCodeGetGetTravellerList    = @"/mobile/hotel/getTravellerList";
//NSString *const ApiCodeGetGetProvinceList    = @"/mobile/common/getProvinceList";
//NSString *const ApiCodeGetGetHotelDetail    = @"/mobile/hotel/getHotelDetail";
//NSString *const ApiCodeGetGetRoomInfo    = @"/mobile/hotel/getRoomInfo";
//NSString *const ApiCodeGetSurplusRoomSearch    = @"/mobile/hotel/surplusRoomSearch";
//NSString *const ApiCodeGetCollectHotel    = @"/mobile/hotel/collectHotel";
//NSString *const ApiCodeGetSubmitOrder    = @"/mobile/hotel/submitOrder";
//NSString *const ApiCodegetUserContract    = @"/mobile/user/getUserContract";
//NSString *const ApiCodeGetOrderList    = @"/mobile/user/getOrderList";
//NSString *const ApiCodeGetOrderDetail    = @"/mobile/user/getOrderDetail";
//NSString *const ApiCodeGetPersonalInfo    = @"/mobile/user/getPersonalInfo";
//NSString *const ApiCodeUpdateHeadImg   = @"/mobile/user/updateHeadImg";
//NSString *const ApiCodeUpdateUserInfo   = @"/mobile/user/updateUserInfo";
//NSString *const ApiCodeGetContractDetail   = @"/mobile/user/getContractDetail";
//NSString *const ApiCodeGetCollectionHotelList   = @"/mobile/user/getCollectionHotelList";
//NSString *const ApiCodeAddBankCard   = @"/mobile/user/addBankCard";
//NSString *const ApiCodeGetWalletInfo   = @"/mobile/user/getWalletInfo";
//NSString *const ApiCodeGetBankCardList   = @"/mobile/user/getBankCardList";
//NSString *const ApiCodeSetDefaultCard   = @"/mobile/user/setDefaultCard";
//NSString *const ApiCodeGetBillInfoList   = @"/mobile/user/getBillInfoList";
//NSString *const ApiCodeGetAdviserInfo = @"/mobile/common/getAdviserInfo";
//NSString *const ApiCodeGetUpdateTravellerInfo = @"/mobile/hotel/updateTravellerInfo";
//NSString *const ApiCodeDeleteCard = @"/mobile/user/deleteCard";
//NSString *const ApiCodeGetNewsList = @"/mobile/news/getNewsList";
//NSString *const ApiCodeGetNewsDetail = @"/mobile/news/getNewsDetail";
//NSString *const ApiCodeGetHotelNotice = @"/mobile/hotel/getHotelNotice";


/**
 *  接口apicode和Model映射关系
 *
 *  @return 映射字典
 */
+(NSDictionary *)mapModel
{
    //TODO:对应 model
//    return @{
//             ApiCodeGetGetHotelDetail : @"HotelDetailModel",
//             ApiCodegetUserContract : @"ContractModelList",
//             ApiCodeGetOrderDetail : @"MyOrderModel",
//             ApiCodeGetPersonalInfo : @"UserInfoModel",
//             ApiCodeGetWalletInfo : @"WalletModel",
//             ApiCodeGetProvinceList : @"ProvinceModelList"
//             };
    return nil;
}

@end
