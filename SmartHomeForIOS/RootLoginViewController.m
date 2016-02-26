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
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation RootLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //添加后退按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
}
- (IBAction)resign:(id)sender {
    
    CloudRegisterViewController* reg = [[CloudRegisterViewController alloc]initWithNibName:@"CloudRegisterViewController" bundle:nil];
    reg.mac = self.mac;
    [self.navigationController pushViewController:reg animated:YES];
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
