//
//  AppViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/25.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppInfoDelegate.h"
#import "AppInfo.h"

@interface AppViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AppInfoDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property(weak,nonatomic) NSMutableArray * appList;

@end
