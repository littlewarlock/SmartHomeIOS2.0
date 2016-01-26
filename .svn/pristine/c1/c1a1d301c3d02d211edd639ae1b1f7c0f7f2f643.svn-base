//
//  FileUploadByBlockOperation.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/12.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskInfo.h"
#import "TaskStatusConstant.h"
#import "ProgressBarViewController.h"
@interface FileUploadByBlockOperation : NSOperation<NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property (nonatomic,strong) NSString * taskId;
@property (nonatomic,strong) NSString * serverPath;
@property (nonatomic,strong) NSString * userName;
@property (nonatomic,strong) NSString * fileName;
@property (nonatomic,strong) NSString * localFileNamePath;
@property (nonatomic,strong) NSString * password;

@property (nonatomic, strong) TaskInfo * taskInfo;
@property (nonatomic,strong) NSString * ip;
@property (nonatomic,strong) NSString * port;
@property (nonatomic,strong)NSURLSession * session;
@property (nonatomic,assign) BOOL  isBackup;
@property (nonatomic,assign) long long totalBytes;

- (void)upload: (NSString*) ip port:(NSString*) port user:(NSString*) user password:(NSString*) password remotePath:(NSString*) remotePath fileNamePath:(NSString*)fileNamePath fileName:(NSString*)fileName;
- (id)initWithLocalPath:(NSString *)localStr ip:(NSString*)ip withServer:(NSString*)serverStr
               withName:(NSString*)theName withPass:(NSString*)thePass;

@end


