//
//  LoginViewController.h
//  project1
//
//  Created by apple1 on 15/8/31.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "LocalFileViewController.h"
#import "IpInfo.h"
#import "AsyncUdpSocket.h"
#import "GTMBase64.h"
#import "UIHelper.h"
#import "LoginViewDelegate.h"

@interface LoginViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) NSMutableArray* arrayIps1;
@property (strong,nonatomic) NSMutableArray* arrayIps2;
@property (weak, nonatomic) UIView* loadingView;



//是否访问网络接口
@property (assign, nonatomic) BOOL isConnetNetServer;
@property (strong, nonatomic) NSString *postLoginIp;//提交的ip

@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (strong, nonatomic) IBOutlet UITextField *textFieldIp;//展示的ip
@property (strong, nonatomic) IBOutlet UITableView *tvList;
@property (strong, nonatomic) IBOutlet UITableView *tvSearch;
- (IBAction)listBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UIView *ipView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
- (IBAction)searchBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordField;

@property (strong, nonatomic) IBOutlet UIButton *checkBox;
@property (assign, nonatomic) BOOL isShowLocalFileBtn; //是否显示本地文档按钮
@property (assign, nonatomic) BOOL isPushHomeView; //是否跳转到主页
@property (strong, nonatomic) IBOutlet UIButton *localFileBtn;
@property(assign, nonatomic) id<LoginViewDelegate> loginViewDelegate; //登录画面的代理

- (IBAction)checkBtn:(UIButton *)sender;
- (IBAction)showLocalFileAction:(id)sender;
- (IBAction)loginAction:(UIButton *)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)ipTextFieldEditngChanged:(id)sender;
- (IBAction)backgroundAction:(id)sender;

@end
