//
//  UploadFileTool.m
//  TestUrlSession
//
//  Created by riqiao on 15/11/17.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FileUploadTool.h"
#import "NSUUIDTool.h"
@implementation FileUploadTool

NSString* boundary = @"----WebKitFormBoundaryT1HoybnYeFOGFlBR";

- (id)initWithLocalPath:(NSString *)localStr withServer:(NSString*)serverStr
           withName:(NSString*)theName withPass:(NSString*)thePass {
    self = [super init];
    if (self == nil)
        return nil;
    localStr = [localStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.localPath = localStr;
    
    self.serverPath = [serverStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.userName = theName;
    self.passWord = thePass;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:[NSUUIDTool gen_uuid]];
    // 后台下载用 backgroundSessionConfiguration
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    return self;
}
- (void)upload: (NSString*) ip port:(NSString*) port user:(NSString*) user password:(NSString*) password remotePath:(NSString*) remotePath fileNamePath:(NSString*)fileNamePath fileName:(NSString*)fileName{
    NSString *urlStr =[NSString stringWithFormat:@"http://%@:8080/smarty_storage/phone/upload.php",ip];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSMutableString *bodyString = [[NSMutableString alloc]init];
    [self putParameter:bodyString key:@
     "user" value:user];
    [self putParameter:bodyString key:@
     "password" value:password];
    [self putParameter:bodyString key:@
     "path" value:remotePath];
    [self putParameter:bodyString key:@
     "filename" value:fileName];
    
    // header of uploaded file
    [bodyString appendFormat:@"--%@\r\n",boundary];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"form\";"];
    [bodyString appendFormat:@"filename=\"%@\"\r\n",@"uploadfile"];
    [bodyString appendString:@"Content-Type: image/jpeg\r\n\r\n"];
    NSMutableData *bodyHeadData = [[NSMutableData alloc]init];
    
    NSData *bodyStringData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [bodyHeadData appendData:bodyStringData];
    NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *dic = [fileManager attributesOfItemAtPath:fileNamePath error:nil];

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
  //  [request setHTTPBody:bodyHeadData];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [request setTimeoutInterval:20];
    NSData *dataOfFile =[[NSData alloc]  initWithContentsOfFile:fileNamePath options:NSDataReadingMappedIfSafe error:nil];
    NSString *tempPath = NSTemporaryDirectory();
   tempPath= [tempPath stringByAppendingPathComponent:fileName];
    
    // 组装POST格式
    if (dataOfFile) {
        [fileManager createFileAtPath:tempPath contents:bodyHeadData attributes:nil];
        fileManager=nil;
        NSFileHandle* fh=[NSFileHandle fileHandleForWritingAtPath:tempPath];
        [fh seekToEndOfFile];
        [fh writeData:dataOfFile];
        NSMutableData *bodyFootData=[[NSMutableData alloc]init];
        [bodyFootData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyFootData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [fh seekToEndOfFile];
        [fh writeData:bodyFootData];
        [fh closeFile];
    }
    

    NSString *contentLength = [NSString stringWithFormat:@"%zi",[bodyHeadData length]];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    NSString *filePath = [[NSString stringWithFormat:@"file://%@", tempPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileUrl = [NSURL URLWithString:filePath];

    NSURLSessionUploadTask * uploadtask = [self.session uploadTaskWithRequest:request fromFile:fileUrl ];
    //NSURLSessionUploadTask * uploadtask = [self.session  uploadTaskWithRequest:request fromFile:fileUrl];
    [uploadtask resume];
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    self.lastUpdSize = totalBytesSent;
   // if(progress>=1 || totalBytesExpectedToSend==totalBytesSent )
    {
        NSNumber* currentProgress = [NSNumber numberWithFloat: ((float)totalBytesSent/(float)totalBytesExpectedToSend)];
        
        NSMutableDictionary * progressDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskId,@"taskId",currentProgress ,@"progress", nil];
        //在主线程刷新UI
        [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(updateProgress:) withObject:progressDic waitUntilDone:YES];
        self.lastUpdSize = totalBytesSent;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    NSLog(@"error====%@",error);
}

-(void) putParameter:(NSMutableString*) bodyString key: (NSString*) key value: (NSString*) value {
    //添加分界线，换行
    [bodyString appendFormat:@"--%@\r\n",boundary];
    //添加字段名称，换2行
    [bodyString appendFormat:@"Content-Disposition:form-data; name=; name=\"%@\"\r\n\r\n",key];
    //添加字段的值
    [bodyString appendFormat:@"%@\r\n",value];
}
@end
