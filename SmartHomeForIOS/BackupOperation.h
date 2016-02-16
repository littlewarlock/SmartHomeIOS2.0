//
//  BackupOperation.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/29.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskInfo.h"
#import "ProgressBarViewController.h"
@interface BackupOperation : NSOperation<NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property (nonatomic, strong) TaskInfo * taskInfo;
@property (nonatomic,strong)NSURLSession * session;
@property(nonatomic,strong)NSString * localCurrentDir;//本地当前路
@property(nonatomic,strong)NSString * targetDir;//存储备份到目标文件夹下
- (id)initWithTaskInfo:(TaskInfo*) taskInfo;
@end
