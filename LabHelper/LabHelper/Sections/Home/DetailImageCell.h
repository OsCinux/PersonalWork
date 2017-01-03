//
//  DetailImageCell.h
//  LabHelper
//
//  Created by ljc on 2017/1/2.
//  Copyright © 2017年 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CellClickBlock)();

@interface DetailImageCell : UICollectionViewCell

@property(nonatomic, copy)CellClickBlock actionCellClick;

- (void)configWithImageURLString:(NSString *)imageURLString ;

- (void)setChoseBtnVisible:(BOOL)isvisible;


@end
