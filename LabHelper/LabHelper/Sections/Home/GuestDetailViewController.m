//
//  GuestDetailViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/23.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "GuestDetailViewController.h"
#import "DetailImageCell.h"
#import "ClientInfoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kItemEageInsets  UIEdgeInsetsMake(10, 10, 10, 10)


static NSString *const kDetailHeaderIndentifier = @"kDetailHeaderIndentifier";
static NSString *const kDetailFooterIndentifier = @"kDetailFooterIndentifier";
static NSString *const kOberverForKeyPath = @"deleteURLStrings";

@interface GuestDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *detaiCollectionView;
@property (nonatomic, strong)UICollectionViewLayout *collectionLayout;
@property (nonatomic, strong)ClientInfoModel *infoModel;
@property (nonatomic, strong)NSMutableArray *photoURLStrings;
@property (nonatomic, strong)NSMutableArray *deleteURLStrings;
@property (nonatomic, strong)NSMutableArray *deleteIndexPathes;
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
@property (nonatomic, strong)UIButton *editBtn;
@property (nonatomic, strong)NSMutableDictionary *picURLtoIDdictionary;

@end

@implementation GuestDetailViewController

#pragma mark - Lifecycle

- (void)dealloc {
    [self removeObserver:self forKeyPath:kOberverForKeyPath];
    self.deleteURLStrings = nil;
    self.deleteIndexPathes = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpViews];
    self.tempScale = NSNotFound;
    [self addObserver:self forKeyPath:kOberverForKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private - Setings and Gettings

- (NSMutableArray *)deleteURLStrings {
    if (!_deleteURLStrings) {
        _deleteURLStrings = [[NSMutableArray alloc] init];
    }
    return _deleteURLStrings;
}

- (NSMutableArray *)photoURLStrings {
    if (!_photoURLStrings) {
        _photoURLStrings = [[NSMutableArray alloc] init];
    }
    return _photoURLStrings;
}

- (NSMutableArray *)deleteIndexPathes {
    if (!_deleteIndexPathes) {
        _deleteIndexPathes = [[NSMutableArray alloc] init];
    }
    return _deleteIndexPathes;
}
- (NSMutableDictionary *)picURLtoIDdictionary {
    if (!_picURLtoIDdictionary) {
        _picURLtoIDdictionary = [[NSMutableDictionary alloc] init];
    }
    return _picURLtoIDdictionary;
}

- (void)setUpData {
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID], @"userid", [uts objectForKey:KToken], @"token", self.ciid, @"ciid", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:KGetGuestInfoAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        self.infoModel = [[ClientInfoModel alloc] initWithDictionary:dic];
        for (NSDictionary *dic in self.infoModel.clientsImageData) {
            [self.photoURLStrings addObject:dic[@"picurl"]];
            [self.picURLtoIDdictionary setObject:dic[@"picid"] forKey:dic[@"picurl"]];
        }
        [self.detaiCollectionView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
    [self readImageFromLocal];

}

- (void)setEditButtonEnabled:(BOOL)enabled {
    self.editBtn.enabled = enabled;
    if (enabled) {
        [self.editBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    } else {
        [self.editBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
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

    self.detaiCollectionView.collectionViewLayout  = self.collectionLayout;
    UINib *cellNib = [UINib nibWithNibName:@"DetailImageCell" bundle:nil];
    [self.detaiCollectionView registerNib:cellNib forCellWithReuseIdentifier:NSStringFromClass([DetailImageCell class])];
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
        
        self.editBtn = [[UIButton alloc] init];
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self.editBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.editBtn addTarget:self action:@selector(editPic:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:self.editBtn];
        
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
        
        [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)editPic:(UIButton *)sender {
   if (self.isEditingStatus) {
       [self deleteItems];
   } else {
       [[self mutableArrayValueForKey:kOberverForKeyPath] removeAllObjects];
       self.navigationItem.rightBarButtonItem = self.rightItem;
       self.isEditingStatus = YES;
       [sender setTitle:@"删除" forState:UIControlStateNormal];
       if ([self.deleteURLStrings count] <= 0) {
           [self setEditButtonEnabled:NO];
       }
   }
}

- (void)deleteItems {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t uploadQueue = dispatch_get_global_queue(0, 0);
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    for (NSString *picurl in self.deleteURLStrings) {
        dispatch_group_async(group, uploadQueue, ^{
            dispatch_group_enter(group);
            NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID], @"userid", [uts objectForKey:KToken], @"token", self.picURLtoIDdictionary[picurl], @"picid", nil];
            
            [manager GET:kDeleteImageAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self.photoURLStrings removeObject:picurl];
                [self.deleteURLStrings removeObject:picurl];
                NSLog(@"%@完成",picurl);
                dispatch_group_leave(group);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                dispatch_group_leave(group);
            }];
        });
   }
   dispatch_group_notify(group, uploadQueue, ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.detaiCollectionView deleteItemsAtIndexPaths:self.deleteIndexPathes];
           [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
           [self setEditButtonEnabled:YES];
           self.isEditingStatus = NO;
           self.navigationItem.rightBarButtonItem = nil;
           
       });
   });

}

- (void)cancleEditPic {
    self.isEditingStatus = NO;
    self.navigationItem.rightBarButtonItem = nil;
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self setEditButtonEnabled:YES];
    [[self mutableArrayValueForKey:kOberverForKeyPath] removeAllObjects];
    for (DetailImageCell *cell in self.detaiCollectionView.visibleCells) {
        [cell setChoseBtnVisible:NO];
    }
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
    NSString *reuseIdentifier = NSStringFromClass([DetailImageCell class]);
    DetailImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSString *urlStr = self.photoURLStrings[indexPath.row];
    if ([self.deleteURLStrings containsObject:urlStr]) {
        [cell setChoseBtnVisible:YES];
    } else {
        [cell setChoseBtnVisible:NO];
    }
    cell.actionCellClick = ^(){
        [self.deleteIndexPathes removeObject:indexPath];
        [[self mutableArrayValueForKey:kOberverForKeyPath] removeObject:self.photoURLStrings[indexPath.row]];
    };
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
    if (self.isEditingStatus) {
        DetailImageCell *cell = (DetailImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell setChoseBtnVisible:YES];
        [[self mutableArrayValueForKey:kOberverForKeyPath] addObject:[self.photoURLStrings objectAtIndex:indexPath.row]];
        [self.deleteIndexPathes addObject:indexPath];
        
    } else {
        NSString *urlStr = self.photoURLStrings[indexPath.row];
        NSURL *url = nil;
        if (![urlStr hasPrefix:@"/var"]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KDisplayClientImageAddress,self.photoURLStrings[indexPath.row]]];
        }else {
            url = [NSURL URLWithString:urlStr];
        }
        self.bigImageView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
        self.bigImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bigImageView sd_setImageWithURL:url];
        self.bigImageView.center = self.view.center;
        [self.fadeBackgroundView addSubview:self.bigImageView];
        [UIView animateWithDuration:0.1f animations:^{
            self.fadeBackgroundView.alpha = 1;
        }];

    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isEditingStatus) {
        if ([keyPath isEqualToString:kOberverForKeyPath]) {
            if ([self.deleteURLStrings count] > 0) {
                [self setEditButtonEnabled:YES];
            } else {
                [self setEditButtonEnabled:NO];
            }
        }
    }
   
}

@end
