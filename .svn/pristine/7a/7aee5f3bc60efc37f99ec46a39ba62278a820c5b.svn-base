//
//  RootLoginViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/2.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "RootLoginViewController.h"
#import "CloudRegisterViewController.h"

@interface RootLoginViewController ()

@end

@implementation RootLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加viewtext
    UITextView* textView = [[UITextView alloc]initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width-40, 240)];
    textView.text=@"使用远程登录，可以通过申请co-cloud ID，远程访问co-cloud服务器，并且在设备报警时，收到报警消息。";
    textView.font = [UIFont fontWithName:@"Arial" size:16];
    [textView setEditable:NO];
    [self.view addSubview:textView];
    //添加注册按钮
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(70, 300, [UIScreen mainScreen].bounds.size.width-140, 50)];
    //添加注册按钮的下划线效果
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"注册co-cloud账户"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strRange];
    [btn setAttributedTitle:str forState:UIControlStateNormal];
    [self.view addSubview:btn];
    //添加导航条标题 并为标题设置颜色
    [self.navigationItem setTitle:@"co-cloud账户"];
    //为注册按钮添加事件
    [btn addTarget: self action: @selector(Register:) forControlEvents: UIControlEventTouchUpInside];
    //添加后退按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)Register:(UIButton *)sender {
    CloudRegisterViewController* reg = [[CloudRegisterViewController alloc]initWithNibName:@"CloudRegisterViewController" bundle:nil];
    reg.mac = self.mac;
    [self.navigationController pushViewController:reg animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
