//
//  ProgressView.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskInfo.h"
#import "NSOperationDownloadQueue.h"
#import "FileDownloadOperation.h"
#import "NSOperationUploadQueue.h"
#import "FileUploadByBlockOperation.h"

@interface ProgressView :UIView
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *taskTypeImageView;

@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
//@property (assign, nonatomic)long long  transferedBytes;//已经传输了多少字节
//@property (assign, nonatomic)long long  totalBytes;//总共多少字节
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIButton *pauseBtn;//暂停继续按钮
@property (strong, nonatomic) TaskInfo  *taskInfo;
- (id)initWithTask:(TaskInfo *)task;
- (IBAction)setTaskStateAction:(UIButton *)sender;

- (void)setPauseBtnState:(BOOL )btnState;
- (void)setTaskStatusInfo:(NSString *)taskStatus;
//设置按钮的状态、标题 以及任务的状态
- (void)setPauseBtnStateCaptionAndTaskStatus:(BOOL) btnState caption:(NSString*)caption taskStatus:(NSString*)taskStatus;



//设置进度条icon的图片
- (void)setTaskTypeImageViewByTaskType:(NSString *)taskType;
@end
