//
//  AlbumUploadByBlockTool.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/12/3.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "AlbumUploadByBlockTool.h"

#import "RequestConstant.h"
#import "FileTools.h"
@implementation AlbumUploadByBlockTool
- (id)initWithLocalPath:(NSString *)localStr ip:(NSString*)ip withServer:(NSString*)serverStr
                     withName:(NSString*)theName withPass:(NSString*)thePass cellAsset:(ALAsset*)cellAsset {
    self = [super init];
    if (self == nil)
        return nil;
    localStr = [localStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.localFileNamePath = localStr;
    self.ip=ip ;
    self.serverPath = serverStr;
    self.userName = theName;
    self.port = REQUEST_PORT;
    self.password = thePass;
    self.fileName = [localStr lastPathComponent];
    self.cellAsset = cellAsset;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration  delegate:self delegateQueue:queue];
    
    return self;
}

- (void)main {
    @try {
        int result = [FileTools saveFileFromAsset:self.cellAsset toPath:self.localFileNamePath];
        if(result==0)
            [super upload:self.ip port:@"" user:self.userName password:self.password remotePath:self.serverPath fileNamePath: self.localFileNamePath fileName:self.fileName];
        
        [FileTools deleteFileByUrl:self.localFileNamePath];//删除本地单个文件
    }@catch (NSException *exception) {
        
    }
}
@end
