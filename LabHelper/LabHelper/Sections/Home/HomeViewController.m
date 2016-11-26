//
//  HomeViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/19.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "HomeViewController.h"
#import "GuestDetailViewController.h"
#import "ClientModel.h"


static NSString *kGuestCellResueIdentifier = @"kGuestCellResueIdentifier";

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *guestList;
@property (nonatomic, strong) NSMutableArray *guestInfoList;
@property (nonatomic, strong) UIButton *addGuestButton;
@property (nonatomic, strong) UIView *footerView;

@end

@implementation HomeViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    [self setUpViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark init
- (void)setUpViews {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setUpData {
    self.guestList = [[NSMutableArray alloc] init];
    self.guestInfoList = [[NSMutableArray alloc] init];
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID],@"userid",[uts objectForKey:KToken],@"token", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:KGetGuestListAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *modelArray = responseObject[@"ClientsData"];
        for (NSDictionary *dic in modelArray) {
            ClientModel *model = [ClientModel modelObjectWithDictionary:dic];
            [self.guestList addObject:model];
        }
        [self.tableView reloadData];
        NSLog(@"获取数据成功");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取数据失败");
    }];
    
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ClientModel *model = self.guestList[indexPath.row];
    [self performSegueWithIdentifier:@"showCustomDetail" sender:model];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.guestList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGuestCellResueIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGuestCellResueIdentifier];
    }
    ClientModel *model = self.guestList[indexPath.row];
    cell.textLabel.text = model.ciName;
    cell.imageView.image = [UIImage imageNamed:@"QRCode"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ClientModel *model = sender;
    if ([segue.identifier isEqualToString:@"showCustomDetail"]) {
        GuestDetailViewController *vc = segue.destinationViewController;
        vc.ciid = model.ciId;
    }
}

@end
