//
//  HomeViewController.h
//  LabHelper
//
//  Created by ljc on 2016/11/19.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *guestList;


@end
