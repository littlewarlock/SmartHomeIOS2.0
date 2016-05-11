//
//  HomeViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "HomeViewController.h"
#import "AppViewController.h"
#import "AppInfo.h"
#import "AppTableViewCell.h"
#import "AppDelegate.h"
#import "KxMenu.h"
#import "UserEditViewController.h"
#import "ShareListViewController.h"
#import "LoginViewController.h"
#import "CameraListViewController.h"
#import "ProgressBarViewController.h"
#import "CloudFileViewController.h"
#import "BaiDuCloudViewController.h"
#import "DataManager.h"
#import "PasswordViewController.h"
#import "FileTools.h"
//#import "AppButton.h"
#import "FunctionManageTools.h"
#import "AlarmMessageListViewController.h"
#import "AlarmMessageDetailViewController.h"
#import "RootLoginViewController.h"
#import "CloudLoginViewController.h"
#import "CloudLoginSuccessViewController.h"
#import "H264ViewController.h"
#import "CameraPhotoViewController.h"
#import "CameraSnapshotHistoryViewController.h"
#import "ThunderViewController.h"
#import "RouterViewController.h"

#define kMainScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kMainScreenWidth  [[UIScreen mainScreen] bounds].size.width
@interface HomeViewController () <UIGestureRecognizerDelegate, IIViewDeckControllerDelegate>
{
    UIView *bottomView;
    UIView *loadingView;
}
@end
@implementation HomeViewController

static NSString * CellIdentifier = @"AppCell";

AppDelegate *appDelegate ;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
// 2015 11 25 start
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comeFromRemoteNotiHome:) name:@"PUSHTOALARMDETAIL" object:nil];
// 2015 11 25 end

    UIImage* img=[UIImage imageNamed:@"sidebar"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 22, 22);
    [left setBackgroundImage:img forState:UIControlStateNormal];
    [left addTarget: self.viewDeckController action: @selector(toggleLeftView) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=item;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:15.0/255 green:131.0/255 blue:255.0/255 alpha:1];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.layer.borderWidth = 0;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线
    [self.tableView registerClass:[AppTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SelectedAppInfo" ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSMutableArray *oldAdressArr  =  [dictionary objectForKey:@"SelectedAppInfo"];
    //NSLog(plistPath);
    if (oldAdressArr.count !=0) {
        _appList = [FunctionManageTools readSavedApp];
    }else{
        appDelegate = [[UIApplication sharedApplication] delegate];
        _appList = appDelegate.selectedAppArray;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;

    self.navigationItem.title = @"首页";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0,height - 50,width/3,50)];
    [homeButton setTitle:@"在家" forState:UIControlStateNormal];
    [homeButton setBackgroundColor:[UIColor whiteColor]];
    [homeButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
    [homeButton setImage:[UIImage imageNamed:@"home-down"] forState:(UIControlStateNormal)];
    //[homeButton centerImageAndTitle];
    homeButton.tag=100;
    [homeButton addTarget:self action:@selector(modeChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:homeButton];
    
    UIButton *egressButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3,height - 50,width/3,50)];
    [egressButton setTitle:@"外出" forState:UIControlStateNormal];
    [egressButton setBackgroundColor:[UIColor whiteColor]];
    [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
    //[homeButton centerImageAndTitle];
    egressButton.tag=101;
    [egressButton addTarget:self action:@selector(modeChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:egressButton];
    

    UIButton *sleepButton = [[UIButton alloc] initWithFrame:CGRectMake(width*2/3,height - 50,width/3,50)];
    [sleepButton setTitle:@"睡眠" forState:UIControlStateNormal];
    [sleepButton setBackgroundColor:[UIColor whiteColor]];
    [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
    //[homeButton centerImageAndTitle];
    sleepButton.tag=102;
    [sleepButton addTarget:self action:@selector(modeChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sleepButton];
 
    // 添加底部蓝色滑块
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 4, kMainScreenWidth / 3, 4)];
    [bottomView setBackgroundColor:[UIColor colorWithRed:0.0 / 255 green:160.0 / 255 blue:226.0 / 255 alpha:1]];
    [self.view addSubview:bottomView];
    
    self.viewDeckController.panningGestureDelegate = self;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:@"getmode" forKey:@"opt"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/smarthome/app",requestHost];

    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_GLOBAL_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        NSLog(@"[operation responseJSON]-->>%@",responseJSON);
        
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"success"])//成功
        {
            if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"mode"]] isEqualToString: @"0"])//成功
            {
                UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
                UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
                UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
                [homeButton setImage:[UIImage imageNamed:@"home-down"] forState:(UIControlStateNormal)];
                [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
                [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
                [homeButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
                [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                // 设置底部滑动条
                CGRect frame = CGRectMake(0, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
                bottomView.frame = frame;
                
            }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"mode"]] isEqualToString: @"1"])//修改成功
            {
                UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
                UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
                UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
                [homeButton setImage:[UIImage imageNamed:@"home1"] forState:(UIControlStateNormal)];
                [egressButton setImage:[UIImage imageNamed:@"egress_down"] forState:(UIControlStateNormal)];
                [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
                [homeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [egressButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
                [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                // 设置底部滑动条
                CGRect frame = CGRectMake(kMainScreenWidth / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
                bottomView.frame = frame;
                
            }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"mode"]] isEqualToString: @"2"]){
                UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
                UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
                UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
                [homeButton setImage:[UIImage imageNamed:@"home1"] forState:(UIControlStateNormal)];
                [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
                [sleepButton setImage:[UIImage imageNamed:@"sleep-down"] forState:(UIControlStateNormal)];
                [homeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [sleepButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
                // 设置底部滑动条
                CGRect frame = CGRectMake(kMainScreenWidth * 2 / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
                bottomView.frame = frame;
            }
        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"timeout"] ||
                 [[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]
                 ){
            [UIHelper showLoginViewWithServerSessionTimeOut: self];
        } else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];

}

//2015 11 25 start hgc
-(void)comeFromRemoteNotiHome:(NSNotification*)notification{
    NSLog(@"comeFromRemoteNoti");
    NSObject *content = [notification object];
    NSLog(@"comeFromRemoteNotiHome==%@",content);
    
    //if cunzai goto
    //then xinjian
    Boolean isPush = YES;
    if ([self.navigationController.visibleViewController isKindOfClass:[AlarmMessageListViewController class]]) {
        NSLog(@"this is it");
        AlarmMessageListViewController *alarmList = self.navigationController.viewControllers[0];
        NSLog(@"[alarmList refreshData]");
//2016 01 20 start
//        [alarmList refreshData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"alarmlistrefreshdata" object:nil];
//2016 01 20 end
        isPush = NO;
    }else{
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[AlarmMessageListViewController class]]) {
                NSLog(@"have one");
                AlarmMessageListViewController *alarmList = vc;
                //2016 01 20
//                self.navigationController.navigationBarHidden = NO;
                [self.navigationController popToViewController:alarmList animated:YES];
                //
                isPush = NO;
                break;
            }
            NSLog(@"vc1=%@",self.navigationController.presentingViewController);
            NSLog(@"vc2=%@",self.navigationController.visibleViewController);
            NSLog(@"vc=%@",vc);
        }
    }
    if (isPush) {
        AlarmMessageListViewController *alarmList = [[AlarmMessageListViewController alloc]initWithNibName:@"AlarmMessageListViewController" bundle:nil];
        [self.navigationController pushViewController:alarmList animated:YES];
    }
}
//2015 11 25 end

