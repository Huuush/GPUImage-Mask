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
#import "PhotosManager.h"
#import "GPUImage.h"
#import "LutFilter.h"
#import "ContrastFilter.h"
#import "SaturationFilter.h"
#import "CompressImg.h"

@interface CollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UICollectionView * _collectionView;
}
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, strong) NSMutableArray *imgdataArr;
@property(nonatomic, strong) NSString *dataStr;
@property (nonatomic, strong) GPUImageCropFilter *rawFilter;
@property (nonatomic, strong) LutFilter *LutFilter;
@property (nonatomic, strong) ContrastFilter *ContrastFilter;
//@property (nonatomic, strong) RGBFilter *RGBFilter;
@property (nonatomic, strong) SaturationFilter *SaturationFilter;
@property (nonatomic, strong) GPUImageHalftoneFilter *HalftoneFilter;
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
//    [PhotosManager showPhotosManager:self withMaxImageCount:10 withAlbumArray:^(NSMutableArray<PhotoModel *> *albumArray) {
//        NSLog(@"%@", albumArray);
//    }];
    
    UIImagePickerController * pickvc = [UIImagePickerController new];
    pickvc.delegate = self;
    pickvc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickvc animated:YES completion:nil];
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
    layout.headerReferenceSize = CGSizeMake(APP_SCREEN_WIDTH, 80);
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
    [self.view addSubview:_collectionView];
    
    self.backToCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backToCameraButton setBackgroundImage:[UIImage imageNamed:@"Photo icon"] forState:UIControlStateNormal];
    [self.backToCameraButton addTarget:self action:@selector(backToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backToCameraButton];
    [self.backToCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(APP_SCREEN_WIDTH/2-APP_SCREEN_WIDTH*0.171/2);
        make.top.mas_equalTo(self.view).mas_offset(10);
        make.width.mas_equalTo(APP_SCREEN_WIDTH*0.171);
        make.height.mas_equalTo(APP_SCREEN_HEIGHT*0.096);
    }];
    
    
    self.inputPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inputPhotoButton setBackgroundImage:[UIImage imageNamed:@"album icon"] forState:UIControlStateNormal];
    [self.view addSubview:self.inputPhotoButton];
    [self.inputPhotoButton addTarget:self action:@selector(inputPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.inputPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(80);
        make.top.mas_equalTo(self.view).mas_offset(30);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
}
//pickimage
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    NSLog(@"aaa");
    GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:image];
    if (_effectTag == 1) {
        [self.rawFilter forceProcessingAtSizeRespectingAspectRatio:image.size];
        [self.rawFilter useNextFrameForImageCapture];
        [sourcePicture addTarget:self.rawFilter];
        [sourcePicture processImage];
        UIImage *newImage = [self.rawFilter imageFromCurrentFramebuffer];
        //开始上传
        CompressImg * compress = [CompressImg new];
        UIImage * postimg = [compress imageWithImage:newImage scaledToSize:CGSizeMake(375, 500)];
        self.imgData = UIImageJPEGRepresentation(postimg,0.5f);//第二个参数为压缩倍数
        
        NSData *base64Data = [self.imgData base64EncodedDataWithOptions:0];
        self.dataStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        NSMutableDictionary * dic = [@{
                                       @"userId":@"1",
                                       @"imgData":self.dataStr,
                                       @"effectTag":@(self.effectTag),
                                       } mutableCopy];
        [session POST:@"http://172.20.10.3:3000/addPhoto" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"上传成功！");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"上传成功！");
        }];
    }
    else if (_effectTag == 2) {
        GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];
        GPUImageGrayscaleFilter * grayfliter = [[GPUImageGrayscaleFilter alloc] init];
        [filterGroup addFilter:grayfliter];
        [filterGroup addFilter:self.ContrastFilter];
        
        [grayfliter addTarget:self.ContrastFilter];
        filterGroup.initialFilters = [NSArray arrayWithObject:grayfliter];
        filterGroup.terminalFilter = self.ContrastFilter;
        
        
        [filterGroup forceProcessingAtSizeRespectingAspectRatio:image.size];
        [filterGroup useNextFrameForImageCapture];
        [sourcePicture addTarget:filterGroup];
        [sourcePicture processImage];
        
        UIImage *newImage = [filterGroup imageFromCurrentFramebuffer];
        //开始上传
        CompressImg * compress = [CompressImg new];
        UIImage * postimg = [compress imageWithImage:newImage scaledToSize:CGSizeMake(375, 500)];
        self.imgData = UIImageJPEGRepresentation(postimg,0.5f);//第二个参数为压缩倍数
        
        NSData *base64Data = [self.imgData base64EncodedDataWithOptions:0];
        self.dataStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        NSMutableDictionary * dic = [@{
                                       @"userId":@"1",
                                       @"imgData":self.dataStr,
                                       @"effectTag":@(self.effectTag),
                                       } mutableCopy];
        [session POST:@"http://172.20.10.3:3000/addPhoto" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"上传成功！");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"上传成功！");
        }];
    }
    else if (_effectTag == 3){
        [self.LutFilter forceProcessingAtSizeRespectingAspectRatio:image.size];
        [self.LutFilter useNextFrameForImageCapture];
        [sourcePicture addTarget:self.LutFilter];
        [sourcePicture processImage];
        UIImage *newImage = [self.LutFilter imageFromCurrentFramebuffer];
        //开始上传
        CompressImg * compress = [CompressImg new];
        UIImage * postimg = [compress imageWithImage:newImage scaledToSize:CGSizeMake(375, 500)];
        self.imgData = UIImageJPEGRepresentation(postimg,0.5f);//第二个参数为压缩倍数
        
        NSData *base64Data = [self.imgData base64EncodedDataWithOptions:0];
        self.dataStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        NSMutableDictionary * dic = [@{
                                       @"userId":@"1",
                                       @"imgData":self.dataStr,
                                       @"effectTag":@(self.effectTag),
                                       } mutableCopy];
        [session POST:@"http://172.20.10.3:3000/addPhoto" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"上传成功！");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"上传成功！");
        }];
    }
    else if(_effectTag == 4){
        [self.HalftoneFilter forceProcessingAtSizeRespectingAspectRatio:image.size];
        [self.HalftoneFilter useNextFrameForImageCapture];

        [self.HalftoneFilter forceProcessingAtSizeRespectingAspectRatio:image.size];
        [self.HalftoneFilter useNextFrameForImageCapture];
        [sourcePicture addTarget:self.HalftoneFilter];
        [sourcePicture processImage];
        
        UIImage *newImage = [self.HalftoneFilter imageFromCurrentFramebuffer];
        //开始上传
        CompressImg * compress = [CompressImg new];
        UIImage * postimg = [compress imageWithImage:newImage scaledToSize:CGSizeMake(375, 500)];
        self.imgData = UIImageJPEGRepresentation(postimg,0.5f);//第二个参数为压缩倍数
        
        NSData *base64Data = [self.imgData base64EncodedDataWithOptions:0];
        self.dataStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        NSMutableDictionary * dic = [@{
                                       @"userId":@"1",
                                       @"imgData":self.dataStr,
                                       @"effectTag":@(self.effectTag),
                                       } mutableCopy];
        [session POST:@"http://172.20.10.3:3000/addPhoto" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"上传成功！");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"上传成功！");
        }];
    }
    else if (_effectTag == 5){
        GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];
        GPUImageWhiteBalanceFilter * BalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
        BalanceFilter.temperature = 4000;
        self.ContrastFilter.contrast = 0.7;
        [filterGroup addFilter:BalanceFilter];
        [filterGroup addFilter:self.ContrastFilter];
        
        [BalanceFilter addTarget:self.ContrastFilter];
        filterGroup.initialFilters = [NSArray arrayWithObject:BalanceFilter];
        filterGroup.terminalFilter = self.ContrastFilter;
        
        [filterGroup forceProcessingAtSizeRespectingAspectRatio:image.size];
        [filterGroup useNextFrameForImageCapture];
        [sourcePicture addTarget:filterGroup];
        [sourcePicture processImage];
        
        UIImage *newImage = [filterGroup imageFromCurrentFramebuffer];
        //开始上传
        CompressImg * compress = [CompressImg new];
        UIImage * postimg = [compress imageWithImage:newImage scaledToSize:CGSizeMake(375, 500)];
        self.imgData = UIImageJPEGRepresentation(postimg,0.5f);//第二个参数为压缩倍数
        
        NSData *base64Data = [self.imgData base64EncodedDataWithOptions:0];
        self.dataStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        session.requestSerializer = [AFJSONRequestSerializer serializer];
        NSMutableDictionary * dic = [@{
                                       @"userId":@"1",
                                       @"imgData":self.dataStr,
                                       @"effectTag":@(self.effectTag),
                                       } mutableCopy];
        [session POST:@"http://172.20.10.3:3000/addPhoto" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"上传成功！");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"上传成功！");
        }];
    }

    [self loadData];
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (LutFilter *)LutFilter {
    if (!_LutFilter) {
        _LutFilter = [[LutFilter alloc] init];
    }
    return _LutFilter;
}

-(GPUImageCropFilter *) rawFilter{
    if (!_rawFilter) {
        _rawFilter = [[GPUImageCropFilter alloc] init];
    }
    return _rawFilter;
}

-(SaturationFilter *) SaturationFilter{
    if (!_SaturationFilter) {
        _SaturationFilter = [[SaturationFilter alloc] init];
    }
    return _SaturationFilter;
}

-(GPUImageHalftoneFilter *) HalftoneFilter{
    if (!_HalftoneFilter) {
        _HalftoneFilter = [GPUImageHalftoneFilter new];
    }
    return _HalftoneFilter;
}

- (ContrastFilter *) ContrastFilter{
    if (!_ContrastFilter) {
        _ContrastFilter = [[ContrastFilter alloc] init];
    }
    return _ContrastFilter;
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
