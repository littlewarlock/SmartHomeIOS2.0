//
//  FileDowanLoadTools.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/12.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FileDownloadTools.h"

@implementation FileDownloadTools


- (id)initWithFileInfo {
    if (self=[super init]) {
        self.filePath = 0;
        self.fileName = 0;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)main {
    @try {
        //下载文件
        NSString* requestUrl=[NSString stringWithFormat: @"http://%@/",[g_sDataManager requestHost]];
        
        NSString* fileSizeString =[requestUrl stringByAppendingString: REQUEST_FILESIZE_URL];
        NSURL *fileSizeUrl = [NSURL URLWithString:[fileSizeString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:fileSizeUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
        NSError * fileSizeError=nil;
        NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&filePath=%@&fileName=%@",[g_sDataManager userName],[g_sDataManager password],self.filePath,self.fileName];
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
                    NSMutableData *fileData =[[NSMutableData alloc] init];
                    fileLength = [[dictionary objectForKey:@"size"] intValue];
                    if(fileLength<DOWNLOAD_STREAM_SIZE)
                    {
                        streamNum =1;
                    }
                    else if (fileLength % DOWNLOAD_STREAM_SIZE > 0)
                    {
                        streamNum = fileLength / DOWNLOAD_STREAM_SIZE + 1;
                        NSLog(@"DOWNLOAD_STREAM_SIZE===%lli",(fileLength / DOWNLOAD_STREAM_SIZE));
                    }
                    else
                    {
                        streamNum = fileLength / DOWNLOAD_STREAM_SIZE;
                    }
                    if((!self.cachePath) || [self.cachePath isEqualToString:@""])
                    {
                        self.cachePath = [kDocument_Folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", [g_sDataManager userName], self.fileName]];
                    }else{
                        self.cachePath = [self.cachePath stringByAppendingPathComponent:self.fileName];
                    }
                    NSString* requestUrl=[NSString stringWithFormat: @"http://%@/",[g_sDataManager requestHost]];
                    NSString* downloadUrl =[requestUrl stringByAppendingString: REQUEST_DOWNBLOCK_URL];
                    NSURL *url = [NSURL URLWithString:[downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    //发送同步请求，请求成功后返回数据
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                    NSFileHandle *file;
                    NSError*  downloadError;
                    NSNumber* currentProgress;
                    while (streamChunk!=streamNum){
                        @autoreleasepool {
                            [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
                            NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&filePath=%@&fileName=%@&blockIndex=%lli&blockSize=%lli",[g_sDataManager userName],[g_sDataManager password],self.filePath,self.fileName,streamChunk,(long long int)DOWNLOAD_STREAM_SIZE];
                              NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
                            [request setHTTPBody:postData];
                            //第三步，连接服务器
                            fileData = [[NSMutableData alloc] init];
                            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&downloadError];
                            if (!downloadError) {
                                NSLog(@"streamNum = %lli", streamChunk);
                                [fileData appendData:received];
                                if ([[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) {
                                    file  = [NSFileHandle fileHandleForWritingAtPath:_cachePath];
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
                                else {
                                    [fileData writeToFile:_cachePath options:NSAtomicWrite error:nil];
                                }
                                
                                if (fileData) {
                                    fileData = nil;
                                }

                                if (postData != nil) {
                                    postData = nil;
                                }
                                if (post!=nil) {
                                    post = nil;
                                }
                                int progress = (int)(float)(streamChunk-self.lastUpdSize+1)/(float)streamNum*100;
                                if(progress>=1 || streamChunk==streamNum-1 )
                                {
                                    if (streamNum==1) {
                                        currentProgress= [NSNumber numberWithFloat: 1];
                                    }else{
                                        currentProgress=[NSNumber numberWithFloat: (float)(streamChunk+1)/(float)streamNum];
                                    }
                                    NSMutableDictionary * progressDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskId,@"taskId",currentProgress ,@"progress", nil];
                                    //在主线程刷新UI
                                   [self.progressBarView performSelectorOnMainThread:@selector(updateProgress:) withObject:progressDic waitUntilDone:NO];
                                    self.lastUpdSize = streamChunk;
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
                           // sleep(0.5);
                            streamChunk++;
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}
@end
