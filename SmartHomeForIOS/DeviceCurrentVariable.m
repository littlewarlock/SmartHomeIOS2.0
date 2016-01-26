//
//  DeviceCurrentInstance.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/25.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "DeviceCurrentVariable.h"

@implementation DeviceCurrentVariable

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static DeviceCurrentVariable *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[DeviceCurrentVariable alloc] init];
    });
    return instance;
}

@end
