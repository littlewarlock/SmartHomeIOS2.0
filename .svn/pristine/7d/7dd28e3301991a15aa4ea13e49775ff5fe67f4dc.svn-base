//
//  regsuccess.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/18.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "RegisterSuccessViewController.h"
#import "CloudLoginViewController.h"
#import "DataManager.h"

@interface RegisterSuccessViewController (){
    UIButton *left ;
}

@end

@implementation RegisterSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
    self.navigationItem.title = @"co-cloud账户注册";
    
    self.textView.text = [[NSString alloc]initWithFormat:@"密码已经发送到邮箱:%@。请查收并登录。",self.texts];
    [self.textView setEditable:NO];
    
    left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
}
//导航条后退按钮按下
- (void)returnAction:(UIBarButtonItem *)sender {
    [left setEnabled:NO];
    NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"checkshowstatus.php" params:nil httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [left setEnabled:YES];
        NSString *result = completedOperation.responseJSON[@"result"];
        NSLog(@"op.responseJSON==%@",completedOperation.responseJSON);
        if([@"0" isEqualToString:result]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录信息取得失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"1" isEqualToString:result]){
            NSString *cologinflg = completedOperation.responseJSON[@"cologinflg"];
            NSString *registerflg = completedOperation.responseJSON[@"registerflg"];
            if([@"0" isEqualToString:cologinflg]&&[@"1" isEqualToString:registerflg]){
                NSString *cids = completedOperation.responseJSON[@"cid"];
                NSString *emails = completedOperation.responseJSON[@"email"];
                NSString *efg = completedOperation.responseJSON[@"emailflg"];
                NSString *mac2 = completedOperation.responseJSON[@"mac"];
                CloudLoginViewController* clg = [[CloudLoginViewController alloc]initWithNibName:@"CloudLoginViewController" bundle:nil];
                clg.email = emails;
                clg.cid = cids;
                clg.emailflg = efg;
                clg.mac = mac2;
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
        [left setEnabled:YES];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
