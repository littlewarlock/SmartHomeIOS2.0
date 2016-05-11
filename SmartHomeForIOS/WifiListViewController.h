//
//  WifiListViewController.h
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/3.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WifiLIistCell.h"

@interface WifiListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,WifiLIistCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *wifiListTableview;

@end
