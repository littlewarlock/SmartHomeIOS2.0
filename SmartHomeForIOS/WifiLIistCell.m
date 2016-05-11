//
//  WifiLIistCell.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/4.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "WifiLIistCell.h"
#import "ApSettingViewController.h"

@implementation WifiLIistCell

- (void)awakeFromNib {
    self.userInteractionEnabled = YES;
    
    [self.btn addTarget:self action:@selector(aaa) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
    }
    return self;
}

- (void)aaa
{
    if ([_delegate respondsToSelector:@selector(setupAp)]) {
        [_delegate setupAp];
    }
}



@end
