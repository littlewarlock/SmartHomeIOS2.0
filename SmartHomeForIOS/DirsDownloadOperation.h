//
//  DirsDownloadOperation.h
//  SmartHomeForIOS
//  下载目录
//  Created by riqiao on 16/3/1.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskInfo.h"
#import "ProgressBarViewController.h"
#import "FileTools.h"

@interface DirsDownloadOperation : NSOperation

@property(nonatomic,strong) TaskInfo * taskInfo;
@property(nonatomic,strong) NSString * cloundCurrentDir;//云端当前路径
@property(nonatomic,strong)NSString * targetDir;//下载到目标文件夹下
@property(nonatomic,strong)NSMutableArray * allDirsArray;//存储所有的目录
@property(nonatomic,strong)NSMutableArray * allFilesArray;

- (id)initWithTaskInfo:(TaskInfo*) taskInfo dirs:(NSMutableArray*)allDirsArray filesArray:(NSMutableArray*)filesArray cloundCurrentDir:(NSString*)cloundCurrentDir targetDir:(NSString*)targetDir;


- (void)download: (NSString*) ip port:(NSString*) port user:(NSString*) user password:(NSString*) password remotePath:(NSString*) remotePath  fileName:(NSString*)fileName targetPath:(NSString*)targetPath;
@end
