    //
//  DeviceNetworkInterface.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/25.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "DeviceNetworkInterface.h"
#import "DeviceCurrentVariable.h"
#import "DataManager.h"

//#define serverHost               @"172.16.10.110/smarthome/app"
//#define serverHost               @"172.16.9.95:82/smarthome/app"
//static NSString *url = @"172.16.9.247:8080/smarthome/app";
//static NSString *url = @"172.16.9.101:8080/smarthome/app";
//
//NSString* urtTest = @"172.16.1.216:8080/smarthome/test";
NSString* urtTest = @"123.57.223.91";



@interface DeviceNetworkInterface ()
{
    AppDelegate *appDelegate;
}

@end

Boolean isServerSessionOutOfTime = NO;

@implementation DeviceNetworkInterface

//
+(void)checkServerNetworkError{
    isServerSessionOutOfTime = YES;
}
//


//
+(void)checkServerSessionOutOfTimeWithOpertion:(MKNetworkOperation *)operation{
    NSString *result = operation.responseJSON[@"result"];
    NSString *message = operation.responseJSON[@"message"];
    if ([result isEqualToString:@"timeout"]) {
        if ([message isEqualToString:@""]) {
            isServerSessionOutOfTime = YES;
            NSLog(@"isServerSessionOutOfTime== %hhu",isServerSessionOutOfTime);
            //发送通知lagout
            [[NSNotificationCenter defaultCenter] postNotificationName:@"letuserlogout" object:nil];
            //
            return;
        }
    }
    NSLog(@"isServerSessionOutOfTime== %hhu",isServerSessionOutOfTime);
    isServerSessionOutOfTime = NO;
}
+ (Boolean)isServerSessionOutOfTime{
    return isServerSessionOutOfTime;
}
+ (void)checkNetWorkError{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SMTnetworkerror" object:nil];
}
//2016 02 26
+ (void)serverSessionRefresh{
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"refresh"};
    
    //请求php
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    
    MKNetworkOperation *op = [engine operationWithPath:@"refresh.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
//        NSString *result = operation.responseJSON[@"result"];
//        NSString *message = operation.responseJSON[@"message"];
        
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    
    [engine enqueueOperation:op];

}


//

+(NSString*) getRequestUrl{
    NSString * requestUrl =@"/smarthome/app";
    NSString *url = [NSString stringWithFormat:@"%@%@",[g_sDataManager requestHost],requestUrl];
    return url;
}

// for study
+ (void)getDeviceList:(id)sender
{
//    AFHTTPRequestOperationManager *manager;
//    
//    //data
//    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];;
//    [params setValue:@"session_id" forKey:@"session_id"];
//    [params setValue:@"list" forKey:@"opt"];
//    NSLog(@"params==%@",params);
//    
//    
//    [manager POST:@"172.16.10.110/smarthome/app/device.php" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        NSLog(@"+-+-+-+-+-right+-+-+-+-+-");
//    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//        NSLog(@"+-+-+-+-+-cuowu +-+-+-+-+-");
//
//    }];
//    
//    NSLog(@"response==%@",self.obj);
//
}


+ (void)getDeviceList:(id)sender withBlock:(void (^)(NSArray *, NSError *))block
{
    NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] init];
    
    __block NSError *error = nil;
    
//    [requestParam setValue:[DeviceCurrentVariable sharedInstance].currentSessionId forKey:@"session_id"];
        [requestParam setValue:@"session_id" forKey:@"session_id"];
    [requestParam setValue:@"list" forKey:@"opt"];
    NSLog(@"requestParam==%@",requestParam);
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    
    MKNetworkOperation *op = [engine operationWithPath:@"device.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op onCompletion:^(MKNetworkOperation *operation) {

        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSArray *deviceList = [[NSArray alloc]init];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        if (block) {
            if ([[operation.responseJSON objectForKey:@"result"] isEqualToString:@"success"]) {
                dic = operation.responseJSON;
                deviceList= [operation.responseJSON objectForKey:@"devices"];
                // for test hgc 2015 10 19
                if ([deviceList isEqual:[NSNull null]] || [deviceList isEqual:@""]) {
                    deviceList = @[];
                }
                //for test hgc 2015 10 19
            }else{
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录状态" message:[operation.responseJSON objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
            }
            block(deviceList,nil);
        }
    } onError:^(NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
  
}

