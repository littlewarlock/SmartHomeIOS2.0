//
//  PasswordViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/9/10.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "PasswordViewController.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "HomeViewController.h"
#import "UIHelper.h"
@implementation PasswordViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置修改密码边框及圆角
    [self setupBorder];
    
    self.title = @"修改密码";
    [self.passwordOld setSecureTextEntry:YES];
    [self.passwordNew setSecureTextEntry:YES];
    [self.passwordNewConfirm setSecureTextEntry:YES];
    
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame =CGRectMake(200, 0, 32, 32);
    [bt setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [bt addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itm=[[UIBarButtonItem alloc]initWithCustomView:bt];
    self.navigationItem.leftBarButtonItem=itm;
    
}
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


//设置修改密码圆角
- (void)setupBorder
{
    //旧密码
    self.passwordOld.layer.cornerRadius = 2.0;
    
    //新密码
    self.passwordNew.layer.cornerRadius = 2.0;
    
    //确认密码
    self.passwordNewConfirm.layer.cornerRadius = 2.0;
    
    //确认修改按钮
    self.confirmButton.layer.cornerRadius = 2.0;
}


- (IBAction)confirmAction:(id)sender {
    
    NSString *regexs = @"^[a-zA-Z0-9]*$";
    NSPredicate *predicates = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexs];
    if(self.passwordOld.text.length==0 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入旧密码" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }else if(self.passwordNew.text.length==0 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入新密码" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }else if(self.passwordNewConfirm.text.length==0 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请确认新密码" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }else if ([self.passwordNewConfirm.text compare: self.passwordNew.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"新密码不一致" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }else if(self.passwordNew.text.length>20 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码长度不能超过20位" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }else if ([predicates evaluateWithObject:self.passwordNewConfirm.text] == NO) {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码应该由字母或数字组成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        __block NSError *error = nil;
        [dic setValue:self.userName forKey:@"uname"];
        [dic setValue:self.passwordOld.text forKey:@"upasswd"];
        [dic setValue:self.passwordNew.text forKey:@"newpasswd1"];
        [dic setValue:self.passwordNewConfirm.text forKey:@"newpasswd2"];
        
        NSString* requestHost = [g_sDataManager requestHost];
        NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];

        MKNetworkOperation *op = [engine operationWithPath:REQUEST_CHANGEPWD_URL params:dic httpMethod:@"POST" ssl:NO];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {
            NSLog(@"[operation responseData]-->>%@", [operation responseString]);
            NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
            NSLog(@"[operation responseJSON]-->>%@",responseJSON);
            if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//修改成功
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"修改密码成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"2"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"旧密码不正确" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
            }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]){
                [UIHelper showLoginViewWithServerSessionTimeOut:self ];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码修改失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        }];
        [engine enqueueOperation:op];
        
    }
}

-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
    
}

- (IBAction)closeInput:(id)sender {
    [self.passwordOld resignFirstResponder];
    [self.passwordNew resignFirstResponder];
    [self.passwordNewConfirm resignFirstResponder];
    
}

@end