//
//  DetailImageCell.m
//  LabHelper
//
//  Created by ljc on 2017/1/2.
//  Copyright © 2017年 meitu. All rights reserved.
//

#import "DetailImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DetailImageCell()
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIButton *choseBtn;

@end

@implementation DetailImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.choseBtn.hidden = YES;
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
   [self.contentImageView sd_setImageWithURL:url];
    
}

-(void)setChoseBtnVisible:(BOOL)isvisible {
    self.choseBtn.hidden = !isvisible;
}
@end