+ (void)cameraDiscovery:(id)sender withBlock:(void (^)(NSArray *, NSError *))block
{
    NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] init];
    
    //    [requestParam setValue:[DeviceCurrentVariable sharedInstance].currentSessionId forKey:@"session_id"];
    [requestParam setValue:@"session_id" forKey:@"session_id"];
    [requestParam setValue:@"discovery" forKey:@"opt"];
    NSLog(@"requestParam==%@",requestParam);
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSMutableArray *deviceList;
        NSMutableDictionary *dic;
        if (block) {
            if ([[op.responseJSON objectForKey:@"result"] isEqualToString:@"success"]) {
                dic = op.responseJSON;
                deviceList= [op.responseJSON objectForKey:@"devices"];
                //for test
//                for (int i = 0 ; i < deviceList.count ; i++) {
//                    if ([deviceList[i][@"addition"] isEqualToString:@":"] ||[deviceList[i][@"brand"] isEqual:[NSNull null]]) {
//                        [deviceList removeObjectAtIndex:i];
//                    }
//                }
                //for test
                
            }else{
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录状态" message:[operation.responseJSON objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
            }
            block(deviceList,nil);
        }
    } onError:^(NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,error);
        }
    }];
    
    [engine enqueueOperation:op];

}

+ (Boolean)isObjectNULLwith:(NSObject *)obj
{

    if ([obj isEqual: [NSNull null]] || obj == nil)
    {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *string = obj;
            if ([string isEqualToString:@""]) {
                return YES;
            }
        }
        
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        if (self->navigationController == nil) {
//            [self->navigationController popViewControllerAnimated:YES];
//        }
        return YES;
    }
    return NO;
}

+ (Boolean)isNSStringSpacewith:(NSString *)string
{
    if ([string isEqual: [NSNull null]] || string == nil)
    {
        return YES;
    }else if ([string isKindOfClass:[NSString class]]) {
        if ([string isEqualToString:@""]) {
            return YES;
        }
    }
    return NO;
}



+(void)realTimeCameraStreamWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"stream",@"devid":deviceId};
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSString *stream = operation.responseJSON[@"stream"];
        NSString *ptz = operation.responseJSON[@"ptz"];
        NSString *monitoring = operation.responseJSON[@"monitoring"];
        NSString *recording = operation.responseJSON[@"recording"];
        NSString *mode = operation.responseJSON[@"mode"];
        NSString *onlining = operation.responseJSON[@"onlining"];
        
        if (block) {
            if ([[op.responseJSON objectForKey:@"result"] isEqualToString:@"success"]) {
                block(result,message,stream,ptz,monitoring,recording,mode,onlining,nil);
            }
        }
    } onError:^(NSError *error) {
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        // 2016 02 24
        [self checkNetWorkError];
        //
        
        if (block) {
            block(nil,@"网络异常",nil,nil,nil,nil,nil,nil,error);
        }
    }];
    
    [engine enqueueOperation:op];

}


+ (void)cameraControlWithDirection:(NSString *)direction withDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"continue",@"devid":deviceId,@"direct":direction};
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        
        if (block) {
            if ([[op.responseJSON objectForKey:@"result"] isEqualToString:@"success"]) {
                block(result,message,nil);
            }
        }
    } onError:^(NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)cameraControlStopwithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSString* url = [DeviceNetworkInterface getRequestUrl];

    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"stop",@"devid":deviceId};
    
    //请求php
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)cameraRecordwithDeviceId:(NSString *)deviceId withSwitchParam:(NSString *)switchParam withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"switchmonitor",@"devid":deviceId,@"switch":switchParam};
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        
        if (block) {
            block(result,message,nil);
        }
    } onError:^(NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)realTimeCameraSnapshotWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSString *,NSError *error))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"snapshot",@"devid":deviceId};
    
    //请求php
        NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSString *image = operation.responseJSON[@"snapshot"];
        
        if (block) {
            block(result,message,image,nil);
        }
    } onError:^(NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
    
}

