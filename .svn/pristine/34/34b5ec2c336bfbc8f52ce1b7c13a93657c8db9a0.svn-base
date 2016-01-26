//
//  FileInfo.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/8.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileInfo : NSObject
@property (nonatomic, strong) NSString *fileId;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileSize;
@property (nonatomic, strong) NSString *fileChangeTime;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, strong) NSString *fileSubtype;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) NSString *isShare;
@property (nonatomic, strong) NSString *cpath; //当前路径(云端调视频缩略图)

@property (nonatomic) BOOL isSelect;

+ (NSURL *)smartURLForString:(NSString *)str;
+ (uint64_t) getFTPStreamSize:(CFReadStreamRef)stream;

+ (NSString*) pathForDocument;
+ (uint64_t) getFileSize:(NSString *)filePath;

@end
