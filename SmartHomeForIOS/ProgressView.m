//
//  ProgressView.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "ProgressView.h"
#import "TaskStatusConstant.h"


@interface ProgressView ()

@end

@implementation ProgressView

- (id)initWithTask:(TaskInfo *)taskInfo
{
    self = [[ProgressView alloc] init];
    self.taskInfo = taskInfo;
    self.progressBar.progress = 0.0f;
    self.progressBar.layer.masksToBounds = YES;
    self.progressBar.layer.cornerRadius = 4;
    //设置进度条的高度
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 7.0f);
    self.progressBar.transform = transform;
    //self.taskNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.taskNameLabel.text = taskInfo.taskName;
    return self;
}

#pragma mark setTaskStateAction 设置任务的状态 暂停 继续
- (IBAction)setTaskStateAction:(UIButton *)sender {
    
    
    if ([self.taskInfo.taskType isEqualToString:@"下载"]) {//“下载”任务
        
        if (self.taskInfo && ![self.taskInfo.taskId isEqualToString:@""]) {
            NSOperationDownloadQueue *downloadQueue = [NSOperationDownloadQueue sharedInstance];
            if (downloadQueue) {
                FileDownloadOperation *downloadOperation;
                for(FileDownloadOperation *operation in downloadQueue.operations)
                {
                    if([operation.taskId isEqualToString:self.taskInfo.taskId] && !operation.cancelled){
                        downloadOperation = operation;
                        break;
                    }
                }
                if (downloadOperation && ![self.taskInfo.taskStatus isEqualToString:CANCLED]) {
                    [downloadOperation cancel]; //（暂停）取消当前操作
                    NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"已暂停" ,@"taskStatus",@"enable",@"btnState",@"继续",@"caption", nil];
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnStateCaptionAndTaskStatus:) withObject:taskStatusDic waitUntilDone:NO];
                    self.taskInfo.taskStatus = CANCLED;
                }else if([self.taskInfo.taskStatus isEqualToString:CANCLED] || ([self.taskInfo.taskStatus isEqualToString:FAILURE])){
                    NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"已暂停" ,@"taskStatus",@"enable",@"btnState",@"暂停",@"caption", nil];
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnStateCaptionAndTaskStatus:) withObject:taskStatusDic waitUntilDone:NO];
                    self.taskInfo.taskStatus = RUNNING;
                    FileDownloadOperation *downloadOperation = [[FileDownloadOperation alloc] initWithTaskInfo:self.taskInfo];
                    downloadOperation.taskId = self.taskInfo.taskId;
                    downloadOperation.completionBlock = ^(void){ //如果是任务执行完成则设置暂停按钮不可用
                        if ([self.taskInfo.taskStatus isEqualToString:FINISHED]) {
                            NSLog(@"completionBlock======ppppp");
                            NSMutableDictionary * btnStateDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"disable" ,@"btnState", nil];
                            [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnState:) withObject:btnStateDic waitUntilDone:NO];
                            //更新进度条的状态信息
                            NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",FINISHED ,@"taskStatus", nil];
                            //在主线程刷新UI
                            [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setTaskStatusInfo:) withObject:taskStatusDic waitUntilDone:NO];
                        }
                    };
                    //继续下载
                    [downloadQueue addOperation:downloadOperation];
                    if(downloadOperation.isExecuting){
                        //       self.taskDetailLabel.text = @"正在下载";
                    }else{
                        //      self.taskDetailLabel.text = @"排队等待";
                    }
                }
            }
        }

    }else {//“上传”任务
        if (self.taskInfo && ![self.taskInfo.taskId isEqualToString:@""]) {
            NSOperationUploadQueue *uploadQueue = [NSOperationUploadQueue sharedInstance];
            if (uploadQueue) {
                FileUploadByBlockOperation *uploadOperation;
                for(FileUploadByBlockOperation *operation in uploadQueue.operations)
                {
                    if([operation.taskId isEqualToString:self.taskInfo.taskId] && !operation.cancelled){
                        uploadOperation = operation;
                        break;
                    }
                }
                if (uploadOperation && ![self.taskInfo.taskStatus isEqualToString:CANCLED]) {
                    [uploadOperation cancel]; //（暂停）取消当前操作
                    NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"已暂停" ,@"taskStatus",@"enable",@"btnState",@"继续",@"caption", nil];
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnStateCaptionAndTaskStatus:) withObject:taskStatusDic waitUntilDone:NO];
                    self.taskInfo.taskStatus = CANCLED;
                }else if([self.taskInfo.taskStatus isEqualToString:CANCLED] || ([self.taskInfo.taskStatus isEqualToString:FAILURE])){
                    NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"已暂停" ,@"taskStatus",@"enable",@"btnState",@"暂停",@"caption", nil];
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnStateCaptionAndTaskStatus:) withObject:taskStatusDic waitUntilDone:NO];
                    self.taskInfo.taskStatus = RUNNING;
                    FileUploadByBlockOperation *uploadOperation = [[FileUploadByBlockOperation alloc] initWithTaskInfo:self.taskInfo];
                    uploadOperation.taskId = self.taskInfo.taskId;
                    uploadOperation.completionBlock = ^(void){ //如果是任务执行完成则设置暂停按钮不可用
                        if ([self.taskInfo.taskStatus isEqualToString:FINISHED]) {
                            NSLog(@"completionBlock======ppppp  ");
                            NSMutableDictionary * btnStateDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"disable" ,@"btnState", nil];
                            [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnState:) withObject:btnStateDic waitUntilDone:NO];
                            //更新进度条的状态信息
                            NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",FINISHED ,@"taskStatus", nil];
                            //在主线程刷新UI
                            [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setTaskStatusInfo:) withObject:taskStatusDic waitUntilDone:NO];
                        }
                    };
                    [uploadQueue addOperation:uploadOperation];
                    if(uploadOperation.isExecuting){
                        //       self.taskDetailLabel.text = @"正在下载";
                    }else{
                        //      self.taskDetailLabel.text = @"排队等待";
                    }
                }
            }
        }
   
    }
  
}

