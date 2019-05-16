//
//  PhotoManager.m
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "PhotoManager.h"

@implementation PhotoManager

+(PhotoManager*)standardPhotoManger {
    static PhotoManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PhotoManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Set方法
-(void)setMaxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
    
    self.photoModelList = [NSMutableArray array];
    self.choiceCount = 0;
}

-(void)setChoiceCount:(NSInteger)choiceCount {
    _choiceCount = choiceCount;
    
    if (self.choiceCountChange) {
        self.choiceCountChange(choiceCount);
    }
}

@end
