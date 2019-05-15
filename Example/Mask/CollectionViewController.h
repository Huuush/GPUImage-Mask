//
//  CollectionViewController.h
//  Masks
//
//  Created by Harry on 2019/4/27.
//  Copyright © 2019年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UIViewController

@property (nonatomic, strong) UIButton * backToCameraButton;
@property (nonatomic, strong) UIButton * inputPhotoButton;
@property (nonatomic, strong) UIButton * DeletePhoto;
@property (nonatomic, assign) NSInteger effectTag;
@end
