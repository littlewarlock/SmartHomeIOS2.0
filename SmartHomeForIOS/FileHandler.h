//
//  FileHandler.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/11/4.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileHandlerDelegate.h"
#import "NSOperationDownloadQueue.h"
@interface FileHandler : NSObject<UITextFieldDelegate>

@property(assign, nonatomic) NSUInteger opType;
@property(assign, nonatomic) id<FileHandlerDelegate>  fileHandlerDelegate;
@property (copy, nonatomic) NSString *cpath;
@property (copy, nonatomic) NSString *flag; //0 取消 1 覆盖
@property (copy, nonatomic) NSString *selectedFileName;
@property (strong, nonatomic) NSMutableDictionary * tableDataDic;
@property (strong, nonatomic) NSCondition *condition;
@property (assign, nonatomic) BOOL isServerSessionTimeOut; //是否连接超时(防止复制移动操作重复跳转login)
- (id) init;
#pragma mark -
#pragma mark uploadFile 上传单个文件的处理
- (void)uploadFile:(NSString*) fileName localFilePath:(NSString*)localFilePath serverCpath:(NSString*)serverCpath;

#pragma mark -
#pragma mark uploadFile 上传单个文件的处理
- (void)uploadFileWithHttp:(NSOperationQueue *)uploadQueue fileName:(NSString*) fileName localFilePath:(NSString*)localFilePath    serverCpath:(NSString*)serverCpath;

#pragma mark -
#pragma mark downloadFiles 下载文件的处理
//- (void)downloadFiles:(NSOperationQueue *)downloadQueue selectedItemsDic: (NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath;

- (void)downloadFiles:(NSOperationDownloadQueue *)downloadQueue selectedItemsDic: (NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath cachePath:(NSString*)cachePath;
#pragma mark -
#pragma mark deleteFiles 删除文件的处理(可多个)
-(void)deleteFiles:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath;
#pragma mark -
#pragma mark shareFile 共享文件的处理
-(void)shareFile:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath isShare:(NSString*)isShare;
-(void)shareFiles:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath isShare:(NSString*)isShare;
-(void)renameFile:(NSString*)fileName alertViewDelegate:(nullable id)alertViewDelegate;

-(void)createFolder:(nullable id)alertViewDelegate;

#pragma mark -
#pragma mark copyFiles 复制文件的处理
-(void)copyFiles:(NSMutableDictionary*) paramsDic;

#pragma mark -
#pragma mark moveFiles 复制文件的处理
-(void)moveFiles:(NSMutableDictionary*) paramsDic;

#pragma mark -
#pragma mark getAllFilesByPath 返回指定目录下的所有文件
-(NSDictionary*)getAllFilesByPath:(NSString*)path;

-(void)signal:(NSString*)opType;

-(long long int)getFileSize:(NSString*)filePath fileName:(NSString*)fileName;

@end
