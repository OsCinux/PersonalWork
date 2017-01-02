//
//  GuestDetailViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/23.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "GuestDetailViewController.h"
#import "DetailCollectionViewCell.h"
#import "ClientInfoModel.h"

#define kItemEageInsets  UIEdgeInsetsMake(10, 10, 10, 10)

static NSString *const kDetailHeaderIndentifier = @"kDetailHeaderIndentifier";
static NSString *const kDetailFooterIndentifier = @"kDetailFooterIndentifier";


@interface GuestDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *detaiCollectionView;
@property (nonatomic, strong)UICollectionViewLayout *collectionLayout;
@property (nonatomic, strong)ClientInfoModel *infoModel;
@property (nonatomic, strong)NSMutableArray *photoURLStrings;
@property (nonatomic, strong)UIImageView *bigImageView;
@property (nonatomic, strong)UIView *fadeBackgroundView;
@property (nonatomic, strong)UICollectionReusableView *tempHeaderView;
@property (nonatomic, strong)UICollectionReusableView *tempFooterView;
@property (nonatomic, assign)CGFloat tempScale;
@property (nonatomic, strong)UIButton *cameraBtn;
@property (nonatomic, strong)UIButton *albumBtn;
@property (nonatomic, strong)NSMutableArray *localImages;
@property (nonatomic, assign)BOOL isEditingStatus;
@property (nonatomic, strong)UIBarButtonItem *rightItem;

@end

@implementation GuestDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpViews];
    self.tempScale = NSNotFound;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private - Setings and Gettings

- (void)setUpData {
    self.photoURLStrings = [[NSMutableArray alloc] init];
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID], @"userid", [uts objectForKey:KToken], @"token", self.ciid, @"ciid", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:KGetGuestInfoAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        self.infoModel = [[ClientInfoModel alloc] initWithDictionary:dic];
        for (NSDictionary *dic in self.infoModel.clientsImageData) {
            [self.photoURLStrings addObject:dic[@"picurl"]];
        }
        [self.detaiCollectionView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
    [self readImageFromLocal];

}

- (void)setUpViews {
    self.fadeBackgroundView = ({
        UIView *view = [UIView new];
        view.alpha = 0;
        view.backgroundColor = RGBA(14, 14, 16, 0.5);
        [self.navigationController.view addSubview:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTap:)];
        [view addGestureRecognizer:tap];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        pinch.delegate = self;
        [view addGestureRecognizer:pinch];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.navigationController.view);
        }];
        view;
        
    });
    
    self.bigImageView = ({
        UIImageView *view = [UIImageView new];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [self.fadeBackgroundView addSubview:view];
        view;
    });
    
    
    self.collectionLayout = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = (kScreenWidth - 20) / 3 -20;
        CGFloat itemHeight = itemWidth;
        layout.itemSize =  CGSizeMake(itemWidth, itemHeight);
        layout.sectionInset = kItemEageInsets;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 100);
        layout.footerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 60);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout;
    });
    
    self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleEditPic)];
    self.navigationItem.rightBarButtonItem = self.rightItem;
    
    self.detaiCollectionView.collectionViewLayout  = self.collectionLayout;
    UINib *cellNib = [UINib nibWithNibName:@"DetailCollectionViewCell" bundle:nil];
    [self.detaiCollectionView registerNib:cellNib forCellWithReuseIdentifier:NSStringFromClass([DetailCollectionViewCell class])];
    [self.detaiCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDetailHeaderIndentifier];
    [self.detaiCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kDetailFooterIndentifier];
}

