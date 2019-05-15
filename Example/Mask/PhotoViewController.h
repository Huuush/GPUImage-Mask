//
//  PhotoViewController.h
//  Masks
//
//  Created by Harry on 2019/4/16.
//  Copyright © 2019年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface PhotoViewController : UIViewController

@property (nonatomic)UIImage *image;
@property (strong, nonatomic) UIButton *preAlbum;
@property (nonatomic, assign) NSInteger effectTag;

@end
