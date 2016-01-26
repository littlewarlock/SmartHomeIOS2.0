//
//  AppInfo.h
//  SmartHomeForIOS
// app相关信息
//  Created by riqiao on 15/8/27.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject
@property (strong,nonatomic) NSString* appName;
@property (assign,nonatomic) int appKey;
@property (strong,nonatomic) NSString* appIconName;
@property (strong,nonatomic) NSString* appInfo;
@property (strong,nonatomic) NSString* appVersion;


@end