//摄像头报警开关
+(void)cameraAlarmingwithDeviceId:(NSString *)deviceId withAlarmParam:(NSString *)alarmParam withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"switchalarm",@"devid":deviceId,@"switch":alarmParam};
//    NSDictionary *requestParam = @{@"opt":@"alarm",@"devid":deviceId};
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        
        if (block) {
            block(result,message,nil);
        }
    } onError:^(NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];

}

+(void)getDeviceAllSetting:(id)sender withBlock:(void (^)(NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"set"};
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"global.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSString *recVolume = operation.responseJSON[@"globals"][0][@"recVolume"];
        NSString *recLoop = operation.responseJSON[@"globals"][0][@"recLoop"];
        NSString *alarmVolume = operation.responseJSON[@"globals"][0][@"alarmVolume"];
        NSString *alarmLoop = operation.responseJSON[@"globals"][0][@"alarmLoop"];
        //
        //
        if (block) {
            block(result,message,recVolume,recLoop,alarmVolume,alarmLoop,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,nil,nil,nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)saveDeviceAllSettingWithSetArray:(NSArray *)setArray withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"save",
                                   @"recVolume":setArray[0],
                                   @"recLoop":setArray[1],
                                   @"alarmVolume":setArray[2],
                                   @"alarmLoop":setArray[3],
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"global.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

//摄像头添加 点击［添加］
+ (void)getDeviceSettingWithBrand:(NSString *)brand andModel:(NSString *)model withBlock :(void (^)(NSString *, NSString *, NSArray *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"brand",
                                   @"brand":brand,
                                   @"model":model
                                   };
    NSLog(@"brand==%@",brand);
    NSLog(@"model==%@",model);
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"brand.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSArray *brands = operation.responseJSON[@"brands"];
        if (block) {
            block(result,message,brands,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

//手动添加摄像头 点击［手动添加摄像头］
+ (void)getDeviceSettingForManualAdd:(id)sender withBlock:(void (^)(NSString *, NSString *, NSArray *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"brand",
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"brand.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSArray *brands = operation.responseJSON[@"brands"];
        if (block) {
            block(result,message,brands,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)addDeviceAutomaticWithDeviceInfo:(DeviceInfo *)deviceInfo withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"add",
                                   @"code":deviceInfo.code,
                                   @"name":deviceInfo.name,
                                   @"type":deviceInfo.type,
                                   @"addition":deviceInfo.addition,
                                   @"brand":deviceInfo.brand,
                                   @"model":deviceInfo.model,
                                   @"recSetInHome":deviceInfo.recSetInHome,
                                   @"recSetOutHome":deviceInfo.recSetOutHome,
                                   @"recSetInSleep":deviceInfo.recSetInSleep,
                                   @"alarmSetInHome":deviceInfo.alarmSetInHome,
                                   @"alarmSetOutHome":deviceInfo.alarmSetOutHome,
                                   @"alarmSetInSleep":deviceInfo.alarmSetInSleep,
                                   @"sensitivity":deviceInfo.sensitivity,
                                   @"wifi":deviceInfo.wifi,
                                   @"version":deviceInfo.version,
                                   @"userid":deviceInfo.userid,
                                   @"passwd":deviceInfo.passwd,
                                   @"alarmflg":deviceInfo.alarmflg
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"device.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)deleleFromDeviceListWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"update",
                                   @"status":@"0",
                                   @"devid":deviceId
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"device.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];

}

+ (void)deleteFromDeviceListAndFileWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"update",
                                   @"status":@"2",
                                   @"devid":deviceId
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"device.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)getCameraSettingWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSArray *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"detail",
                                   @"devid":deviceId
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"device.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSArray *devices = operation.responseJSON[@"devices"];
        if (block) {
            block(result,message,devices,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)updateCameraSettingWithDeviceInfo:(DeviceInfo *)deviceInfo withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"update",
                                   @"devid":deviceInfo.devid,
                                   @"name":deviceInfo.name,
                                   @"recSetInHome":deviceInfo.recSetInHome,
                                   @"recSetOutHome":deviceInfo.recSetOutHome,
                                   @"recSetInSleep":deviceInfo.recSetInSleep,
                                   @"alarmSetInHome":deviceInfo.alarmSetInHome,
                                   @"alarmSetOutHome":deviceInfo.alarmSetOutHome,
                                   @"alarmSetInSleep":deviceInfo.alarmSetInSleep,
                                   @"sensitivity":deviceInfo.sensitivity,
                                   @"wifi":deviceInfo.wifi,
                                   @"status":@"1"
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"device.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)getCameraRecordHistoryWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *, NSString *, NSArray *, NSArray *, NSError *))block
{
    NSLog(@"day====%@",deviceId);
    NSLog(@"day====%@",day);
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"videolist",
                                   @"devid":deviceId,
                                   @"day":day
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSArray *times = operation.responseJSON[@"times"];
        NSArray *videos = operation.responseJSON[@"videos"];
        if (block) {
            block(result,message,times,videos,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)getCameraRecordHistoryDatesWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *, NSString *, NSArray *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"calendarlist",
                                   @"devid":deviceId,
                                   @"mon":day
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSArray *calendar = operation.responseJSON[@"calendar"];
        if (block) {
            block(result,message,calendar,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)networkTestForDeviceAddWithAddition:(NSString *)addition andUserid:(NSString *)userid andPasswd:(NSString *)passwd andBrand:(NSString *)brand andModel:(NSString *)model withBlock:(void (^)(NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"join",
                                   @"addition":addition,
                                   @"userid":userid,
                                   @"passwd":passwd,
                                   @"brand":brand,
                                   @"model":model
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }

        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //
        //get data
        NSLog(@"join===%@",operation.responseJSON[@"join"]);
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSLog(@"join===%@",result);
        NSLog(@"join===%@",message);
        //
        NSArray *join =operation.responseJSON[@"join"];
        if (join.count == 0) {
            if (block) {
                block(result,message,nil,nil,nil,nil,nil,nil,nil,nil);
            }
        }else{
            NSString *code = operation.responseJSON[@"join"][0][@"code"];
//            NSString *sensitivity = operation.responseJSON[@"join"][0][@"sensitivity"];
            NSString *sensitivity = @"10";
            NSString *wifi = operation.responseJSON[@"join"][0][@"wifi"];
            NSString *brand = operation.responseJSON[@"join"][0][@"brand"];
            NSString *model = operation.responseJSON[@"join"][0][@"model"];
            NSString *version = operation.responseJSON[@"join"][0][@"version"];
            NSString *alarmflg = operation.responseJSON[@"join"][0][@"alarmflg"];
            if (block) {
//                block(result,message,code,sensitivity,wifi,version,alarmflg,nil);
                block(result,message,code,sensitivity,wifi,brand,model,version,alarmflg,nil);
            }
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,nil,nil,nil,nil,nil,nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}   

+ (void)newNetworkTestForDeviceAddWithAddition:(NSString *)addition andUserid:(NSString *)userid andPasswd:(NSString *)passwd withBlock:(void (^)(NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"join",
                                   @"addition":addition,
                                   @"userid":userid,
                                   @"passwd":passwd
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //
        //get data
        NSLog(@"join===%@",operation.responseJSON[@"join"]);
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSLog(@"join===%@",result);
        NSLog(@"join===%@",message);
        //
        NSArray *join =operation.responseJSON[@"join"];
        if (join.count == 0) {
            if (block) {
                block(result,message,nil,nil,nil,nil,nil,nil,nil,nil);
            }
        }else{
            NSString *code = operation.responseJSON[@"join"][0][@"code"];
//            NSString *sensitivity = operation.responseJSON[@"join"][0][@"sensitivity"];
            NSString *sensitivity = @"10";
            NSString *wifi = operation.responseJSON[@"join"][0][@"wifi"];
            NSString *brand = operation.responseJSON[@"join"][0][@"brand"];
            NSString *model = operation.responseJSON[@"join"][0][@"model"];
            NSString *version = operation.responseJSON[@"join"][0][@"version"];
            NSString *alarmflg = operation.responseJSON[@"join"][0][@"alarmflg"];
            if (block) {
                block(result,message,code,sensitivity,wifi,brand,model,version,alarmflg,nil);
            }
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,nil,nil,nil,nil,nil,nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}


+ (void)setCameraPictureRolloverWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"rollover",
                                   @"devid":deviceId
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)setCameraRebootWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"reboot",
                                   @"devid":deviceId
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        if (block) {
            block(result,message,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}

//2016 01 11 hgc merged
+ (void)getAlarmListWithMsgId:(NSString *)msgId andMsgCnt:(NSString *)msgCnt withBlock:(void (^)(NSString *, NSString *, NSArray *, NSError *))block
{
    //2016 01 22
    [DeviceNetworkInterface checkAlarmTransferServerwithBlock:^(NSString *result, NSString *message, NSDictionary *cidinfo, NSError *error) {
        NSString *mac;
        NSString *cid;
        NSString *email;
        NSString *passwd;
        //
        if ([result isEqualToString:@"success"]) {
            if (cidinfo.count == 0) {
                mac = @"";
                cid = @"";
                email = @"";
                passwd = @"";
            }else{
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"mac"]]){
                    mac = @"";
                }else{
                    mac = cidinfo[@"mac"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"cid"]]){
                    cid = @"";
                }else{
                    cid = cidinfo[@"cid"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"email"]]){
                    email = @"";
                }else{
                    email = cidinfo[@"email"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"passwd"]]){
                    passwd = @"";
                }else{
                    passwd = cidinfo[@"passwd"];
                }
            }
            NSLog(@"mac==%@",mac);
            NSLog(@"mac==%@",cid);
            NSLog(@"mac==%@",mac);
            NSLog(@"mac==%@",mac);
//original
            NSDictionary *requestParam = @{@"session_id":@"session_id",
                                           @"opt":@"list",
                                           @"msgid":msgId,
                                           @"msgcnt":msgCnt,
                                           //                                   @"cid":[g_sDataManager cId]
                                           @"mac":mac,
                                           @"cid":cid,
                                           @"email":email,
                                           @"passwd":passwd
                                           };
            //请求php
            //2016 01 11 start
            //    NSString* url = [DeviceNetworkInterface getRequestUrl];
            NSString* url = urtTest;
            //2016 01 11 end
            
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
            [engine useCache];
            MKNetworkOperation *op = [engine operationWithPath:@"alarm.php" params:requestParam httpMethod:@"POST"];
            //操作返回数据
            [op addCompletionHandler:^(MKNetworkOperation *operation) {
                
                if([operation isCachedResponse]) {
                    NSLog(@"Data from cache %@", [operation responseString]);
                }
                else {
                    NSLog(@"Data from server %@", [operation responseString]);
                }
                
                //2016 02 23 hgc
                [self checkServerSessionOutOfTimeWithOpertion:operation];
                // hgc
                
                //get data
                NSString *result = operation.responseJSON[@"result"];
                NSString *message = operation.responseJSON[@"message"];
                NSArray *alarms = operation.responseJSON[@"alarms"];
                if (block) {
                    block(result,message,alarms,nil);
                }
            } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
                // 2016 02 24
                [self checkNetWorkError];
                //
                NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
                if (block) {
                    block(nil,@"网络异常",nil,error);
                }
            }];
            
            [engine enqueueOperation:op];
            
            
        }
    }];
    
    //2016 01 22
   
}

+ (void)delAlarmMsgWithMsgIds:(NSArray *)msgIds withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    
    [DeviceNetworkInterface checkAlarmTransferServerwithBlock:^(NSString *result, NSString *message, NSDictionary *cidinfo, NSError *error) {
        NSString *mac;
        NSString *cid;
        NSString *email;
        NSString *passwd;
        //
        if ([result isEqualToString:@"success"]) {
            if (cidinfo.count == 0) {
                mac = @"";
                cid = @"";
                email = @"";
                passwd = @"";
            }else{
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"mac"]]){
                    mac = @"";
                }else{
                    mac = cidinfo[@"mac"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"cid"]]){
                    cid = @"";
                }else{
                    cid = cidinfo[@"cid"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"email"]]){
                    email = @"";
                }else{
                    email = cidinfo[@"email"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"passwd"]]){
                    passwd = @"";
                }else{
                    passwd = cidinfo[@"passwd"];
                }
            }
//original on
            NSString *ns = [msgIds componentsJoinedByString:@","];
            NSDictionary *requestParam = @{@"session_id":@"session_id",
                                           @"opt":@"del",
                                           @"msgid":ns,
//                                           @"cid":[g_sDataManager cId]
                                           @"mac":mac,
                                           @"cid":cid,
                                           @"email":email,
                                           @"passwd":passwd,
                                           };
            //请求php
            //请求php
            //2016 01 11 start
            //    NSString* url = [DeviceNetworkInterface getRequestUrl];
            NSString* url = urtTest;
            //2016 01 11 end
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
            [engine useCache];
            MKNetworkOperation *op = [engine operationWithPath:@"alarm.php" params:requestParam httpMethod:@"POST"];
            //操作返回数据
            [op addCompletionHandler:^(MKNetworkOperation *operation) {
                
                if([operation isCachedResponse]) {
                    NSLog(@"Data from cache %@", [operation responseString]);
                }
                else {
                    NSLog(@"Data from server %@", [operation responseString]);
                }
                
                //2016 02 23 hgc
                [self checkServerSessionOutOfTimeWithOpertion:operation];
                // hgc
                
                //get data
                NSString *result = operation.responseJSON[@"result"];
                NSString *message = operation.responseJSON[@"message"];
                if (block) {
                    block(result,message,nil);
                }
            } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
                // 2016 02 24
                [self checkNetWorkError];
                //
                NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
                if (block) {
                    block(nil,@"网络异常",error);
                }
            }];
            
            [engine enqueueOperation:op];
//original off
        }
    }];
}

