//
//  FunctionManageTools.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/10.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FunctionManageTools.h"
#import "FileTools.h"
#import "AppInfo.h"

@implementation FunctionManageTools
+ (int)saveSelectedApp{
    AppDelegate *appDelegate;
    appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray * appArray = appDelegate.selectedAppArray;
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *selectedApplistPath = [documentsDirectory stringByAppendingPathComponent:@"SelectedAppInfo.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:selectedApplistPath];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc]init];
    }
    NSMutableArray *oldAdressArray = [dictionary objectForKey:@"SelectedAppInfo"];
    if (!oldAdressArray) {
        oldAdressArray =[[NSMutableArray alloc]init];
    }
    [dictionary removeObjectForKey:@"SelectedAppInfo"];

    [oldAdressArray removeAllObjects];
    for(int i=0;i<appArray.count;i++){
        AppInfo *appInfo = appArray[i];
        [oldAdressArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:appInfo.appName,@"appName",appInfo.appIconName,@"appIconName",[NSNumber numberWithInt:appInfo.appKey],@"appKey",appInfo.appInfo,@"appInfo",appInfo.appVersion,@"appVersion", nil] atIndex: oldAdressArray.count];
    }
    [dictionary setObject:oldAdressArray forKey:@"SelectedAppInfo"];
    [dictionary writeToFile:selectedApplistPath atomically:YES];
    
    return -1;
}


+(NSMutableArray *) readSavedApp{

    NSMutableArray * appArray = [[NSMutableArray alloc]init];
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"SelectedAppInfo.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSMutableArray *oldAdressArr  =  [dictionary objectForKey:@"SelectedAppInfo"];
    //NSLog(plistPath);
    if (oldAdressArr.count !=0) {
        NSArray *array = dictionary[@"SelectedAppInfo"];
        
        if (!array)
        {
            NSLog(@"文件加载失败");
        }
        static NSString * const AppNameKey = @"appName";
        static NSString * const AppIconNameKey = @"appIconName";
        static NSString * const AppKey = @"appKey";
        static NSString * const AppInfoKey = @"appInfo";
        static NSString * const AppVersionKey = @"appVersion";
        
        [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            AppInfo *appInfo = [[AppInfo alloc] init];
            appInfo.appName= dict[AppNameKey];
            appInfo.appIconName = dict[AppIconNameKey];
            appInfo.appKey = [dict[AppKey] intValue];
            appInfo.appInfo= dict[AppInfoKey];
            appInfo.appVersion = dict[AppVersionKey];
            
            [appArray addObject:appInfo];
        }];
       
    }
    
    return appArray;
}

@end
