//
//  HomeViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicViewController.h"
#import "AppTableViewCell.h"
#import "IIViewDeckController.h"

@interface HomeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,AppCellDelegate, IIViewDeckControllerDelegate>

@property(weak,nonatomic) NSMutableArray * appList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *opType; //0:home 1:egress 2:sleep

@property BOOL modeChanging;
@end
