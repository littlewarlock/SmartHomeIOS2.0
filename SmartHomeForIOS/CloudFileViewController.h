//
//  CloudFileViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/13.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSUUIDTool.h"
#import "FileDialogViewController.h"
#import "MWPhotoBrowser.h"
#import "FileHandler.h"
#import "FDTableViewCell.h"
#import "CustomIOSAlertView.h"
@interface CloudFileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,FileDialogDelegate,MWPhotoBrowserDelegate,UIGestureRecognizerDelegate,CustomIOSAlertViewDelegate>

//@property(assign,nonatomic) BOOL isServerFile; //表示是否读的是服务器端的文件YES：读的是服务器端的 NO：读的是本地目录下的文件
@property (copy, nonatomic) NSString *cpath; //当前路径
@property (assign, nonatomic) BOOL isShowFile; //是否显示文件 YES：显示 NO：不显示文件 显示目录
@property (assign, nonatomic) BOOL isMultiple;//是否允许多选，YES：允许多选 NO：不允许多选
@property (copy, nonatomic) NSString *rootUrl; //存储当前用户的根目录
@property (assign, nonatomic) BOOL isInSharedFolder; //是否在共享文件夹下
@property (assign, nonatomic) BOOL isServerSessionTimeOut; //是否连接超时
@property (strong, nonatomic) IBOutlet UITableView *fileListTableView;
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (weak, nonatomic) IBOutlet UITabBarItem *item1;
@property (weak, nonatomic) IBOutlet UITabBarItem *item2;
@property (weak, nonatomic) IBOutlet UITabBarItem *item3;
@property (weak, nonatomic) IBOutlet UITabBarItem *item4;
@property (weak, nonatomic) IBOutlet UIButton *misButton;
@property (weak, nonatomic) IBOutlet UITabBar *moreBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem1;

@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem2;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem3;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem4;

@property (weak, nonatomic) FDTableViewCell *curCel;

@end
