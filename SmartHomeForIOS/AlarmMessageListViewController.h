//
//  AlarmMessageListViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface AlarmMessageListViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>

- (void)refreshData;
- (void)refreshDataMessage;

@end
