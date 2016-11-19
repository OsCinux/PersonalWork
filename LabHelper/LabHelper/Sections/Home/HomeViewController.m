//
//  HomeViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/19.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "HomeViewController.h"

static NSString *kGuestCellResueIdentifier = @"kGuestCellResueIdentifier";

@interface HomeViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UIButton *addGuest;

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
    self.addGuest = ({
        UIButton *button = [UIButton new];
        
        button;
    });
   // self.tableView.tableFooterView = [];
}

- (void)setUpData {
    self.dataList = [[NSMutableArray alloc] init];
}



#pragma mark - Actions

#pragma mark UITableViewDelegate

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return  self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGuestCellResueIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGuestCellResueIdentifier];
    }
    return cell;
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
