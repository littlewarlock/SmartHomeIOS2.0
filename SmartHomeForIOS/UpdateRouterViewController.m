//
//  UpdateRouterViewController.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/3.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "UpdateRouterViewController.h"

@interface UpdateRouterViewController ()

@end

@implementation UpdateRouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //透明模板
     self.view.backgroundColor = [UIColor clearColor];
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
}



//监听“以后再说”按钮点击
- (IBAction)backTolastVc:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

//监听“立即更新”按钮点击
- (IBAction)refreshNow:(id)sender {
}

@end
