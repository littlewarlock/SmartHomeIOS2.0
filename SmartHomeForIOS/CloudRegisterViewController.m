//
//  Cloudregister.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/10.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CloudRegisterViewController.h"
#import "CloudLoginViewController.h"
#import "CloudLoginSuccessViewController.h"
#import "RegisterSuccessViewController.h"
#import "DataManager.h"

@interface CloudRegisterViewController (){
    
    IBOutlet UIView *promotView;
    
    __weak IBOutlet UIActivityIndicatorView *move;
}

@end

@implementation CloudRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"co-cloud账户注册";
    
    self.registerButton.layer.cornerRadius = 0;
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    
    promotView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    promotView.layer.borderWidth = 1;
    [promotView setHidden:YES];
    
    [self.registerButton setEnabled:NO];
    [self.email becomeFirstResponder];
}



//是否同意开关的切换
- (IBAction)change:(UIButton*)sender{
    sender.selected = !sender.selected;
    if(sender.selected){
        [self.registerButton setEnabled:YES];
    }else{
        [self.registerButton setEnabled:NO];
    }
}

- (IBAction)touch:(id)sender {
    [self.email resignFirstResponder];
    [self.cocloudid resignFirstResponder];
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//按下注册按钮后的格式检查
- (IBAction)registers:(id)sender {
    
    [self.email resignFirstResponder];
    [self.cocloudid resignFirstResponder];
    NSString *regexs = @"^[a-zA-Z0-9]*$";
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *predicates = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexs];
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([self.email.text isEqualToString:@""]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"电子邮件不能为空。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.email becomeFirstResponder];
        return ;
    }
    if([self.cocloudid.text isEqualToString:@""]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"Co-cloud-id不能为空。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.cocloudid becomeFirstResponder];
        return ;
    }
    if([emailTest evaluateWithObject:self.email.text] == NO){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"电子邮件不合法。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.email becomeFirstResponder];
        return ;
    }
    if ([predicates evaluateWithObject:self.cocloudid.text] == NO) {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"Co-cloud-id应为数字或字母大小写。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.cocloudid becomeFirstResponder];
        return ;
    }
    if([self.cocloudid.text length]<6){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"Co-cloud-id长度应不小于6位。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.cocloudid becomeFirstResponder];
        return ;
    }
    
    [self.email resignFirstResponder];
    [self.cocloudid resignFirstResponder];
    [self.registerButton setEnabled:NO];
    [promotView setHidden:NO];
    [move startAnimating];
    [self registerCheck];
    
}
//注册功能
-(void)registerCheck{
    NSDictionary *requestParam = @{@"cid":self.cocloudid.text,@"email":self.email.text,@"mac":self.mac};
    //    //请求php
    NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"proxyregister.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        NSString *result = completedOperation.responseJSON[@"result"];
        NSString *results = [NSString stringWithFormat:@"%@",result];
        [self.registerButton setEnabled:YES];
        [move stopAnimating];
        [promotView setHidden:YES];
        if([@"0" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"注册失败，请重新输入。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.email becomeFirstResponder];
        }else if([@"2" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备MAC地址取得失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.email becomeFirstResponder];
        }else if([@"3" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器该数据已存在。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.cocloudid becomeFirstResponder];
        }else if([@"4" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备非法。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"5" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器更新DB失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [self.email becomeFirstResponder];
            [alert show];
        }else if([@"6" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"邮件发送失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [self.email becomeFirstResponder];
            [alert show];
        }else if([@"7" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录信息更新失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [self.email becomeFirstResponder];
            [alert show];
        }else if([@"1" isEqualToString:results]){
            RegisterSuccessViewController* ss = [[RegisterSuccessViewController alloc]initWithNibName:@"RegisterSuccessViewController" bundle:nil];
            ss.texts = self.email.text;
            ss.cid = self.cocloudid.text;
            ss.mac = self.mac;
            [self.navigationController pushViewController:ss animated:YES];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"注册失败，请重新输入。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [self.registerButton setEnabled:YES];
        [move stopAnimating];
        [promotView setHidden:YES];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"注册失败，请重新输入。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        [self.email becomeFirstResponder];
    }];
    [engine enqueueOperation:op];
}

- (IBAction)finish:(id)sender {
    [sender resignFirstResponder];
}
@end