+ (void)setAlarmMsgReadedWithMsgIds:(NSArray *)msgIds withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    
    //2016 01 22
    [DeviceNetworkInterface checkAlarmTransferServerwithBlock:^(NSString *result, NSString *message, NSDictionary *cidinfo, NSError *error) {
        NSString *mac;
        NSString *cid;
        NSString *email;
        NSString *passwd;
        //
        if ([result isEqualToString:@"success"]) {
            if (cidinfo.count == 0) {
                mac = @"";
                cid = @"";
                email = @"";
                passwd = @"";
            }else{
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"mac"]]){
                    mac = @"";
                }else{
                    mac = cidinfo[@"mac"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"cid"]]){
                    cid = @"";
                }else{
                    cid = cidinfo[@"cid"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"email"]]){
                    email = @"";
                }else{
                    email = cidinfo[@"email"];
                }
                
                if ([DeviceNetworkInterface isObjectNULLwith:cidinfo[@"passwd"]]){
                    passwd = @"";
                }else{
                    passwd = cidinfo[@"passwd"];
                }
            }
            //original on
            NSString *ns = [msgIds componentsJoinedByString:@","];
            NSDictionary *requestParam = @{@"session_id":@"session_id",
                                           @"opt":@"setRead",
                                           @"msgid":ns,
//                                           @"cid":[g_sDataManager cId]
                                           @"mac":mac,
                                           @"cid":cid,
                                           @"email":email,
                                           @"passwd":passwd,
                                           };
            //请求php
            //2016 01 11 start
            //    NSString* url = [DeviceNetworkInterface getRequestUrl];
            NSString* url = urtTest;
            //2016 01 11 end
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
            [engine useCache];
            MKNetworkOperation *op = [engine operationWithPath:@"alarm.php" params:requestParam httpMethod:@"POST"];
            //操作返回数据
            [op addCompletionHandler:^(MKNetworkOperation *operation) {
                
                if([operation isCachedResponse]) {
                    NSLog(@"Data from cache %@", [operation responseString]);
                }
                else {
                    NSLog(@"Data from server %@", [operation responseString]);
                }
                
                //2016 02 23 hgc
                [self checkServerSessionOutOfTimeWithOpertion:operation];
                // hgc
                
                //get data
                NSString *result = operation.responseJSON[@"result"];
                NSString *message = operation.responseJSON[@"message"];
                if (block) {
                    block(result,message,nil);
                }
            } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
                // 2016 02 24
                [self checkNetWorkError];
                //
                NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
                if (block) {
                    block(nil,@"网络异常",error);
                }
            }];
            
            [engine enqueueOperation:op];
            //original off
        }
    }];
    
}

+ (void)getCameraSnapshotHistoryWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *, NSString *, NSArray *, NSArray *, NSError *))block
{
    NSLog(@"day====%@",deviceId);
    NSLog(@"day====%@",day);
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"snapshotlist",
                                   @"devid":deviceId,
                                   @"day":day
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSArray *times = operation.responseJSON[@"times"];
        NSArray *videos = operation.responseJSON[@"snapshots"];
        if (block) {
            block(result,message,times,videos,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

+ (void)getCameraModeRecordHistoryWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *, NSString *, NSArray *, NSArray *, NSError *))block
{
    NSLog(@"day====%@",deviceId);
    NSLog(@"day====%@",day);
    NSDictionary *requestParam = @{@"session_id":@"session_id",
                                   @"opt":@"recordlist",
                                   @"devid":deviceId,
                                   @"day":day
                                   };
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseString]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseString]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        NSArray *times = operation.responseJSON[@"times"];
        NSArray *videos = operation.responseJSON[@"videos"];
        if (block) {
            block(result,message,times,videos,nil);
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
}

//2016 01 22
+ (void)checkAlarmTransferServerwithBlock:(void (^)(NSString *, NSString *, NSDictionary *, NSError *))block
{
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"cidinfo"};
    //    NSDictionary *requestParam = @{@"opt":@"alarm",@"devid":deviceId};
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseData]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseData]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSLog(@"checkAlarmTransferServerwithBlock==%@",[operation responseJSON]);
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
//        NSDictionary *cidinfotest = operation.responseJSON[@"cidinfo"];
//        
//        NSLog(@"cidinfotest==%@",cidinfotest[@"cid"]);
//        NSLog(@"cidinfotest==%@",cidinfotest);
        
        NSDictionary *cidinfo = operation.responseJSON[@"cidinfo"];
        if (block) {
            if (
                ([DeviceNetworkInterface isObjectNULLwith:result])
                ||([DeviceNetworkInterface isObjectNULLwith:message])
                ||([DeviceNetworkInterface isObjectNULLwith:cidinfo])
                )
            {
                block(nil,@"接口异常",nil,nil);
            }else{
                block(result,message,cidinfo,nil);
            }
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",nil,error);
        }
    }];
    
    [engine enqueueOperation:op];
    
}

