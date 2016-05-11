//
//  DirsHandler.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/3/1.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskInfo.h"
#import "ProgressBarViewController.h"
#import "FileTools.h"
#import "NSUUIDTool.h"
#import "DirsDownloadOperation.h"
#import "NSOperationDirsDownloadQueue.h"

@interface DirsHandler : NSObject
@property(nonatomic,strong) NSString * cloundCurrentDir;//云端当前路径
@property(nonatomic,strong)NSString * targetDir;//下载到目标文件夹下
@property(nonatomic,strong)NSMutableArray * dirsArray;//存储用户选择需下载的目录
@property(nonatomic,strong)NSMutableArray * allDirsArray;//存储所有的目录
@property(nonatomic,strong)NSMutableArray * allFilesArray;

- (id)init:(NSMutableArray*)dirsArray filesArray:(NSMutableArray*)filesArray cloundCurrentDir:(NSString*)cloundCurrentDir targetDir:(NSString*)targetDir;

- (void)traversalDirs: (NSMutableArray*)dirsArray currentPath:(NSMutableString *)currentPath;

- (void) dirsHandle;
@end
