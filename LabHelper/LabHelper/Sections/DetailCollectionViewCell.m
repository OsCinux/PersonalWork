//
//  DetailCollectionViewCell.m
//  LabHelper
//
//  Created by ljc on 2016/12/27.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "DetailCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DetailCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIButton *chosenButton;


@end

@implementation DetailCollectionViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
   // self.chosenButton.hidden = YES;
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentImageView.image = nil;
    [self.contentImageView sd_cancelCurrentImageLoad];
}


#pragma mark - Public 

- (void)configWithImageURLString:(NSString *)imageURLString {
    NSURL *url = nil;
    if (![imageURLString hasPrefix:@"/var"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",KDisplayClientImageAddress,imageURLString]];
    } else {
        url = [NSURL URLWithString:imageURLString];
    }
    [self.contentImageView setImage:[UIImage imageWithContentsOfFile:imageURLString]];
   // [self.contentImageView sd_setImageWithURL:url];
    
}

@end
