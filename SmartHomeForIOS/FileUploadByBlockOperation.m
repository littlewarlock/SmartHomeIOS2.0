//
//  FileUploadByBlockOperation.m
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/12.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "FileUploadByBlockOperation.h"
#import "NSUUIDTool.h"
#import "RequestConstant.h"
#import "FileTools.h"
static NSString* boundary = @"----WebKitFormBoundaryT1HoybnYeFOGFlBR";
@implementation FileUploadByBlockOperation

- (id)initWithTaskInfo:(TaskInfo*) taskInfo{
    if (self=[super init]) {
        self.taskInfo = taskInfo;
    }
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration  delegate:self delegateQueue:queue];
    return self;
}

- (id)initWithLocalPath:(NSString *)localStr ip:(NSString*)ip withServer:(NSString*)serverStr
               withName:(NSString*)theName withPass:(NSString*)thePass {
    self = [super init];
    if (self == nil)
        return nil;
    localStr = [localStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.taskInfo.localFileNamePath = localStr;
    self.taskInfo.ip = ip ;
    self.taskInfo.serverPath = serverStr;
    self.taskInfo.userName = theName;
    self.taskInfo.port = REQUEST_PORT;
    self.taskInfo.password = thePass;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration  delegate:self delegateQueue:queue];
    return self;
}

- (void)upload: (NSString*) ip port:(NSString*) port user:(NSString*) user password:(NSString*) password remotePath:(NSString*) remotePath fileNamePath:(NSString*)fileNamePath fileName:(NSString*)fileName
{
    NSString *urlStr =[NSString stringWithFormat:@"http://%@/%@",ip,REQUEST_UPLOADBLOCK_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:20];
    long long  fileSize =  [FileTools getFileSize:fileNamePath];
    NSLog(@"fileSize===========%lld",fileSize);
    int httpBlockNum = (int) (fileSize / DOWNLOAD_STREAM_SIZE);
    if (fileSize % DOWNLOAD_STREAM_SIZE != 0)
        httpBlockNum++;
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:fileNamePath];
    long long transferedBytes = 0;
    long long streamChunk =0;
    long long i = 0;
    if (self.taskInfo && self.taskInfo.transferedBlocks) {
        streamChunk = self.taskInfo.transferedBlocks+1;
    }else{
        streamChunk = 0;
    }
    if (self.taskInfo && self.taskInfo.transferedBytes) {
        transferedBytes =  self.taskInfo.transferedBytes;
    }
    for (i = streamChunk; i < httpBlockNum && !self.isCancelled; i++) {
        @autoreleasepool {
            // header of uploaded file
            NSMutableString *bodyString = [[NSMutableString alloc]init];
            [self setParameter:bodyString key:@
             "user" value:user];
            //NSString *path = [remotePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self setParameter:bodyString key:@
             "password" value:password];
            [self setParameter:bodyString key:@
             "path" value:remotePath];
            [self setParameter:bodyString key:@
             "filename" value:fileName];
            
            [self setParameter:bodyString key:@"blocksize"  value:[NSString stringWithFormat:@"%d",DOWNLOAD_STREAM_SIZE]];
            [self setParameter:bodyString key:@"blockindex"  value:[NSString stringWithFormat:@"%lld",i]];
            if (i == 0)
                [self setParameter:bodyString key:@"firstblockflag"  value:@"1"];
            else
                [self setParameter:bodyString key:@"firstblockflag"  value:@"0"];
            if (i == httpBlockNum - 1)
                [self setParameter:bodyString key:@"lastblockflag"  value:@"1"];
            else
                [self setParameter:bodyString key:@"lastblockflag"  value:@"0"];
            
            [bodyString appendFormat:@"--%@\r\n",boundary];
            [bodyString appendFormat:@"Content-Disposition:form-data; name=\"form\";"];
            [bodyString appendFormat:@"filename=\"%@\"\r\n",@"uploadfile"];
            [bodyString appendString:@"Content-Type: image/jpeg\r\n\r\n"];
            NSString *endString = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundary];
            NSData *uploadData;
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=%@", boundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
            [request setHTTPMethod:@"POST"];
            NSMutableData *bodyHeadData = [[NSMutableData alloc]init];
            NSData *bodyStringData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fileNamePath]) {
                [file seekToFileOffset:transferedBytes];
                uploadData = [file readDataOfLength:DOWNLOAD_STREAM_SIZE];
            }
            
            [bodyHeadData appendData:bodyStringData];
            NSData *endStringData = [endString dataUsingEncoding:NSUTF8StringEncoding];
            [bodyHeadData appendData:uploadData];
            [bodyHeadData appendData:endStringData];
            NSString *contentLength = [NSString stringWithFormat:@"%zi",[bodyHeadData length]];
            [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
            transferedBytes += [uploadData length];
            self.taskInfo.transferedBytes = transferedBytes;
            self.taskInfo.transferedBlocks = i;
            dispatch_semaphore_t semaphore =dispatch_semaphore_create(0);
            NSURLSessionUploadTask * dataTask = [self.session uploadTaskWithRequest:request fromData:bodyHeadData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                dispatch_semaphore_signal(semaphore);
                if (!self.isBackup) {
                    NSNumber* currentProgress = [NSNumber numberWithFloat: ((float)transferedBytes/(float)fileSize)];
                    NSMutableDictionary * progressDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskId,@"taskId",currentProgress ,@"progress", nil];
                    //在主线程刷新UI
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(updateProgress:) withObject:progressDic waitUntilDone:YES];
                }else{
                    NSNumber* sendBytes = [NSNumber numberWithLong: [uploadData length]];
                    NSMutableDictionary * progressDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskId,@"taskId",sendBytes ,@"sendBytes",fileName,@"fileName",nil];
                    //在主线程刷新UI
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(updateProgress:) withObject:progressDic waitUntilDone:YES];
                }
            }];
            [dataTask resume];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }
    if (i== httpBlockNum) {
        self.taskInfo.taskStatus = FINISHED;
    }
    [file closeFile];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandle
{
    NSLog(@"didReceiveResponse====");
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    NSLog(@"error====%@",error);
}

-(void) setParameter:(NSMutableString*) bodyString key: (NSString*) key value: (NSString*) value {
    //添加分界线，换行
    [bodyString appendFormat:@"--%@\r\n",boundary];
    //添加字段名称，换2行
    [bodyString appendFormat:@"Content-Disposition:form-data; name=\"%@\"\r\n\r\n",key];
    //添加字段的值
    [bodyString appendFormat:@"%@\r\n",value];
}

- (void)main {
    @try {
        [self upload:self.taskInfo.ip port:@"" user:self.taskInfo.userName password:self.taskInfo.password remotePath:self.taskInfo.serverPath fileNamePath: self.taskInfo.localFileNamePath fileName:self.taskInfo.fileName];
    }@catch (NSException *exception) {
        
    }
}

@end
