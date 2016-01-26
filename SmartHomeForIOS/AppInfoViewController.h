//
//  AppInfoViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/27.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AppInfo.h"

@interface AppInfoViewController : UIViewController
@property (assign,nonatomic) NSInteger *appIndex;
@property (weak, nonatomic) IBOutlet UISwitch *appSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UITextView *appInfoTextView;
@property(weak,nonatomic) AppInfo * appInfo;

@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;

- (IBAction)enableDisableAppAction:(id)sender;


@end
