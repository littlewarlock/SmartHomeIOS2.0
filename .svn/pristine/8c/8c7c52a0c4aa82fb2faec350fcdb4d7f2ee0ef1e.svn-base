//
//  FileUploadByBlockTool.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/11/20.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProgressBarViewController.h"

@interface FileUploadByBlockTool : NSOperation<NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property (nonatomic,strong) NSString * taskId;
@property (nonatomic,strong) NSString * serverPath;
@property (nonatomic,strong) NSString * userName;
@property (nonatomic,strong) NSString * fileName;
@property (nonatomic,strong) NSString * localFileNamePath;
@property (nonatomic,strong) NSString * password;
@property (nonatomic,strong) NSString * ip;
@property (nonatomic,strong) NSString * port;
@property (nonatomic,strong)NSURLSession * session;
@property (nonatomic,assign) BOOL  isBackup;
@property (nonatomic,assign) long long totalBytes;

- (void)upload: (NSString*) ip port:(NSString*) port user:(NSString*) user password:(NSString*) password remotePath:(NSString*) remotePath fileNamePath:(NSString*)fileNamePath fileName:(NSString*)fileName;
- (id)initWithLocalPath:(NSString *)localStr ip:(NSString*)ip withServer:(NSString*)serverStr
               withName:(NSString*)theName withPass:(NSString*)thePass;

@end
