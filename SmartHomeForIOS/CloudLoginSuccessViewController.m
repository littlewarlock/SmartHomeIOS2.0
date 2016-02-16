//
//  CloudLoginSuccessViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CloudLoginSuccessViewController.h"
#import "UpdatePasswordViewController.h"
#import "CloudLoginViewController.h"
#import "DataManager.h"
#import "LoginViewController.h"
#import "RequestConstant.h"
#import <AVOSCloud/AVOSCloud.h>

@interface CloudLoginSuccessViewController (){
    
    IBOutlet UIView *promotView;
    __weak IBOutlet UIActivityIndicatorView *move;
    __weak IBOutlet UIButton *cancelBtn;
}

@end

@implementation CloudLoginSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"co-cloud账户"];
    //后退按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    
    self.AccountText.text = self.email;
    self.cid.text = self.cocloudid;
    //风火轮矩形
    [promotView setHidden:YES];
    promotView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    promotView.layer.borderWidth = 1;
}
//注销功能
- (void)logoutCheck{
    [move startAnimating];
    [promotView setHidden:NO];
    NSDictionary *requestParam = @{@"cid":self.cocloudid,@"mac":self.mac};
    //请求php
    NSString* url = Server_URL;
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"logout.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [move stopAnimating];
        [promotView setHidden:YES];
        [cancelBtn setEnabled:NO];
        //get data
        NSString *result = completedOperation.responseJSON[@"result"];
        NSString *results = [NSString stringWithFormat:@"%@",result];
        if([@"0" isEqualToString:results]){
            //检查是否为外网
            if ([g_sDataManager.requestHost rangeOfString:url].location != NSNotFound) {
                //                g_sDataManager.logoutFlag=@"1";
                [g_sDataManager setUserName:@""];
                [g_sDataManager setPassword:@""];
                AVInstallation *currentInstallation = [AVInstallation currentInstallation];
                [currentInstallation removeObject:[g_sDataManager cId] forKey:@"channels"];
                [currentInstallation saveInBackground];
                LoginViewController *loginView= [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                loginView.isPushHomeView =YES;
                loginView.isShowLocalFileBtn =YES;
//                self.viewDeckController.toggleLeftView;
                [self.viewDeckController presentViewController:loginView animated:YES completion:nil];
            }else{
                CloudLoginViewController* clc = [[CloudLoginViewController alloc] initWithNibName:@"CloudLoginViewController" bundle:nil];
                clc.cid = self.cocloudid;
                clc.email = self.email;
                clc.mac = self.mac;
                [self.navigationController pushViewController:clc animated:YES];
            }
        }else if([@"1" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录状态更新失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"2" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备注销失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"301" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备非法。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备注销失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [move stopAnimating];
        [promotView setHidden:YES];
        [cancelBtn setEnabled:NO];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//后退按钮
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//按下更改密码按钮跳转
- (IBAction)update:(id)sender {
    UpdatePasswordViewController* up = [[UpdatePasswordViewController alloc]initWithNibName:@"UpdatePasswordViewController" bundle:nil];
    up.email = self.email;
    up.cid = self.cocloudid;
    up.mac = self.mac;
    [self.navigationController pushViewController:up animated:YES];
}
//按下注销按钮弹出提示框
- (IBAction)cancel:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"关闭远程访问将无法在外网访问设备。\n是否注销？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"是",@"否",nil ];
    [alert show];
}
//选择按钮“是”时启动注销功能
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        [cancelBtn setEnabled:NO];
        [self logoutCheck];
    }
}

@end
