//
//  FileDialogViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/28.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileDialogDelegate.h"

@interface FileDialogViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(assign,nonatomic) BOOL isServerFile; //表示是否读的是服务器端的文件YES：读的是服务器端的 NO：读的是本地目录下的文件
@property(assign,nonatomic) BOOL isSelectFileMode; //表示选择文件模式，用户只能选择文件
@property(strong,nonatomic) NSString *selectedFile;//表示用户选择的文件
@property (copy, nonatomic) NSString *cpath; //当前路径
@property (assign, nonatomic) BOOL isShowFile; //是否显示文件 YES：显示 NO：不显示文件 显示目录
@property (assign, nonatomic) BOOL isMultiple;//是否允许多选，YES：允许多选 NO：不允许多选
@property (copy, nonatomic) NSString *rootUrl; //存储当前用户的根目录
@property (weak, nonatomic) IBOutlet UITableView *fileListTableView;
@property (weak, nonatomic) IBOutlet UIButton *returnLastDirBtn;
@property (strong, nonatomic) IBOutlet UIButton *returnRootDirBtn;

@property(assign, nonatomic) id<FileDialogDelegate> fileDialogDelegate; //文件选择控件的代理
@end
