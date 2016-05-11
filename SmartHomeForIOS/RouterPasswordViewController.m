//
//  RouterPasswordViewController.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/4.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "RouterPasswordViewController.h"

@interface RouterPasswordViewController ()

@end

@implementation RouterPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"修改密码";
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = itemLeft;
    
    
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
