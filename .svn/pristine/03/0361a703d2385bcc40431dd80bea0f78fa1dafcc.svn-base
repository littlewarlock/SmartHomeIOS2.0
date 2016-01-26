//
//  NSOperationDownloadQueue.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/12/11.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "NSOperationDownloadQueue.h"
#import "FileDownloadOperation.h"
#define FreezableOperationExtension @"downloadfrozenoperation"
#define NETWORKCACHE_DEFAULT_DIRECTORY @"NetworkKitCache"
@implementation NSOperationDownloadQueue

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static NSOperationDownloadQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSOperationDownloadQueue alloc] init];
        [instance setMaxConcurrentOperationCount:1];

    });
    return instance;
}
-(BOOL) isCacheEnabled {
    BOOL isDir = NO;
    NSString *cacheDirectory = [self cacheDirectoryName];
    BOOL isDirectory = YES;
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] && isDirectory;
    
    if (!folderExists)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    BOOL isCachingEnabled = [[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectoryName] isDirectory:&isDir];
    return isCachingEnabled;
}

-(NSString*) cacheDirectoryName {
    
    static NSString *cacheDirectoryName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:NETWORKCACHE_DEFAULT_DIRECTORY];
    });
    
    return cacheDirectoryName;
}
#pragma mark -
#pragma mark freezeOperations 冻结下载操作的处理事件
-(void) freezeOperations {
    if(![self isCacheEnabled]) return;
    for(FileDownloadOperation *operation in self.operations) {
        NSString *archivePath = [[[self cacheDirectoryName] stringByAppendingPathComponent:operation.taskInfo.taskId]
                                 stringByAppendingPathExtension:FreezableOperationExtension];
        
        [NSKeyedArchiver archiveRootObject:operation.taskInfo toFile:archivePath];
        [operation cancel];
    }
}

-(void) checkAndRestoreFrozenOperations {
    
    if(![self isCacheEnabled]) return;
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheDirectoryName] error:&error];
    if(error)
        DLog(@"%@", error);
    
    NSArray *pendingOperations = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *thisFile = (NSString*) evaluatedObject;
        return ([thisFile rangeOfString:FreezableOperationExtension].location != NSNotFound);
    }]];
    
    for(NSString *pendingOperationFile in pendingOperations) {
        NSString *archivePath = [[self cacheDirectoryName] stringByAppendingPathComponent:pendingOperationFile];
        TaskInfo *pendingTask = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        if(![pendingTask.taskStatus isEqualToString:CANCLED]){
            FileDownloadOperation *pendingOperation = [[FileDownloadOperation alloc]initWithTaskInfo:pendingTask];
            [[ProgressBarViewController sharedInstance]  setProgressViewTaskInfo:pendingTask];//设置progressView 的TaskInfo
            pendingOperation.taskId = pendingTask.taskId;
            pendingOperation.completionBlock = ^(void){ //如果是任务执行完成则设置暂停按钮不可用
                if ([pendingTask.taskStatus isEqualToString:FINISHED]) {
                    NSLog(@"completionBlock======ooooo");
                    //更新进度按钮的状态
                    NSMutableDictionary * btnStateDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:pendingTask.taskId,@"taskId",@"disable" ,@"btnState", nil];
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnState:) withObject:btnStateDic waitUntilDone:NO];
                    //更新进度条的状态信息
                    NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:pendingTask.taskId,@"taskId",@"已完成" ,@"taskStatus", nil];
                    //在主线程刷新UI
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setTaskStatusInfo:) withObject:taskStatusDic waitUntilDone:NO];
                }
            };
            [self addOperation:pendingOperation]; //已取消的任务，不应该加入到队列中
        }
        NSError *error2 = nil;
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error2];
        if(error2)
            DLog(@"%@", error2);
    }
}

@end