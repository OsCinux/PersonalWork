//
//  GuestDetailViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/23.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "GuestDetailViewController.h"
#import "ClientInfoModel.h"

#define kItemEageInsets  UIEdgeInsetsMake(10, 30, 0, 30)

static NSString *const kDetailIndetifier = @"kDetailIndetifier";
static NSString *const kDetailHeaderIndentifier = @"kDetailHeaderIndentifier";
static NSString *const kDetailFooterIndentifier = @"kDetailFooterIndentifier";


@interface GuestDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *detaiCollectionView;
@property (nonatomic, strong)UICollectionViewLayout *collectionLayout;
@property (nonatomic, strong)ClientInfoModel *infoModel;
@property (nonatomic, strong)NSMutableArray *photoURLStrings;
@property (nonatomic, strong)UIImageView *bigImageView;
@property (nonatomic, strong)UIView *fadeBackgroundView;



@end

@implementation GuestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Settings

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
}

- (void)setUpViews {
    self.fadeBackgroundView = ({
        UIView *view = [UIView new];
        view.alpha = 0;
        view.backgroundColor = RGBA(14, 14, 16, 0.5);
        [self.navigationController.view addSubview:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTap:)];
        [view addGestureRecognizer:tap];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.navigationController.view);
        }];
        view;
        
    });

    self.bigImageView = ({
        UIImageView *view = [UIImageView new];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [self.fadeBackgroundView addSubview:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTap:)];
        [view addGestureRecognizer:tap];
        view;
    });
    
    
    self.collectionLayout = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = kCollectionViewItemSize;
        layout.sectionInset = kItemEageInsets;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 100);
        layout.footerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 160);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 50;
        layout.minimumLineSpacing = 50;
        layout;
    });
    self.detaiCollectionView.collectionViewLayout  = self.collectionLayout;
    [self.detaiCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDetailHeaderIndentifier];
    [self.detaiCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kDetailFooterIndentifier];
    [self.detaiCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kDetailHeaderIndentifier];
    [self.detaiCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kDetailFooterIndentifier];
}

- (void)setupHeaderView:(UICollectionReusableView *)view {
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

- (void)setupFooterView:(UICollectionReusableView *)view {
    UIButton *addButton = [[UIButton alloc] init];
    [addButton setImage:[UIImage imageNamed:@"btn_add_normal"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"btn_add_highlight"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:addButton];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).with.offset(10);
        make.height.mas_equalTo(@150);
        make.left.equalTo(view.mas_left).with.offset(kItemEageInsets.left-8);
        make.width.mas_equalTo(@150);
    }];
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


- (void)coverViewTap:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.2f animations:^{
        [self.bigImageView removeFromSuperview];
        self.fadeBackgroundView.alpha = 0;
     }];
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

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDetailIndetifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView *)view;
            [imgView removeFromSuperview];
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
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
    imageView.image = image;
    [cell addSubview:imageView];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view =  [self.detaiCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDetailHeaderIndentifier forIndexPath:indexPath];
        [self setupHeaderView:view];
        return view;
        
    }else {
        UICollectionReusableView *view =  [self.detaiCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDetailFooterIndentifier forIndexPath:indexPath];
        [self setupFooterView:view];
        return view;
    }
    
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
    [UIView animateWithDuration:0.2f animations:^{
        self.fadeBackgroundView.alpha = 1;
        self.bigImageView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
        self.bigImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.bigImageView.center = self.view.center;
        self.bigImageView.image = image;
        [self.fadeBackgroundView addSubview:self.bigImageView];
    }];
    

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
