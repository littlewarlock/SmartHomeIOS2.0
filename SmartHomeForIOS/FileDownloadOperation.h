//
//  FileDownloadOperation.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/12/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "ProgressBarViewController.h"
#import "TaskInfo.h"
#import "TaskStatusConstant.h"
@interface FileDownloadOperation : NSOperation


@property (nonatomic, strong) NSString * taskId;
@property (nonatomic, strong) TaskInfo * taskInfo;
- (id)initWithTaskInfo:(TaskInfo*) taskInfo;
@end
