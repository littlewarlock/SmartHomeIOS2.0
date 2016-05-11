//
//  DirsHandler.m
//  SmartHomeForIOS
//
//  Created by riqiao on 16/3/1.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "DirsHandler.h"

@implementation DirsHandler

- (id)init:(NSMutableArray*)dirsArray filesArray:(NSMutableArray*)filesArray cloundCurrentDir:(NSString*)cloundCurrentDir targetDir:(NSString*)targetDir{
    self = [super init];
    if (self == nil)
        return nil;
    self.dirsArray = dirsArray;
    self.allDirsArray =[NSMutableArray arrayWithArray:dirsArray] ;
    if (filesArray!=nil) {
        self.allFilesArray = [NSMutableArray arrayWithArray:filesArray];
    }else{
        self.allFilesArray = [[NSMutableArray alloc] init];
    }
    
    self.cloundCurrentDir = cloundCurrentDir;
    self.targetDir = targetDir;
    return self;
}

- (void)traversalDirs: (NSMutableArray*)dirsArray currentPath:(NSMutableString *)currentPath{
    NSMutableArray *tempDirsArray = [NSMutableArray array ];
    for (int i=0;i<dirsArray.count;i++) {
        NSMutableString *basePath;
        if ([currentPath isEqualToString:@"/"]) {
            basePath = [NSMutableString stringWithFormat:@"/%@",dirsArray[i]];
        }else{
            basePath = [NSMutableString stringWithFormat:@"%@/%@",currentPath,dirsArray[i]];
        }
        NSString *requestUrl=[NSString stringWithFormat: @"http://%@/",[g_sDataManager requestHost]];
        
        NSString *fetchFileString =[requestUrl stringByAppendingString: REQUEST_FETCH_URL];
        NSURL *fetchFileUrl = [NSURL URLWithString:[fetchFileString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:fetchFileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"POST"];//设置请求方式为
        NSError *fetchFileError = nil;
        NSString *post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&cpath=%@",[g_sDataManager userName],[g_sDataManager password],basePath];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
        [request setHTTPBody:postData];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&fetchFileError];
        
        if (!fetchFileError) {
            NSError * jsonError=nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:&jsonError];
            if ([jsonObject isKindOfClass:[NSDictionary class]]){
                NSString *result =[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"value"]];
                if([result isEqualToString: @"1"]){
                    NSArray *responseJSONResult=jsonObject[@"result"];
                    if([responseJSONResult isEqual:@"file not exit"]){
                        return;
                    }
                    //提取文件夹和文件
                    for (int j=0; j<responseJSONResult.count; j++) {
                        NSDictionary *dict = responseJSONResult[j];
                        FileInfo *fileInfo = [[FileInfo alloc] init];
                        fileInfo.fileName = dict[@"fileName"];
                        fileInfo.fileSize = dict[@"fileSize"];
                        fileInfo.fileChangeTime = dict[@"fileChangeTime"];
                        fileInfo.fileType = dict[@"fileType"];
                        if([fileInfo.fileType isEqualToString:@"folder"])
                        {
                            fileInfo.fileSubtype =@"folder";
                            NSString *isShare = [NSString stringWithFormat:@"%@",dict[@"isShare"]];
                            fileInfo.isShare = isShare;
                            NSString *dirPath = [NSString stringWithFormat:@"%@/%@",basePath,fileInfo.fileName];
                            [tempDirsArray addObject:fileInfo.fileName];
                            [self.allDirsArray addObject:dirPath];
                        }else if([fileInfo.fileType isEqualToString:@"file"]){
                            fileInfo.fileUrl = [NSString stringWithFormat:@"%@/%@",basePath,fileInfo.fileName];
                            [self.allFilesArray addObject:fileInfo];
                        }
                        
                    }
                    [self traversalDirs:tempDirsArray currentPath:basePath]; //递归遍历所有的子目录
                }
            }
        }
    }//end for
}

- (void) dirsHandle{
    //1.获取所有文件夹和所有文件
    [self traversalDirs: self.dirsArray currentPath:self.cloundCurrentDir];
    //2.创建所有目录
    for(int i=0;i<self.allDirsArray.count;i++){
        NSString *path = [NSString stringWithFormat:@"%@/%@",self.targetDir,self.allDirsArray[i]];
        [FileTools createDirectoryAtPath:path];
    }
    TaskInfo *taskInfo = [[TaskInfo alloc]init];
    taskInfo.taskId = [NSUUIDTool gen_uuid];
    taskInfo.taskType =@"下载文件夹";
    
    taskInfo.ip = [g_sDataManager requestHost] ;
    NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"%@",[g_sDataManager userName]];
    taskInfo.serverPath = uploadUrl;
    taskInfo.userName = [g_sDataManager userName];
    taskInfo.port = REQUEST_PORT;
    taskInfo.password = [g_sDataManager password];
    taskInfo.totalBytes = 0;
    taskInfo.fileIndex = 0;
    //3.获取所有文件的大小
    taskInfo.filesArray = [NSMutableArray array];
    for(int i=0;i<self.allFilesArray.count;i++){
        FileInfo *fileInfo = (FileInfo*)self.allFilesArray[i];
       taskInfo.totalBytes += [fileInfo.fileSize intValue];
        [taskInfo.filesArray addObject:fileInfo.fileUrl];
    }
    
    ProgressView *progressView =[[ProgressBarViewController sharedInstance].downloadProgressBarDic objectForKey:taskInfo.taskId];
    progressView.taskInfo.totalBytes = taskInfo.totalBytes;
    
    if(taskInfo.totalBytes==1){ //如果下载的只是所有目录，没有任何文件，总字节数是0，设置为1字节
        taskInfo.totalBytes=1;
        progressView.taskInfo.transferedBytes=1;
        progressView.percentLabel.text = @"100%";
        [progressView.progressBar setProgress:1 animated:NO];
    }
    
    DirsDownloadOperation *dirsDownloadOperation = [[DirsDownloadOperation alloc]initWithTaskInfo:taskInfo dirs:self.allDirsArray filesArray:self.allFilesArray cloundCurrentDir:self.cloundCurrentDir targetDir:self.targetDir];
    [[ProgressBarViewController sharedInstance].downloadTaskDic  setObject:taskInfo forKey:taskInfo.taskId];
    [[ProgressBarViewController sharedInstance] addProgressBarRow:taskInfo];
    [ProgressBarViewController sharedInstance].showTabIndex = 1;
    [[ProgressBarViewController sharedInstance] setTabBarStyle];
    [[NSOperationDirsDownloadQueue sharedInstance] addOperation:dirsDownloadOperation];
}

@end
