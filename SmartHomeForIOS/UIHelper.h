//
//  UIHelper.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/25.
//  Copyright (c) 2015年 riqiao. All rights reserved.
///Users/riqiao/Documents/svn/20151028/SmartHomeForIOS /SmartHomeForIOS/UIHelper.h:15:10: Pointer is missing a nullability type specifier (_Nonnull, _Nullable, or _Null_unspecified)

#import <Foundation/Foundation.h>
#import "LoginViewDelegate.h"
#import "AsyncUdpSocket.h"



@interface UIHelper : NSObject
+(CGSize) getScreenSize;
// 显示loadingView,
+ (UIView* __nonnull) addLoadingViewWithSuperView:(UIView* __nonnull)view text:(NSString* __nonnull)text ;

+ (void) showLoginView:(UIViewController* __nonnull)viewController;
+ (void) showLoginViewWithDelegate:(UIViewController* __nonnull)viewController loginViewDelegate:(nullable id )delegate;
+ (void) showLoginViewWithServerSessionTimeOut:(UIViewController* __nonnull)viewController;
@end
