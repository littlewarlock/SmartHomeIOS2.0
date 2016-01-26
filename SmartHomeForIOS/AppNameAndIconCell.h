//
//  AppNameAndIconCellTableViewCell.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/26.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppInfoDelegate.h"

@interface AppNameAndIconCell : UITableViewCell




@property (strong,nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *iconButton;
@property (strong, nonatomic) IBOutlet UISwitch *enableDisableSwitch;


- (IBAction)chooseAppAction:(UIButton *)sender;
- (IBAction)enableDisableAppAction:(UISwitch*)sender;

@property (assign, nonatomic) id<AppInfoDelegate> delegate;

@end