- (void)setupHeaderView:(UICollectionReusableView *)view {
    if (self.tempHeaderView != view) {
        self.tempHeaderView = view;
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [view addSubview:blurView];
        [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(view);
        }];
        
        UIImageView *QRAvatarView = [[UIImageView alloc] init];
        QRAvatarView.image = [UIImage imageNamed:@"avator"];
        [view addSubview:QRAvatarView];
        [QRAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(@50);
            make.centerY.mas_equalTo(view);
            make.left.equalTo(view.mas_left).with.offset(kItemEageInsets.left);
        }];
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = self.infoModel.ciname;
        nameLabel.font = [UIFont systemFontOfSize:20.f];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@100);
            make.height.mas_equalTo(@45);
            make.centerY.mas_equalTo(view);
            make.left.equalTo(QRAvatarView.mas_right).with.offset(30);
        }];
        
        UILabel *phoneLabel = [[UILabel alloc] init];
        phoneLabel.text = self.infoModel.ciphone;
        phoneLabel.textAlignment = NSTextAlignmentCenter;
        phoneLabel.font = [UIFont systemFontOfSize:20.f];
        [view addSubview:phoneLabel];
        [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@100);
            make.height.mas_equalTo(@45);
            make.centerY.mas_equalTo(view);
            make.left.equalTo(nameLabel.mas_right).with.offset(30);
        }];
        
        UIView *sepratorLine = [[UIView alloc] init];
        sepratorLine.backgroundColor = [UIColor grayColor];
        [view addSubview:sepratorLine];
        [sepratorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.bottom.mas_equalTo(view);
            make.height.mas_equalTo(@1);
        }];
        
    }
}

- (void)setupFooterView:(UICollectionReusableView *)view {
    if (self.tempFooterView != view) {
        self.tempFooterView = view;
        UIView *sepratorLine = [[UIView alloc] init];
        sepratorLine.backgroundColor = [UIColor grayColor];
        [view addSubview:sepratorLine];
        [sepratorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.top.mas_equalTo(view);
            make.height.mas_equalTo(@1);
        }];
        self.cameraBtn = [[UIButton alloc] init];
        [_cameraBtn setTitle:@"相机" forState: UIControlStateNormal];
        [_cameraBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_cameraBtn addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_cameraBtn];
        
        self.albumBtn = [[UIButton alloc] init];
        [_albumBtn setTitle:@"相册" forState:UIControlStateNormal];
        [_albumBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_albumBtn addTarget:self action:@selector(showPhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_albumBtn];
        
        UIButton *editBtn = [[UIButton alloc] init];
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(editPic) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:editBtn];
        
        [_albumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(view);
            make.height.width.mas_equalTo(60);
            make.right.equalTo(view.mas_right).with.offset(-25);
        }];
        
        [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(view);
            make.left.equalTo(view.mas_left).with.offset(25);
            make.width.height.mas_equalTo(60);
        }];
        
        [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.centerX.mas_equalTo(view);
            make.width.height.mas_equalTo(60);
        }];
        
    }
}

#pragma mark - Private - Methods

- (void)readImageFromLocal {
    NSFileManager *manager = [NSFileManager defaultManager];
    self.localImages = [[NSMutableArray alloc] init];
    NSArray *subStrings = [manager contentsOfDirectoryAtPath:kClientImageFolder error:nil];
    for (NSString *string in subStrings) {
        NSString *path = [kClientImageFolder stringByAppendingPathComponent:string];
        UIImage *uimage = [UIImage imageWithContentsOfFile:path];
        [self.localImages addObject:uimage];
    }
    
}

- (void)addAction:(UIButton *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"选择图片来源" preferredStyle:UIAlertControllerStyleActionSheet];
    alertVC.popoverPresentationController.sourceView = sender;
    alertVC.popoverPresentationController.sourceRect = CGRectMake(50, 40, 100, 100);
    UIAlertAction *photoAlbumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showPhotoAlbum];
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showCamera];
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [alertVC addAction:photoAlbumAction];
    [alertVC addAction:cameraAction];
    [alertVC addAction:cancleAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    NSLog(@"点击添加");
}

