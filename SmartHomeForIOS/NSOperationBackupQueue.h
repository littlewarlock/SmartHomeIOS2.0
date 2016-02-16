//
//  NSOperationBackupQueue.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/27.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskStatusConstant.h"
#import "ProgressBarViewController.h"
@interface NSOperationBackupQueue : NSOperationQueue
+ (instancetype)sharedInstance;
@end
