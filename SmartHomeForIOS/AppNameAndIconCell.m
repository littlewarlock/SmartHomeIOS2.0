//
//  AppNameAndIconCellTableViewCell.m
//  SmartHomeForIOS
//自定义的tableCell显示 app的列表
//  Created by riqiao on 15/8/26.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AppNameAndIconCell.h"
#import "AppInfoViewController.h"

@implementation AppNameAndIconCell
- (IBAction)chooseAppAction:(UIButton *)sender {
        if ([_delegate respondsToSelector:@selector(chooseAppAction:)]) {
            [_delegate chooseAppAction:sender];//调用委托方法，来实现页面的跳转
    }
}

- (IBAction)enableDisableAppAction:(UISwitch*)sender {
    if ([_delegate respondsToSelector:@selector(chooseAppAction:)]) {
        [_delegate enableDisableAppAction:sender];//调用委托方法，来实现页面的跳转
    }
}



@end
