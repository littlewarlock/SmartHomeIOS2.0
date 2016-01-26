//
//  NSOperationDownloadQueue.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/12/11.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationDownloadQueue : NSOperationQueue
+ (instancetype)sharedInstance;
-(void) freezeOperations;
-(void) checkAndRestoreFrozenOperations;
-(NSString*) cacheDirectoryName;
@end
