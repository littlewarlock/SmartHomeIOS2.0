//
//  FileHandlerDelegate.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/11/4.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileHandlerDelegate <NSObject>
- (void)requestSuccessCallback;
- (void)sessionTimeOutCallback;
@end
