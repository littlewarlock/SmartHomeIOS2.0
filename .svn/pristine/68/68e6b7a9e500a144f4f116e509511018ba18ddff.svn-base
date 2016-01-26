//
//  NSUUID.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "NSUUIDTool.h"

@interface NSUUIDTool ()

@end

@implementation NSUUIDTool
+ (NSString *) gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}
@end
