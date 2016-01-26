//
//  TaskInfo.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/10.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "TaskInfo.h"

@implementation TaskInfo

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject: self.taskId forKey:@"taskId"];
    [encoder encodeObject: self.taskType forKey:@"taskType"];
    [encoder encodeObject: self.cachePath forKey:@"cachePath"];
    [encoder encodeObject: self.fileName forKey:@"fileName"];
    [encoder encodeObject: self.filePath forKey:@"filePath"];
    [encoder encodeObject: self.fileSize forKey:@"fileSize"];
    [encoder encodeObject: self.fileUrl forKey:@"fileUrl"];
    [encoder encodeObject: self.taskStatus forKey:@"taskStatus"];
    [encoder encodeObject: self.tempPath forKey:@"tempPath"];
    [encoder encodeInt64: self.totalBytes forKey:@"totalBytes"];
    [encoder encodeInt64: self.transferedBlocks forKey:@"transferedBlocks"];
    [encoder encodeInt64: self.transferedBytes forKey:@"transferedBytes"];
    [encoder encodeObject: self.currentProgress forKey:@"currentProgress"];
    [encoder encodeObject: self.taskName forKey:@"taskName"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.taskId = [decoder decodeObjectForKey:@"taskId"];
        self.taskType = [decoder decodeObjectForKey:@"taskType"];
        self.cachePath =[decoder decodeObjectForKey:@"cachePath"];
        self.fileName = [decoder decodeObjectForKey:@"fileName"];
        self.filePath = [decoder decodeObjectForKey:@"filePath"];
        self.fileSize =[decoder decodeObjectForKey:@"fileSize"];
        self.fileUrl = [decoder decodeObjectForKey:@"fileUrl"];
        self.taskStatus = [decoder decodeObjectForKey:@"taskStatus"];
        self.tempPath = [decoder decodeObjectForKey:@"tempPath"];
        self.totalBytes = [decoder decodeInt64ForKey:@"totalBytes"];
        self.transferedBlocks = [decoder decodeInt64ForKey:@"transferedBlocks"];
        self.transferedBytes = [decoder decodeInt64ForKey:@"transferedBytes"];
        self.currentProgress = [decoder decodeObjectForKey:@"currentProgress"];
        self.taskName = [decoder decodeObjectForKey:@"taskName"];
       
    }
    return self;
}

@end
