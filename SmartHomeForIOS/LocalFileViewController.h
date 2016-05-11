//
//  LocalFileViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/6.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTableViewCell.h"
#import "FileDialogViewController.h"
#import "LocalFileHandler.h"
#import "MWPhotoBrowser.h"
#import "CustomIOSAlertView.h"
#import "KxMovieView.h"
@interface LocalFileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIDocumentInteractionControllerDelegate,FileDialogDelegate,MWPhotoBrowserDelegate,UIGestureRecognizerDelegate,CustomIOSAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *fileListTableView;

@property (weak, nonatomic) IBOutlet UITabBarItem *item1;
@property (weak, nonatomic) IBOutlet UITabBarItem *item2;
@property (weak, nonatomic) IBOutlet UITabBarItem *item3;
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;
@property (weak, nonatomic) IBOutlet UITabBar *moreBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem1;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem2;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem3;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem4;
@property (weak, nonatomic) IBOutlet UIButton *misButton;


@property (retain, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (strong, nonatomic) NSMutableDictionary *tableDataDic;

@property (strong, nonatomic) NSString *folderLocationStr;
@property (strong, nonatomic) NSString *cpath; //当前路径
@property (strong, nonatomic) NSString *cfolder;
@property  int requestType;
@property  BOOL isOpenFromAppList; // 从首页进入为no 从app列表进入为yes
@property (strong, nonatomic) NSString *opType; //操作的类型，op=1，是删除 op=2，时是上传 op=3时是复制 op=4时是移动 op=5 是重命名 op=6是新建文件夹 op=7 时下载 8时 备份-1时是取消
@property KxMovieView *kxvc;

@property (strong, nonatomic) FDTableViewCell *curCel;
/**
 *  是否处于编辑状态
 */
@property (assign, nonatomic) BOOL isMultipleEdit;

@end
