//
//  FunctionManageTools.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/10.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunctionManageTools :  NSObject
+ (int)saveSelectedApp;
+ (NSMutableArray *) readSavedApp;
@end
