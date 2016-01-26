//
//  thunderTools.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/1/13.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "thunderTools.h"

@interface thunderTools()

@property(nonatomic, copy)NSString *activeCode;

@end



@implementation thunderTools

/** 启动盒子中的迅雷*/
+ (void)openThunder
{
    
    NSLog(@"打开迅雷");
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_ON_URL params:nil httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        
    }];  
    
    [engine enqueueOperation:op];
}

/** 关闭盒子中的迅雷*/
+ (void)closeThunder
{
    NSLog(@"关闭迅雷");
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_OFF_URL params:nil httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        
    }];
    
    [engine enqueueOperation:op];
}

/** 检测盒子中的迅雷是否打开*/
+ (void)thunderOn:(BOOL)isON
{
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_ISON_URL params:nil httpMethod:@"GET"];
    __weak typeof(self) weakSelf = self;
    [op addCompletionHandler:^(MKNetworkOperation *operation) {

        if (isON) {//用户开启迅雷
            if ([[operation responseString] isEqualToString:@"0"]) {//盒子已经启动迅雷
                
            }else {//盒子未启动迅雷
                [weakSelf openThunder];
            }
        } else {//用户未开启迅雷
            if ([[operation responseString] isEqualToString:@"0"]) {//盒子已经启动迅雷
                [weakSelf closeThunder];
            }else {//盒子未启动迅雷
                return;
            }
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        
    }];
    
    [engine enqueueOperation:op];

}


@end
