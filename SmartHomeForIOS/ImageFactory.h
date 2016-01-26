//
//  ImageFactory.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/8.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileInfo.h"


@interface ImageFactory : NSObject
+(UIImage *)getImage:(NSString *)filetype size:(NSInteger)size;
+(UIImage *)getCheckImage:(BOOL)flag;
+(BOOL)checkFileTypeToOpen:(NSString *)filetype;
@end
