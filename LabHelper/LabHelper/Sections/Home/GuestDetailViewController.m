//
//  GuestDetailViewController.m
//  LabHelper
//
//  Created by ljc on 2016/11/23.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "GuestDetailViewController.h"

@interface GuestDetailViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *DetaiCollectionView;
@property (nonatomic,strong)UICollectionViewLayout *collectionLayout;


@end

@implementation GuestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
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