- (void)showCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [imagePicker setDelegate:self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)showPhotoAlbum {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [imagePicker.navigationBar setBarStyle:UIBarStyleBlack];
        imagePicker.allowsEditing = NO;
        [imagePicker setDelegate:self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (NSString *)uniqueString {
     CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
     CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
     NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
     CFRelease(uuid_ref);
     CFRelease(uuid_string_ref);
     return [uuid lowercaseString];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        if (self.tempScale != NSNotFound) {
            UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)gestureRecognizer;
            pinch.scale = self.tempScale;
        }
    }
    return YES;
}

- (void)coverViewTap:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.2f animations:^{
        [self.bigImageView removeFromSuperview];
        self.fadeBackgroundView.alpha = 0;
     }];
}

- (void)pinchView:(UIPinchGestureRecognizer *)sender{
    self.bigImageView.transform = CGAffineTransformMakeScale(sender.scale, sender.scale);
    self.bigImageView.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    self.tempScale = sender.scale;
}

- (void)uploadImageToServerWithImgData:(NSData *)data fileName:(NSString *)fileName {
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID],@"userid",[uts objectForKey:KToken],@"token",self.ciid,@"ciid", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kUploadImageAddress parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"进度=======%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"图片上传成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"图片上传失败");
        NSLog(@"error=====%@",error);
    }];
}

//压缩图片质量
-(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}
//压缩图片尺寸
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark Actions 

- (void)editPic {
    
}

- (void)deleteItemWithSender:(UIButton *)btn {
    UICollectionViewCell *cell = (UICollectionViewCell *)btn.superview;
    NSIndexPath *index = [self.detaiCollectionView indexPathForCell:cell];
    [self.photoURLStrings removeObjectAtIndex:index.row];
    [self.detaiCollectionView deleteItemsAtIndexPaths:@[index]];
    
}

- (void)cancleEditPic {
    
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"选择完毕");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [self reduceImage:image percent:1];
    CGSize imageSize = image.size;
    imageSize.height = image.size.height*0.5;
    imageSize.width = image.size.width*0.5;
    image = [self imageWithImageSimple:image scaledToSize:imageSize];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    NSString *imageName = [[self uniqueString] stringByAppendingPathExtension:@"jpg"];
    NSString *targetPath = [kClientImageFolder stringByAppendingPathComponent:imageName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL successFlolder = [fileManager createDirectoryAtPath:kClientImageFolder withIntermediateDirectories:YES attributes:nil error:nil];
    if (successFlolder) {
        if ([fileManager fileExistsAtPath:targetPath]) {
            [fileManager removeItemAtPath:targetPath error:nil];
        }
        BOOL success = [fileManager createFileAtPath:targetPath contents:imageData attributes:nil];
        if (success) {
            [self.photoURLStrings addObject:targetPath];
        }
        [self.detaiCollectionView reloadData];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self uploadImageToServerWithImgData:imageData fileName:imageName];
        });
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoURLStrings.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = NSStringFromClass([DetailCollectionViewCell class]);
    DetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    NSString *urlStr = self.photoURLStrings[indexPath.row];
    [cell configWithImageURLString:urlStr];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view =  [self.detaiCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDetailHeaderIndentifier forIndexPath:indexPath];
        [self setupHeaderView:view];
        
    } else {
        view =  [self.detaiCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDetailFooterIndentifier forIndexPath:indexPath];
        [self setupFooterView:view];
        
    }
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlStr = self.photoURLStrings[indexPath.row];
    NSURL *url = nil;
    UIImage *image = nil;
    if (![urlStr hasPrefix:@"/var"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KDisplayClientImageAddress,self.photoURLStrings[indexPath.row]]];
        image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    }else {
        url = [NSURL URLWithString:urlStr];
        image = [UIImage imageWithContentsOfFile:urlStr];
    }
    [UIView animateWithDuration:0.1f animations:^{
        self.fadeBackgroundView.alpha = 1;
        self.bigImageView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
        self.bigImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.bigImageView.center = self.view.center;
        self.bigImageView.image = image;
        [self.fadeBackgroundView addSubview:self.bigImageView];
    }];
    

}

@end