- (void)setPauseBtnState:(BOOL )btnState{
    self.pauseBtn.enabled = btnState;
}

//如果任务结束，则隐藏按钮
- (void)setTaskStatusInfo:(NSString *)taskStatus{
   // self.taskDetailLabel.text = taskStatus;
    if([taskStatus isEqualToString:FINISHED]){
        self.pauseBtn.hidden = YES;
    }
}


- (void)setPauseBtnStateCaptionAndTaskStatus:(BOOL) btnState caption:(NSString*)caption taskStatus:(NSString*)taskStatus{
    self.pauseBtn.enabled = btnState;
    [self.pauseBtn setTitle:caption forState:UIControlStateNormal];
    if([caption isEqualToString:@"继续"]){
        [self.pauseBtn setImage:[UIImage imageNamed:@"down_play"] forState:UIControlStateNormal];
        self.progressBar.progressTintColor=[UIColor colorWithRed:255.0/255 green:184.0/255 blue:28.0/255 alpha:1.0f];
    }
    else if([caption isEqualToString:@"暂停"]){
        [self.pauseBtn setImage:[UIImage imageNamed:@"down_pause_icon"] forState:UIControlStateNormal];
         self.progressBar.progressTintColor =[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1.0f];
    }
   // self.taskDetailLabel.text = taskStatus;
}

- (void)setTaskTypeImageViewByTaskType:(NSString *)taskType{
    if([taskType isEqualToString:@"上传"]){
        [self.taskTypeImageView setImage:[UIImage imageNamed:@"upload_icon"]];
    }else if([taskType isEqualToString:@"下载"]){
        [self.taskTypeImageView setImage:[UIImage imageNamed:@"down_icon"]];
    }
}
@end
