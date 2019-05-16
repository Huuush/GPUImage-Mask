//
//  AlbumViewController.h
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlbumViewControllerConfirmAction)(void);

@interface AlbumViewController : UIViewController

/// 确定事件
@property (nonatomic, copy) AlbumViewControllerConfirmAction confirmAction;

@end
