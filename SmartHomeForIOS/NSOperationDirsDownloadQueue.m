//
//  NSOperationDirsDownloadQueue.m
//  SmartHomeForIOS
//
//  Created by riqiao on 16/3/4.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "NSOperationDirsDownloadQueue.h"

@implementation NSOperationDirsDownloadQueue
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static NSOperationDirsDownloadQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSOperationDirsDownloadQueue alloc] init];
        [instance setMaxConcurrentOperationCount:1];
        
    });
    return instance;
}
@end
