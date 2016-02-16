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


/** 检测盒子中的迅雷是否打开*/
+ (void)thunderOn:(BOOL)isON
{
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_ISON_URL params:nil httpMethod:@"GET"];
    __weak typeof(self) weakSelf = self;
    [op addCompletionHandler:^(MKNetworkOperation *operation) {

        
        if (isON == YES) {//用户开启迅雷
            if ([[operation responseString] isEqualToString:@"0"]) {//盒子已经启动迅雷
              NSLog(@"盒子已经启动迅雷");
            }else {//盒子未启动迅雷
                NSLog(@"盒子未启动迅雷");
                [weakSelf openThunderwithBlock:nil];
            }
        } else {//用户未开启迅雷
            if ([[operation responseString] isEqualToString:@"0"]) {//盒子已经启动迅雷
                NSLog(@"--盒子已经启动迅雷");
                [weakSelf closeThunderwithBlock:nil];
            }else {//盒子未启动迅雷
                NSLog(@"--盒子未启动迅雷");
                return;
            }
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        
    }];
    
    [engine enqueueOperation:op];

}
/** 启动盒子中的迅雷*/
+ (void )openThunderwithBlock:(void (^)(NSString *result,  NSError *error))block
{

    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_ON_URL params:nil httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = operation.responseString;
        NSLog(@"result-----:%@",result);
        if (block) {
            block(result,nil);
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {

        if (block) {
            block(@"网络异常",err);
        }
        
    }];

    [engine enqueueOperation:op];

}
/** 关闭盒子中的迅雷*/
+ (void )closeThunderwithBlock:(void (^)(NSString *result,  NSError *error))block
{
   
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_OFF_URL params:nil httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = operation.responseString;
        if (block) {
            block(result,nil);
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        if (block) {
            block(@"网络异常",err);
        }
        
    }];
    
    [engine enqueueOperation:op];
    
}

/** 返回迅雷的激活码*/
+ (void )activeCodewithBlock:(void (^)(NSString *result,  NSError *error))block
{
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_KEY_URL params:nil httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = operation.responseString;
        if (block) {
            block(result,nil);
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        if (block) {
            block(@"网络异常",err);
        }
        
    }];
    
    [engine enqueueOperation:op];
    
}


@end
