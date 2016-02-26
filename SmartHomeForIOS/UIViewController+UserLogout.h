//
//  UIViewController+UserLogout.h
//  SmartHomeForIOS
//
//  Created by apple2 on 16/2/24.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UserLogout)

- (void)checkServerSessionOutOfTime;
- (void)SMTnetWorkError;
- (void)serverSessionRefresh;

@end
