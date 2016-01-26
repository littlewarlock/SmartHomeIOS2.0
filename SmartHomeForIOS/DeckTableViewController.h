//
//  DeckTableViewController.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/6.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RCellHeight 60
#define RMarginX 8
#define RMarginY 4

@interface DeckTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
