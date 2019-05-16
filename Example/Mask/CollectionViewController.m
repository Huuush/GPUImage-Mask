//
//  CollectionViewController.m
//  Masks
//
//  Created by Harry on 2019/4/27.
//  Copyright © 2019年 Harry. All rights reserved.
//

#define APP_SCREEN_BOUNDS   [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT   (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH    (APP_SCREEN_BOUNDS.size.width)
#define APP_STATUS_FRAME    [UIApplication sharedApplication].statusBarFrame

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "HandlerBusiness.h"
#import "editRawViewController.h"
//#import "PhotoPickerController.h"
#import "PhotosManager.h"

@interface CollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    
    UICollectionView * _collectionView;
}
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, strong) NSMutableArray *imgdataArr;
@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [self setNeedsStatusBarAppearanceUpdate];
    [self loadUI];
    [self loadData];
}

- (void) backToCamera {
    NSLog(@"点击到了");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) inputPhoto {
    NSLog(@"点击到了");
    [PhotosManager showPhotosManager:self withMaxImageCount:10 withAlbumArray:^(NSMutableArray<PhotoModel *> *albumArray) {
        NSLog(@"%@", albumArray);
    }];
}

- (void)loadData{
    NSDictionary *getfordata = @{
                              @"effecttag":@(self.effectTag)
                               };
    [HandlerBusiness AFNGETServiceWithApicode:@"/inputImage" Parameters:getfordata Success:^(NSArray * dataArr, id msg) {
        NSLog(@"加载成功");
        for (int i = 0 ; i < dataArr.count; i++) {
            _imgData = [[NSData alloc] initWithBase64EncodedString:[dataArr[i] valueForKey:@"imagedata"] options:0];
            [self.imgdataArr addObject:_imgData];
        }
        [_collectionView reloadData];
    } Failed:^(NSString *error, NSString *errorDescription) {
        NSLog(@"");
    } Complete:^{
        NSLog(@"");
    }];
}

- (void) loadUI {
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH,APP_SCREEN_HEIGHT) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    //到时候设置相册背景图片
    //    NSString *path = [[NSBundlemainBundle]pathForResource:@"image"ofType:@"jpg"];
    //    UIImage *image = [UIImageimageWithContentsOfFile:path];
    //    self.view.layer.contents = (id)image.CGImage;
    //_collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@""]];
    
    layout.headerReferenceSize = CGSizeMake(APP_SCREEN_WIDTH, 80);
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self.view addSubview:_collectionView];
    
    self.backToCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backToCameraButton setBackgroundImage:[UIImage imageNamed:@"Rec Button"] forState:UIControlStateNormal];
    [self.backToCameraButton addTarget:self action:@selector(backToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backToCameraButton];
    [self.backToCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(APP_SCREEN_WIDTH/2-APP_SCREEN_WIDTH*0.171/2);
        make.top.mas_equalTo(self.view).mas_offset(10);
        make.width.mas_equalTo(APP_SCREEN_WIDTH*0.171);
        make.height.mas_equalTo(APP_SCREEN_HEIGHT*0.096);
    }];
    
    
    self.inputPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inputPhotoButton setBackgroundImage:[UIImage imageNamed:@"Latest Image Icon"] forState:UIControlStateNormal];
    [self.view addSubview:self.inputPhotoButton];
    [self.inputPhotoButton addTarget:self action:@selector(inputPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.inputPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(67);
        make.top.mas_equalTo(self.view).mas_offset(20);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
}
//pickimage
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    editRawViewController *editvc = [editRawViewController new];
    editvc.imagefrompick = image;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    cell.itemImage.image = [UIImage imageWithData:self.imgdataArr[indexPath.row]];
    
    return cell;
}
//点击放大图片
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imgdataArr.count;
}


//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(171, 228);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

////设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (NSMutableArray *) imgdataArr{
    if (!_imgdataArr) {
        _imgdataArr = [[NSMutableArray alloc] init];
    }
    return _imgdataArr;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
