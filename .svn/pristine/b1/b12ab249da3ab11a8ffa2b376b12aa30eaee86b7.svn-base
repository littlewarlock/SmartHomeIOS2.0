//
//  FileDownloadOperation.m
//  SmartHomeForIOS
//  可断点下载的Operation
//  Created by riqiao on 15/12/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FileDownloadOperation.h"
#import "FileTools.h"

@implementation FileDownloadOperation


- (id)initWithTaskInfo:(TaskInfo*) taskInfo{
    if (self=[super init]) {
        self.taskInfo = taskInfo;
    }
    return self;
}

- (void)main {
    @try {
        NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"正在下载" ,@"taskStatus", nil];
        //在主线程刷新UI
        [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setTaskStatusInfo:) withObject:taskStatusDic waitUntilDone:NO];
        //下载文件
        NSString* requestUrl=[NSString stringWithFormat: @"http://%@/",[g_sDataManager requestHost]];
        
        NSString* fileSizeString =[requestUrl stringByAppendingString: REQUEST_FILESIZE_URL];
        NSURL *fileSizeUrl = [NSURL URLWithString:[fileSizeString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:fileSizeUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
        NSError * fileSizeError=nil;
        NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&filePath=%@&fileName=%@",[g_sDataManager userName],[g_sDataManager password],self.taskInfo.filePath,self.taskInfo.fileName];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
        [request setHTTPBody:postData];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&fileSizeError];
        if (!fileSizeError) {
            NSError * jsonError=nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:&jsonError];
            if ([jsonObject isKindOfClass:[NSDictionary class]]){
                NSDictionary *dictionary = (NSDictionary *)jsonObject;
                NSString* result =[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"result"]];
                if([result isEqualToString: @"1"]){
                    long long int fileLength = 0;
                    long long int streamNum = 0;
                    long long int streamChunk = 0;
                    if (self.taskInfo && self.taskInfo.transferedBlocks) {
                        streamChunk = self.taskInfo.transferedBlocks+1;
                    }
                    NSMutableData *fileData =[[NSMutableData alloc] init];
                    fileLength = [[dictionary objectForKey:@"size"] intValue];
                    
                    if (fileLength % DOWNLOAD_STREAM_SIZE != 0)
                    {
                        streamNum = fileLength / DOWNLOAD_STREAM_SIZE + 1;
                        NSLog(@"DOWNLOAD_STREAM_SIZE===%lli",(fileLength / DOWNLOAD_STREAM_SIZE));
                    }
                    else
                    {
                        streamNum = fileLength / DOWNLOAD_STREAM_SIZE;
                    }
                    /*
                    if([self.taskInfo.cachePath isEqualToString:@""] || (!self.taskInfo.cachePath)  )
                    {
                        self.taskInfo.cachePath = [kDocument_Folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", [g_sDataManager userName], self.taskInfo.fileName]];
                    }else if(streamChunk==0){ //如果是第一次下载，需要拼接完整路径
                        self.taskInfo.cachePath = [self.taskInfo.cachePath stringByAppendingPathComponent:self.taskInfo.fileName];
                    }*/
                    NSString* requestUrl=[NSString stringWithFormat: @"http://%@/",[g_sDataManager requestHost]];
                    NSString* downloadUrl =[requestUrl stringByAppendingString: REQUEST_DOWNBLOCK_URL];
                    NSURL *url = [NSURL URLWithString:[downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    //发送同步请求，请求成功后返回数据
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                    NSFileHandle *file;
                    NSError *downloadError;
                    NSNumber *currentProgress;
                    while (streamChunk!=streamNum && !self.isCancelled){//如果operation被取消后，则不执行循环
                        @autoreleasepool {
                            [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
                            NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&filePath=%@&fileName=%@&blockIndex=%lli&blockSize=%lli",[g_sDataManager userName],[g_sDataManager password],self.taskInfo.filePath,self.taskInfo.fileName,streamChunk,(long long int)DOWNLOAD_STREAM_SIZE];
                            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
                            [request setHTTPBody:postData];
                            fileData = [[NSMutableData alloc] init];
                            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&downloadError];
                            if (!downloadError) {
                                NSLog(@"streamNum = %lli", streamChunk);
                                NSFileManager *fm =[NSFileManager defaultManager];
                                [fileData appendData:received];
                                @synchronized(fm)
                                {//加锁
                                    if ([fm fileExistsAtPath:self.taskInfo.cachePath] && streamChunk!=0) {
                                        long long fileSize = [FileTools getFileSize:self.taskInfo.cachePath];
                                        int currentBlockNum = (int) (fileSize / DOWNLOAD_STREAM_SIZE);//当前文件已经下载的块数
                                        if (fileSize % DOWNLOAD_STREAM_SIZE != 0)
                                            currentBlockNum++;
                                        if (currentBlockNum>=streamChunk+1) {//如果当前块已经存在，则舍弃
                                            streamChunk++;
                                            continue;
                                        }

                                        file = [NSFileHandle fileHandleForWritingAtPath:self.taskInfo.cachePath];
                                        if (file) {
                                            [file seekToEndOfFile];
                                            [file writeData:fileData];
                                            [file closeFile];
                                            file = nil;
                                            received = nil;
                                        }
                                        else {
                                            //清除数据
                                            if (fileData != nil) {
                                                fileData = nil;
                                            }
                                            return;
                                        }
                                    }
                                    else if(streamChunk!=0 && ![fm fileExistsAtPath:self.taskInfo.cachePath]){//如果任务失败，则停止下载
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"下载文件出错！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
                                        [alert show];
                                        self.taskInfo.transferedBlocks =0;
                                        self.taskInfo.transferedBytes = 0;
                                        self.taskInfo.currentProgress = 0;
                                        self.taskInfo.taskStatus = FAILURE;
                                        NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"下载失败" ,@"taskStatus",@"enable",@"btnState",@"重新下载",@"caption", nil];
                                        [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnStateCaptionAndTaskStatus:) withObject:taskStatusDic waitUntilDone:NO];
                                        return;
                                    }
                                    else {
                                        [fileData writeToFile:self.taskInfo.cachePath options:NSAtomicWrite error:nil];
                                    }
                                }//释放锁
                                if (fileData) {
                                    fileData = nil;
                                }
                                
                                if (postData != nil) {
                                    postData = nil;
                                }
                                if (post!=nil) {
                                    post = nil;
                                }
                                int progress = (int)(float)(streamChunk-self.taskInfo.transferedBytes+1)/(float)streamNum*100;
                                if(progress>=1 || streamChunk==streamNum-1 )
                                {
                                    if (streamNum==1) {
                                        currentProgress= [NSNumber numberWithFloat: 1];
                                    }else{
                                        currentProgress=[NSNumber numberWithFloat: (float)(streamChunk+1)/(float)streamNum];
                                    }
                                    NSMutableDictionary * progressDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",currentProgress ,@"progress", nil];
                                    //在主线程刷新UI
                                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(updateProgress:) withObject:progressDic waitUntilDone:NO];
                                    self.taskInfo.transferedBlocks = streamChunk;
                                }
                            }
                            else
                            {
                                NSLog(@"error streamNum = %lli", streamChunk);
                                //清除数据
                                if (fileData != nil) {
                                    fileData = nil;
                                }
                                return;
                            }
                            self.taskInfo.transferedBlocks =
                            streamChunk++;
                        }
                    }
                    //如果手动取消任务，需要发送信息给主线程，防止取消前的最后一块尚未处理完毕，用户直接点击恢复按钮，导致出现问题
                    if (self.isCancelled && [self.taskInfo.taskStatus isEqualToString:CANCLED]) {
                        self.taskInfo.taskStatus = CANCLED;
                        NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"已暂停" ,@"taskStatus",@"enable",@"btnState",@"继续",@"caption", nil];
                        //在主线程刷新UI
                        [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnStateCaptionAndTaskStatus:) withObject:taskStatusDic waitUntilDone:NO];
                    }else if(streamChunk==streamNum){
                        self.taskInfo.taskStatus = FINISHED;
                    }
                }
            }
        }else{
            self.taskInfo.taskStatus = FAILURE;
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"下载文件出错！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
        [alert show];
        NSLog(@"==================");
    }
}
@end
