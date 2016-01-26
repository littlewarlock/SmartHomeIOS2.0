//
//  CameraAddViewCell.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/10/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppInfoDelegate.h"
#import "DeviceInfo.h"
@interface CameraAddViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *labelAdded;
//@property (strong, nonatomic) IBOutlet UILabel *labelAdd;
@property (strong, nonatomic) IBOutlet UIButton *buttonAdd;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraName;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraType;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraIP;

@property (assign,nonatomic) id<AppInfoDelegate> delegate;
@property (strong,nonatomic) NSString *brand;
@property (strong,nonatomic) NSString *model;

//设备信息
@property (strong,nonatomic) DeviceInfo *deviceInfo;
- (IBAction)buttonAddPressed:(UIButton *)sender;
@end
