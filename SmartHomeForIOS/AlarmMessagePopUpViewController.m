//
//  AlarmMessagePopUpViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/11/20.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "AlarmMessagePopUpViewController.h"

@interface AlarmMessagePopUpViewController ()

@end

@implementation AlarmMessagePopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewTopSide.layer.borderWidth = 0.5;
    self.viewTopSide.layer.borderColor = [[UIColor colorWithRed:241.0/255 green:241.0/255 blue:241.0/255 alpha:1.0]CGColor];
    self.viewBottomSide.layer.borderWidth = 0.5;
    self.viewBottomSide.layer.borderColor = [[UIColor colorWithRed:241.0/255 green:241.0/255 blue:241.0/255 alpha:1.0]CGColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClosePressed:(id)sender {
    
    NSLog(@"buttonClosePressed in AlarmMessagePopUpViewController.h");
//    [self.view removeFromSuperview];
}

@end
