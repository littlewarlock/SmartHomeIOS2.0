//
//  TestTableViewCell.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppInfoDelegate.h"

@interface TestTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imagetest;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UILabel *labelr1;
@property (strong, nonatomic) IBOutlet UILabel *labelr2;
@property (strong, nonatomic) IBOutlet UILabel *labelr3;
@property (strong, nonatomic) IBOutlet UILabel *labelr4;
// 2015 11 09 add
@property (strong, nonatomic) IBOutlet UIButton *buttonAlarm;
@property (strong, nonatomic) IBOutlet UIImageView *imageRec;
@property (strong,nonatomic) NSString *alarming;
// 2015 11 09 add
// 2015 11 11 add
@property (strong,nonatomic) NSString *onlining;
// 2015 11 11 add

// 2015 12 30
@property (strong, nonatomic) IBOutlet UIImageView *imageModeRec;

// 2015 12 30

@property (strong, nonatomic) NSString *deviceID;

@property (assign,nonatomic) id<AppInfoDelegate> delegate;
@end
