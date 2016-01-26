//
//  VideoCollctionViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/24.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileDialogViewController.h"


@interface VideoTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FileDialogDelegate>
@property (weak, nonatomic) IBOutlet UITableView *videoTableView;
@end
