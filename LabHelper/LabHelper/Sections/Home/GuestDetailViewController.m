//
//  GuestDetailViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/23.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "GuestDetailViewController.h"
#import "ClientInfoModel.h"

static NSString *const kDetailIndetifier = @"kDetailIndetifier";
static NSString *const kDetailHeaderIndentifier = @"kDetailHeaderIndentifier";
static NSString *const kDetailFooterIndentifier = @"kDetailFooterIndentifier";


@interface GuestDetailViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *detaiCollectionView;
@property (nonatomic,strong)UICollectionViewLayout *collectionLayout;
@property (nonatomic,strong)ClientInfoModel *infoModel;


@end

@implementation GuestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpViews];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Settings 

- (void)setUpData {
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID],@"userid",[uts objectForKey:KToken],@"token", self.ciid,@"ciid",nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:KGetGuestInfoAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        self.infoModel = [[ClientInfoModel alloc] initWithDictionary:dic];
        [self.detaiCollectionView reloadData];
        NSLog(@"获取数据成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取数据失败");
    }];
    
}

- (void)setUpViews {
    self.collectionLayout = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(150, 150);
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 100);
        layout.footerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 100);
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

#pragma UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDetailIndetifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    cell.backgroundColor = [UIColor redColor];
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view =  [self.detaiCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDetailHeaderIndentifier forIndexPath:indexPath];
        view.backgroundColor = [UIColor greenColor];
        return view;

    }else {
        UICollectionReusableView *view =  [self.detaiCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDetailFooterIndentifier forIndexPath:indexPath];
        view.backgroundColor = [UIColor yellowColor];
        return view;
    }
   
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
