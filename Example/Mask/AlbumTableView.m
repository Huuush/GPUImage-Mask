//
//  AlbumTableView.m
//  Mask_Example
//
//  Created by Harry on 2019/5/16.
//  Copyright © 2019年 Huuush. All rights reserved.
//

#import "AlbumTableView.h"
#import "AlbumTableViewCell.h"

@interface AlbumTableView() <UITableViewDelegate, UITableViewDataSource>

@end

static NSString *albumTableViewCell = @"AlbumTableViewCell";

@implementation AlbumTableView
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self setupTableView];
    }
    
    return self;
}

#pragma mark - 设置tableView
-(void)setupTableView {
    [self registerClass:[AlbumTableViewCell class] forCellReuseIdentifier:albumTableViewCell];
    
    self.delegate = self;
    self.dataSource = self;
    
    self.tableFooterView = [UIView new];
}

#pragma mark - Set方法
-(void)setAssetCollectionList:(NSMutableArray<AlbumModel *> *)assetCollectionList {
    _assetCollectionList = assetCollectionList;
    
    [self reloadData];
}

#pragma mark - UITableViewDataSource / UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollectionList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:albumTableViewCell];
    
    cell.row = indexPath.row;
    cell.albumModel = self.assetCollectionList[indexPath.row];
    [cell loadImage:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectAction) {
        self.selectAction(self.assetCollectionList[indexPath.row]);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
