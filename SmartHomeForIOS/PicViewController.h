//
//  PicViewController.h
//  project1
//
//  Created by apple1 on 15/9/8.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalFileViewController.h"
@interface PicViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSMutableArray* picArray;

@property (strong, nonatomic) IBOutlet UITableView *tvContent;
@end
