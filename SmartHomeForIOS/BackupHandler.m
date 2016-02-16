//
//  BackupHandler.m
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/29.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "BackupHandler.h"
#import "FileTools.h"
#import "RequestConstant.h"
#import "DataManager.h"
#import "NSUUIDTool.h"
#import "TaskInfo.h"
#import "BackupOperation.h"
#import "NSOperationBackupQueue.h"

@implementation BackupHandler
- (id)init:(NSArray *)sourceFilesArray sourceDirsArray:(NSArray*)sourceDirsArray localCurrentDir:(NSString*)localCurrentDir targetDir:(NSString*)targetDir userName:(NSString*)userName password:(NSString*)password{
    self = [super init];
    if (self == nil)
        return nil;
    self.sourceFilesArray = sourceFilesArray;
    self.sourceDirsArray = sourceDirsArray;
    self.localCurrentDir = localCurrentDir;
    targetDir = [targetDir stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.targetDir = targetDir;
    self.userName = userName;
    self.password = password;
    return self;
}

-(void) backupHandle{
    @try {
        //1.获取所有的文件夹,及其子目录下的文件
        NSMutableArray *allDirsArray= [[NSMutableArray alloc]init];
        NSMutableArray *allFilesArray= [[NSMutableArray alloc]init];
        [allDirsArray addObjectsFromArray:self.sourceDirsArray];
        [allFilesArray addObjectsFromArray:self.sourceFilesArray];
        for (int i =0; i<self.sourceDirsArray.count; i++) {
            NSArray *dirsArray = [FileTools getAllDirs:self.sourceDirsArray[i]];
            NSMutableArray *dirsCompleteArray = [[NSMutableArray alloc]init];//存储所有的完整路径
            for (int j=0; j<dirsArray.count; j++) { //将子目录（目录名）拼接上父目录的绝对路径
                if(dirsArray[j] && ![dirsArray[j] isEqualToString:@""]){
                    dirsCompleteArray[j] = [self.sourceDirsArray[i] stringByAppendingPathComponent:dirsArray[j]];
                }
            }
            [allDirsArray addObjectsFromArray:dirsCompleteArray];
            NSArray *filesArray = [FileTools getAllFilesUrl:self.sourceDirsArray[i]];
            [allFilesArray addObjectsFromArray:filesArray];
        }
        //2.创建目录
        
        NSString* requestUrl=[NSString stringWithFormat: @"http://%@/",[g_sDataManager requestHost]];
        NSString* newFolderString =[requestUrl stringByAppendingString: REQUEST_NEWFOLDER_URL];
        NSURL *newFolderUrl = [NSURL URLWithString:[newFolderString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:newFolderUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
        NSError * newFolderError=nil;
        for(int i=0;i<allDirsArray.count;i++){
            NSString *folderName = [allDirsArray[i] lastPathComponent];
            NSString *dirPath =  allDirsArray[i];
            NSRange localCurrentDirRange = [dirPath rangeOfString:self.localCurrentDir];//匹配得到的下标
            NSString *cpath;
            if (localCurrentDirRange.location != NSNotFound) {
                NSRange range = {localCurrentDirRange.length,[allDirsArray[i] length]-localCurrentDirRange.length};
                NSString *sourceDir = [dirPath substringWithRange:range];//截取范围
                if ([sourceDir isEqualToString:[sourceDir lastPathComponent]]) {
                    cpath = self.targetDir;
                }else{
                    cpath = [self.targetDir stringByAppendingPathComponent:[sourceDir stringByDeletingLastPathComponent]];
                }
            }
            NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&cpath=%@&newName=%@",[g_sDataManager userName],[g_sDataManager password],cpath,folderName];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
            [request setHTTPBody:postData];
            NSLog(@"cpath=====%@",cpath);
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&newFolderError];
            if (!newFolderError) {
                NSError * jsonError=nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:&jsonError];
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSString* result =[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"result"]];
                    if([result isEqualToString: @"1"]){
                    }else{
                        
                    }
                }
            }
        }
        //3.获取备份文件的总长度
        long long totalBytes = 0;
        for (int i =0; i<allFilesArray.count; i++) {
            totalBytes += [FileTools getFileSize:allFilesArray[i]];
        }

        //4.上传文件
        TaskInfo *taskInfo = [[TaskInfo alloc]init];
        taskInfo.taskId = [NSUUIDTool gen_uuid];
        taskInfo.taskType =@"备份";
        if ([allFilesArray count]>0) {
            taskInfo.taskName =[allFilesArray[0] lastPathComponent];
        }
        if(totalBytes==0){ //如果备份的只是所有目录，没有任何文件，总字节数是0，设置为1字节
            totalBytes=1;
            taskInfo.transferedBytes = 1;
            taskInfo.totalBytes = 1;
        }
        taskInfo.totalBytes = totalBytes;
        taskInfo.ip = [g_sDataManager requestHost] ;
        NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"%@",[g_sDataManager userName]];
        if (![self.targetDir isEqualToString:@"/"]) {
            uploadUrl = [uploadUrl stringByAppendingPathComponent:self.targetDir];
        }
        taskInfo.serverPath = uploadUrl;
        taskInfo.userName = [g_sDataManager userName];
        taskInfo.port = REQUEST_PORT;
        taskInfo.password = [g_sDataManager password];
        taskInfo.filesArray = allFilesArray;
        taskInfo.fileIndex = 0;
        BackupOperation *backupOperation = [[BackupOperation alloc]initWithTaskInfo:taskInfo];
        backupOperation.localCurrentDir = self.localCurrentDir;
        backupOperation.targetDir = self.targetDir;

        [[ProgressBarViewController sharedInstance].uploadTaskDic  setObject:taskInfo forKey:taskInfo.taskId];
        [[ProgressBarViewController sharedInstance] addProgressBarRow:taskInfo];
        [[NSOperationBackupQueue sharedInstance] addOperation:backupOperation];
    }@catch (NSException *exception) {
        
    }
}
@end
