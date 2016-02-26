//
//  UIViewController+UserLogout.m
//  SmartHomeForIOS
//
//  Created by apple2 on 16/2/24.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "UIViewController+UserLogout.h"
#import "DeviceNetworkInterface.h"
#import "DataManager.h"
#import <AVOSCloud/AVOSCloud.h>
#import "LoginViewController.h"

@implementation UIViewController (UserLogout)

- (void)checkServerSessionOutOfTime{
    //    if ([DeviceNetworkInterface isServerSessionOutOfTime]) {
    //        for (UIViewController *vc in self.navigationController.viewControllers) {
    //            if ([vc isKindOfClass:[HomeViewController class]]) {
    //                NSLog(@"have one");
    //                HomeViewController *homeVC = vc;
    //                //
    //                self.navigationController.navigationBarHidden = NO;
    //                [self.navigationController setToolbarHidden:YES];
    //                [self.navigationController popToViewController:homeVC animated:YES];
    //                [self.navigationController popToRootViewControllerAnimated:YES];
    //                //
    //                break;
    //            }
    //            NSLog(@"vc1=%@",[vc class]);
    //            NSLog(@"vc2=%@",self.navigationController.visibleViewController);
    //        }
    //    }
    
    
    if ([DeviceNetworkInterface isServerSessionOutOfTime]) {
        //2016 02 25
//        if (self.navigationController) {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
        //
        [g_sDataManager setUserName:@""];
        [g_sDataManager setPassword:@""];
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation removeObject:[g_sDataManager cId] forKey:@"channels"];
        [currentInstallation saveInBackground];
        LoginViewController *loginView= [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginView.isPushHomeView =YES;
        loginView.isShowLocalFileBtn =YES;
        [self presentViewController:loginView animated:YES completion:nil];
        //        [self.viewDeckController presentViewController:loginView animated:YES completion:nil];
    }
}

- (void)SMTnetWorkError{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"网络错误" message:@"请您检查网络设置" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
    [alert show];
}

- (void)serverSessionRefresh{
    //2016 02 26 注释
//    [DeviceNetworkInterface serverSessionRefresh];
    NSLog(@"serverSessionRefresh fresh");
}

@end
