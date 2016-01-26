//
//  thunderTools.h
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/1/13.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "RequestConstant.h"

@interface thunderTools : NSObject

/** 启动盒子中的迅雷*/
+ (void)openThunder;
/** 关闭盒子中的迅雷*/
+ (void)closeThunder;
/** 检测盒子中的迅雷是否打开*/
+ (void)thunderOn:(BOOL)isON;

@end