+ (void)delHistoryRecordSnapshotWithPaths:(NSArray *)paths withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    
    NSString *ns = [paths componentsJoinedByString:@","];
    NSDictionary *requestParam = @{@"session_id":@"session_id",@"opt":@"delfiles",@"files":ns};
    
    NSLog(@"ns==%@",ns);
    
    //请求php
    NSString* url = [DeviceNetworkInterface getRequestUrl];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"camera.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([operation isCachedResponse]) {
            NSLog(@"Data from cache %@", [operation responseData]);
        }
        else {
            NSLog(@"Data from server %@", [operation responseData]);
        }
        
        //2016 02 23 hgc
        [self checkServerSessionOutOfTimeWithOpertion:operation];
        // hgc
        
        //get data
        NSLog(@"checkAlarmTransferServerwithBlock==%@",[operation responseJSON]);
        NSString *result = operation.responseJSON[@"result"];
        NSString *message = operation.responseJSON[@"message"];
        
        if (block) {
            if (
                ([DeviceNetworkInterface isObjectNULLwith:result])
                ||([DeviceNetworkInterface isObjectNULLwith:message])
                )
            {
                block(nil,@"接口异常",nil);
            }else{
                block(result,message,nil);
            }
        }
    } errorHandler:^(MKNetworkOperation *errorOp,NSError *error) {
        // 2016 02 24
        [self checkNetWorkError];
        //
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        if (block) {
            block(nil,@"网络异常",error);
        }
    }];
    
    [engine enqueueOperation:op];
}


@end
