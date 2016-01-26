//
//  UploadFileTool.h
//  TestUrlSession
//
//  Created by riqiao on 15/11/17.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProgressBarViewController.h"
@interface FileUploadTool : NSObject<NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSString * taskId;
@property (nonatomic, strong) NSString * localPath;
@property (nonatomic, strong) NSString * serverPath;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * passWord;
@property (nonatomic, assign) long long int   localSize;
@property (nonatomic, assign) long long int   lastUpdSize;
@property (strong,nonatomic)NSURLSession * session;

- (void)upload: (NSString*) ip port:(NSString*) port user:(NSString*) user password:(NSString*) password remotePath:(NSString*) remotePath fileNamePath:(NSString*)fileNamePath fileName:(NSString*)fileName;
- (id)initWithLocalPath:(NSString *)localStr withServer:(NSString*)serverStr withName:(NSString*)theName withPass:(NSString*)thePass;
@end
