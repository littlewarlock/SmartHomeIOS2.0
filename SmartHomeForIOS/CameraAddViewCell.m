//
//  CameraAddViewCell.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/10/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraAddViewCell.h"

@interface CameraAddViewCell ()


@end

@implementation CameraAddViewCell

- (void)awakeFromNib {
    // Initialization code
    _deviceInfo = [[DeviceInfo alloc]init];
    [self.buttonAdd.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (IBAction)buttonAddPressed:(UIButton *)sender {
    NSLog(@" CameraAddViewCell buttonAddPressed ");
    if ([_delegate respondsToSelector:@selector(chooseAppAction:)]) {
        [_delegate chooseAppAction:sender];//调用委托方法，来实现页面的跳转
    }

}

@end
