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
#import "LoginInViewController.h"


static NSString *kGuestCellResueIdentifier = @"kGuestCellResueIdentifier";

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *addGuestButton;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSMutableArray *ciidList;

@end

@implementation HomeViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.guestList = [[NSMutableArray alloc] init];
    self.ciidList = [[NSMutableArray alloc] init];
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
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf setUpData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setUpData {
    NSUserDefaults *uts = [NSUserDefaults standardUserDefaults];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[uts objectForKey:KUserID],@"userid",[uts objectForKey:KToken],@"token", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:KGetGuestListAddress parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *string = [responseObject objectForKey:@"remark"];
        if ([string isEqualToString:@"帐号或密码错误"]) {//此时代表token过期
            [self handleTokenOverTime];
        }else {
            NSArray *modelArray = responseObject[@"ClientsData"];
            [self.guestList removeAllObjects];
            [self.ciidList  removeAllObjects];
            for (NSDictionary *dic in modelArray) {
                ClientModel *model = [ClientModel modelObjectWithDictionary:dic];
                [self.ciidList addObject:model.ciId];
                [self.guestList addObject:model];
                [self saveToLocal:self.ciidList];
            }
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
            NSLog(@"获取数据成功");
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取数据失败");
    }];
    
}

- (void)saveToLocal:(NSMutableArray *)list {
    NSArray *data = [NSArray arrayWithArray:list];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:data forKey:KCiidList];
}
- (void)handleTokenOverTime {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录过期，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginInViewController *loginVC = [storyBoard instantiateViewControllerWithIdentifier:@"loginVC"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Public
- (void)refreshData {
    [self setUpData];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ClientModel *model = self.guestList[indexPath.row];
    [self performSegueWithIdentifier:@"showCustomDetail" sender:model];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
