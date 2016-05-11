//
//  NSOperationDirsDownloadQueue.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/3/4.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationDirsDownloadQueue : NSOperationQueue
+ (instancetype)sharedInstance;
@end
