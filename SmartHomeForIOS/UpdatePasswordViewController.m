//
//  UpdatePasswordViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "CloudLoginViewController.h"
#import "DataManager.h"
#import "LoginViewController.h"
#import "RequestConstant.h"
#import <AVOSCloud/AVOSCloud.h>

@interface UpdatePasswordViewController (){
    
    IBOutlet UIButton *updateBtn;
    IBOutlet UIView *promotView;
    IBOutlet UILabel *promotLabel;
    __weak IBOutlet UIActivityIndicatorView *move;
    
}

@end

@implementation UpdatePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"co-cloud账户"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    [promotView setHidden:YES];
    [self.oldPassword becomeFirstResponder];
    promotView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    promotView.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)updateCheck{
    [move startAnimating];
    promotLabel.text = @"修改密码中...";
    [promotView setHidden:NO];
    NSDictionary *requestParam = @{@"email":self.email,@"cid":self.cid,@"passwd":self.oldPassword.text,@"new_pwd":self.NewPassword.text,@"mac":self.mac};
    //请求php
    NSString* url = Server_URL;
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"changepasswd.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        [move stopAnimating];
        [promotView setHidden:YES];
        NSString *result = completedOperation.responseJSON[@"result"];
        NSString *results = [NSString stringWithFormat:@"%@",result];
        [updateBtn setEnabled:YES];
        if([@"0" isEqualToString:results]){
            [updateBtn setEnabled:NO];
            [self logoutCheck];
        }else if([@"201" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"密码错误。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"301" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备非法。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"501" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器更新DB失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"601" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"邮件发送失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"修改密码失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [updateBtn setEnabled:YES];
        [move stopAnimating];
        [promotView setHidden:YES];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (IBAction)update:(id)sender {
    
    [self miss];
    self.oldPassword.inputView =nil;
    self.NewPassword.inputView =nil;
    self.passwordTwo.inputView =nil;
    NSString *regex = @"^[a-zA-Z0-9_-]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if([@"" isEqualToString:self.oldPassword.text]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"当前密码不能为空。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.oldPassword becomeFirstResponder];
        return;
    }else if([@"" isEqualToString:self.NewPassword.text]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"新密码不能为空。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.NewPassword becomeFirstResponder];
        return;
    }else if([@"" isEqualToString:self.passwordTwo.text]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"确认密码不能为空。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.passwordTwo becomeFirstResponder];
        return;
    }else if(self.NewPassword.text.length<8||self.NewPassword.text.length>16){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"密码长度应为8-16位。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.NewPassword becomeFirstResponder];
        return;
    }else if([self.NewPassword.text characterAtIndex:0]=='-'||[self.NewPassword.text characterAtIndex:0]=='_'){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"密码不能以符号开头。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.NewPassword becomeFirstResponder];
        return ;
    }else if([predicate evaluateWithObject:self.NewPassword.text] == NO||![self checkPassword:self.NewPassword.text]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"密码应为数字/字母大小写/-/_的组合。并至少有其中3种。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.NewPassword becomeFirstResponder];
        return ;
    }else if(![self.NewPassword.text isEqualToString:self.passwordTwo.text]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"确认密码和确认新密码不一致。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.NewPassword becomeFirstResponder];
        return ;
    }else{
        [updateBtn setEnabled:NO];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"修改密码功能将修改密码并关闭远程访问连接。\n\n是否修改密码？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"是",@"否",nil ];
        [alert show];
    }
}

- (IBAction)finish:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)touch:(id)sender {
    [self miss];
}

- (void)miss{
    [self.oldPassword resignFirstResponder];
    [self.NewPassword resignFirstResponder];
    [self.passwordTwo resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        [self miss];
        [self performSelector:@selector(updateCheck) withObject:nil afterDelay:0.5f];
    }else{
        [updateBtn setEnabled:YES];
    }
}

- (void)logoutCheck{
    [move startAnimating];
    promotLabel.text = @"注销中...";
    [promotView setHidden:NO];
    NSDictionary *requestParam = @{@"cid":self.cid,@"mac":self.mac};
    //请求php
    NSString* url = Server_URL;
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"logout.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [move stopAnimating];
        [promotView setHidden:YES];
        [updateBtn setEnabled:YES];
        //get data
        NSString *result = completedOperation.responseJSON[@"result"];
        NSString *results = [NSString stringWithFormat:@"%@",result];
        if([@"0" isEqualToString:results]){
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
                clc.cid = self.cid;
                clc.email = self.email;
                clc.mac = self.mac;
                [self.navigationController pushViewController:clc animated:YES];
            }
        }else if([@"301" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备非法。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.oldPassword becomeFirstResponder];
        }else if([@"1" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录状态更新失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.oldPassword becomeFirstResponder];
        }else if([@"2" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备注销失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.oldPassword becomeFirstResponder];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备注销失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.oldPassword becomeFirstResponder];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [move stopAnimating];
        [updateBtn setEnabled:YES];
        [promotView setHidden:YES];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.oldPassword becomeFirstResponder];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

-(NSInteger)checkPassword:(NSString*)nss{
    NSString *regex1 = @"^[a-zA-Z]*$";
    NSString *regex2 = @"^[0-9]*$";
    NSInteger a=0;
    NSInteger b=0;
    NSInteger c=0;
    NSInteger d=0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSPredicate *predicates = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    for(int s=0;s<nss.length;s++){
        //        NSString *firstStr=[nss substringWithRange:NSMakeRange(s, s+1)];
        char x=[nss characterAtIndex:s];
        NSString *ss=[[NSString alloc]initWithFormat:@"%c",x];
        if([predicate evaluateWithObject:ss] == YES){
            a=1;
        }
        if([predicates evaluateWithObject:ss] == YES){
            b=1;
        }
        if(x=='-'){
            c=1;
        }
        if(x=='_'){
            d=1;
        }
    }
    if(a+b+c+d>=3){
        return 1;
    }else{
        return 0;
    }
}

@end
