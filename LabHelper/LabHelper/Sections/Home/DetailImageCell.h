//
//  DetailImageCell.h
//  LabHelper
//
//  Created by ljc on 2017/1/2.
//  Copyright © 2017年 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailImageCell : UICollectionViewCell

- (void)configWithImageURLString:(NSString *)imageURLString ;

- (void)setChoseBtnVisible:(BOOL)isvisible;

@end
