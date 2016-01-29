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



//1. 整形判断
+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

//2.浮点形判断：
+ (BOOL)isPureFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

@end
