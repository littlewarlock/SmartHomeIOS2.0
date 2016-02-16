//
//  NSOperationUploadQueue.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/22.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationUploadQueue : NSOperationQueue
+ (instancetype)sharedInstance;
-(void) freezeOperations;
-(void) checkAndRestoreFrozenOperations;
-(NSString*) cacheDirectoryName;

@end
