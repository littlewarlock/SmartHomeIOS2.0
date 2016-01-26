//
//  LoginViewDelegate.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/23.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginViewDelegate <NSObject>
- (void)loginCallbackAction:(UIButton *)sender;
- (void)cancelSearch:(UIGestureRecognizer *)sender;
@end
