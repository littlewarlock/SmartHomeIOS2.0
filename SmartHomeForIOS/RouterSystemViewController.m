//
//  RouterSystemViewController.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/7.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "RouterSystemViewController.h"

@interface RouterSystemViewController ()

@end

@implementation RouterSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"系统信息";
    
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