- (void)awakeFromNib {

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _appList = appDelegate.selectedAppArray;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark TableView DataSource And Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    if (_appList && _appList.count>0) {
        number = (_appList.count - 1) + 1;
        NSLog(@"%zi", number);
    }else{
        number =0;
        
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppTableViewCell *cell =(AppTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[AppTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSInteger index = indexPath.row;

    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    cell.cellDelegate=self;
    [cell bindApps:_appList[index]];
    
    //获得显示的app
    AppInfo *appInfo = (AppInfo *)_appList[index];
    //判断迅雷app是否被用户打开
    BOOL isOn = [appInfo.appName isEqualToString:@"迅雷"];
    if (isOn == YES) {
        [thunderTools thunderOn:isOn];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RCellHeight;
}

#pragma mark -
#pragma mark TapButton Action

- (void)appCell:(AppTableViewCell *)cell actionWithFlag:(NSInteger)flag
{
    NSLog(@"flag:%zi", flag);
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        
        [self.viewDeckController toggleLeftView];
        return;
    }
    //点击不同的按钮进行不同的处理
    switch (flag)
    {
        case 1:{
            CloudFileViewController *cloudView = [[CloudFileViewController alloc]initWithNibName:@"CloudFileViewController" bundle:nil];
            cloudView.isShowFile =YES;
            cloudView.isInSharedFolder = NO;
            cloudView.cpath =@"/";
            [self.navigationController pushViewController:cloudView animated:YES];
            break;
        }
        case 2:{
            CameraListViewController *cameraListVC = [[CameraListViewController alloc]initWithNibName:@"CameraListViewController" bundle:nil];
            [self.navigationController pushViewController:cameraListVC animated:YES];
            break;
        }
        case 4:{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"功能升级中..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            break;
            
            BaiDuCloudViewController *baiduCloudVC = [[BaiDuCloudViewController alloc]
                                                      initWithNibName:@"BaiDuCloudViewController" bundle:nil];
            [self.navigationController pushViewController:baiduCloudVC animated:YES];
            break;
        }
        case 5:{
            ShareListViewController *shareList = [[ShareListViewController alloc]                                                    initWithNibName:@"ShareListViewController" bundle:nil];
            [self.navigationController pushViewController:shareList animated:YES];
            break;
        }
        case 6:{
            //test
//            H264ViewController *h264 = [[H264ViewController alloc]initWithNibName:@"H264ViewController" bundle:nil];
//            [self.navigationController pushViewController:h264 animated:YES];
            
//            CameraSnapshotHistoryViewController *vc = [[CameraSnapshotHistoryViewController alloc]initWithNibName:@"CameraSnapshotHistoryViewController" bundle:nil];
//            [self.navigationController pushViewController:vc animated:YES];
            
            AlarmMessageListViewController *alarmList = [[AlarmMessageListViewController alloc]
                                                 initWithNibName:@"AlarmMessageListViewController" bundle:nil];
            [self.navigationController pushViewController:alarmList animated:YES];
            break;
        }
        case 7:{
            //请求php
            NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
            [engine useCache];
            MKNetworkOperation *op = [engine operationWithPath:@"checkshowstatus.php" params:nil httpMethod:@"POST"];
            //操作返回数据
            [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
                NSString *result = completedOperation.responseJSON[@"result"];
                NSLog(@"op.responseJSON==%@",completedOperation.responseJSON);
                if([@"0" isEqualToString:result]){
                    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录信息取得失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }else if([@"1" isEqualToString:result]){
                    NSString *cologinflg = completedOperation.responseJSON[@"cologinflg"];
                    //                    int cfg = [cologinflg intValue];
                    NSString *registerflg = completedOperation.responseJSON[@"registerflg"];
                    //                    int rfg = [registerflg intValue];
                    NSString *mac = completedOperation.responseJSON[@"mac"];
                    if([@"0" isEqualToString:cologinflg]&&[@"0" isEqualToString:registerflg]){
                        RootLoginViewController *cloudLogin = [[RootLoginViewController alloc]initWithNibName:@"RootLoginViewController" bundle:nil];
                        cloudLogin.mac = mac;
                        [self.navigationController pushViewController:cloudLogin animated:YES];
                    }else if([@"0" isEqualToString:cologinflg]&&[@"1" isEqualToString:registerflg]){
                        NSString *cids = completedOperation.responseJSON[@"cid"];
                        NSString *emails = completedOperation.responseJSON[@"email"];
                        NSString *efg = completedOperation.responseJSON[@"emailflg"];
                        NSString *mac = completedOperation.responseJSON[@"mac"];
                        CloudLoginViewController* clg = [[CloudLoginViewController alloc]initWithNibName:@"CloudLoginViewController" bundle:nil];
                        clg.email = emails;
                        clg.cid = cids;
                        clg.emailflg = efg;
                        clg.mac = mac;
                        [self.navigationController pushViewController:clg animated:YES];
                    }else if([@"1" isEqualToString:cologinflg]&&[@"1" isEqualToString:registerflg]){
                        NSString *cids = completedOperation.responseJSON[@"cid"];
                        NSString *emails = completedOperation.responseJSON[@"email"];
                        NSString *mac = completedOperation.responseJSON[@"mac"];
                        CloudLoginSuccessViewController* clg = [[CloudLoginSuccessViewController alloc]initWithNibName:@"CloudLoginSuccessViewController" bundle:nil];
                        clg.email = emails;
                        clg.cocloudid = cids;
                        clg.mac = mac;
                        [self.navigationController pushViewController:clg animated:YES];
                    }else{
                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录信息取得失败。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                    }
                }else{
                    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录信息取得失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
            }];
            [engine enqueueOperation:op];
            break;
        }
        case 8:{
            LocalFileViewController *localFileView = [[LocalFileViewController alloc]
                                                      initWithNibName:@"LocalFileViewController" bundle:nil];
            localFileView.isOpenFromAppList = YES;
            [self.navigationController pushViewController:localFileView animated:YES];
            break;
        }
        case 9:{
            //            ThunderViewController *thunderViewController = [[ThunderViewController alloc] init];
            //            [self.navigationController pushViewController:thunderViewController animated:YES];
            
            
        }
        case 10:{
            RouterViewController *outer = [[RootLoginViewController alloc] initWithNibName:@"RouterViewController" bundle:nil];
            [self.navigationController pushViewController:outer animated:YES];
            break;
        }
        case 11:{
            //进度管理
            [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
            break;
        }
        case 12:{
            ThunderViewController *thunderViewController = [[ThunderViewController alloc] init];
            [self.navigationController pushViewController:thunderViewController animated:YES];
            break;
        }
        default:
            break;
    }
    
}





- (void) homeAction:(UIButton *)sender {
    
    loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"模式切换中，请等待..." ];
    [self.view addSubview:loadingView];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:@"setmode" forKey:@"opt"];
    [dic setValue:@"0" forKey:@"mode"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/smarthome/app",requestHost];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_GLOBAL_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        NSLog(@"[operation responseJSON]-->>%@",responseJSON);
        
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"success"])//成功
        {
            if (![[responseJSON objectForKey:@"message"]isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[responseJSON objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
            }
            
            UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
            UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
            UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
            [homeButton setImage:[UIImage imageNamed:@"home-down"] forState:(UIControlStateNormal)];
            [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
            [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
            [homeButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
            [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            // 设置底部滑动条
            CGRect frame = CGRectMake(0, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
            bottomView.frame = frame;

        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"timeout"] ||
                 [[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]
                 ){
            [UIHelper showLoginViewWithServerSessionTimeOut: self];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
        }
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        //self.modeChanging = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求超时" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }];
    [engine enqueueOperation:op];

}

- (void) egressAction:(UIButton *)sender {
    loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"模式切换中，请等待..." ];
    [self.view addSubview:loadingView];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:@"setmode" forKey:@"opt"];
    [dic setValue:@"1" forKey:@"mode"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/smarthome/app",requestHost];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_GLOBAL_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        NSLog(@"[operation responseJSON]-->>%@",responseJSON);
        
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"success"])//成功
        {
            if (![[responseJSON objectForKey:@"message"]isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[responseJSON objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
            }
            
            UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
            UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
            UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
            [homeButton setImage:[UIImage imageNamed:@"home1"] forState:(UIControlStateNormal)];
            [egressButton setImage:[UIImage imageNamed:@"egress_down"] forState:(UIControlStateNormal)];
            [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
            [homeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [egressButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
            [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            // 设置底部滑动条
            CGRect frame = CGRectMake(kMainScreenWidth / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
            bottomView.frame = frame;

        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"timeout"] ||
                 [[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]
                 ){
            [UIHelper showLoginViewWithServerSessionTimeOut: self];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
        }
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        //self.modeChanging = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求超时" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }];
    [engine enqueueOperation:op];

}

- (void) sleepAction:(UIButton *)sender {

    loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"模式切换中，请等待..." ];
    [self.view addSubview:loadingView];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:@"setmode" forKey:@"opt"];
    [dic setValue:@"2" forKey:@"mode"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/smarthome/app",requestHost];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_GLOBAL_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        NSLog(@"[operation responseJSON]-->>%@",responseJSON);
        
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"success"])//成功
        {
            if (![[responseJSON objectForKey:@"message"]isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[responseJSON objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
            }
            
            UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
            UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
            UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
            [homeButton setImage:[UIImage imageNamed:@"home1"] forState:(UIControlStateNormal)];
            [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
            [sleepButton setImage:[UIImage imageNamed:@"sleep-down"] forState:(UIControlStateNormal)];
            [homeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [sleepButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
            // 设置底部滑动条
            CGRect frame = CGRectMake(kMainScreenWidth * 2 / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
            bottomView.frame = frame;


        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"timeout"] ||
        [[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]
                 ){
            [UIHelper showLoginViewWithServerSessionTimeOut: self];
        } else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
        }
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        //self.modeChanging = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请求超时" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }];
    [engine enqueueOperation:op];

}

- (void) modeChange:(UIButton *)sender {
    
    if(sender.tag == 100){
        self.opType = @"在家";
    }else if (sender.tag == 101){
        self.opType = @"外出";
    }else if (sender.tag == 102){
        self.opType = @"睡眠";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"是否切换到“%@”模式",sender.titleLabel.text] message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}
-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //delete user
    if(buttonIndex ==0 ){
        if([self.opType isEqualToString:@"在家"]){
            [self homeAction:nil ];
        }else if([self.opType isEqualToString:@"外出"]){
            [self egressAction:nil ];
        }else if([self.opType isEqualToString:@"睡眠"]){
            [self sleepAction:nil ];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        
        [self.viewDeckController toggleLeftView];
        return;
    }
    AppTableViewCell *cell =(AppTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[AppTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self appCell:cell actionWithFlag:cell.actionIndex];
}


- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self.viewDeckController action:@selector(toggleLeftView)];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self.viewDeckController action:@selector(toggleLeftView)];
    [(IIViewDeckController*)self.viewDeckController.leftController closeLeftView];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        CGPoint point = [touch locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath!=nil) {
            return YES;
        }
    }else{
        return NO;
    }
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        
        [self.viewDeckController toggleLeftView];
    }
    
}



@end
