//
//  UIHelper.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/25.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "UIHelper.h"
#import "LoginViewController.h"
#import "AsyncUdpSocket.h"
#define WIDTH_LOADINGVIEW_BLACKVIEW   200
#define HEIGHT_LOADINGVIEW_BLACKVIEW  120
#define EDGE_BLACKVIEW_BOTTOM 100


@implementation UIHelper

+(CGSize) getScreenSize
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    return size;
    
    
}

+ (UIView*) addLoadingViewWithSuperView:(UIView*)view text:(NSString*)text
{
    return [UIHelper addLoadingViewWithSuperView:view text:text isAddToScreen:YES ];
}

+ (UIView*) addLoadingViewWithSuperView:(UIView*)view text:(NSString*)text isAddToScreen:(BOOL)isAddToScreen
{
    // 1. 定制loadingView
    CGRect bounds;
    if (isAddToScreen)
    {
        bounds= [UIScreen mainScreen].bounds;
    }
    else
    {
        bounds = view.bounds;
    }
    UIView* loadingView = [[UIView alloc] initWithFrame:bounds];
    loadingView.backgroundColor = [UIColor clearColor];
    
    

    // 2. 定制矩形框
    UIView* rectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_LOADINGVIEW_BLACKVIEW,HEIGHT_LOADINGVIEW_BLACKVIEW)];
    rectView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5f];
    rectView.layer.cornerRadius = 5.0f;
    if (isAddToScreen)
    {
        rectView.center = CGPointMake(bounds.size.width/2,bounds.size.height/2-EDGE_BLACKVIEW_BOTTOM);
    }
    else
    {
        rectView.center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    }
    [loadingView addSubview:rectView];
    
    // 3. 定制风火轮
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(rectView.frame.size.width/2, rectView.frame.size.height/2-15);
    [activityView startAnimating];
    [rectView addSubview:activityView];
    // 4. text
    if (text)
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,HEIGHT_LOADINGVIEW_BLACKVIEW - 20-10,WIDTH_LOADINGVIEW_BLACKVIEW,20)];
        label.text = text;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentCenter;
        [rectView addSubview:label];
    }
    
    // 显示
    [view addSubview:loadingView];
    
    return loadingView;
}



+ (void) showLoginView:(UIViewController*)viewController{
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginView.isShowLocalFileBtn =NO;
    loginView.isPushHomeView = NO;
    [viewController.navigationController pushViewController:loginView animated:NO];
}
+ (void) showLoginViewWithDelegate:(UIViewController*)viewController loginViewDelegate:(nullable id )loginViewDelegate{
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginView.isShowLocalFileBtn =NO;
    loginView.isPushHomeView = NO;
    loginView.loginViewDelegate = loginViewDelegate;
    [viewController.navigationController pushViewController:loginView animated:NO];
}

+ (void) showLoginViewWithServerSessionTimeOut:(UIViewController*)viewController{
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginView.isShowLocalFileBtn =NO;
    loginView.isPushHomeView = YES;
    [viewController.navigationController pushViewController:loginView animated:NO];
}

@end
