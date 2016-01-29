//
//  DeviceCurrentInstance.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/25.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceCurrentVariable : NSObject

@property (nonatomic,strong) NSString *userId;
@property (nonatomic,assign) NSString *role;
@property (nonatomic,strong) NSString *roleName;
@property (nonatomic,strong) NSString *currentSessionId;
@property (nonatomic,strong) NSString *localBaseURL;
@property (nonatomic,strong) NSString *cloudBaseURL;
@property (nonatomic,strong) NSString *deviceTag;

+ (instancetype)sharedInstance;
+ (BOOL)isPureInt:(NSString *)string;
+ (BOOL)isPureFloat:(NSString *)string;

@end
