//
//  TaskInfo.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/10.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskInfo : NSObject<NSCoding>
@property (nonatomic, strong) NSString *taskId;//任务id
@property (nonatomic, strong) NSString *taskType;//任务类别
@property (nonatomic, strong) NSString *taskName;//任务名称

@property (nonatomic, strong) NSNumber *currentProgress;//当前进度
@property (assign, nonatomic)long long  totalBytes;
@property(nonatomic,strong)NSString *fileName;
@property(nonatomic,strong)NSString *fileSize;
@property(nonatomic,strong)NSString *fileUrl;
@property(nonatomic,strong)NSString *tempPath;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, assign) long long int  transferedBytes;
@property (nonatomic, assign) long long int transferedBlocks;
@property (nonatomic, strong) NSString *taskStatus;
@property (nonatomic, strong) NSString *serverPath;//上传时 传到服务器端的指定路径
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *localFileNamePath;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *port;

@property (nonatomic, strong) NSMutableArray *filesArray;//上传或者下载的文件列表
@property (nonatomic, assign) int fileIndex;//记录当前正在上传或下载的文件在文件列表的索引
@end
