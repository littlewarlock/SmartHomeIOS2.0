//
//  FileCopyAndMoveTools.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/24.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FileCopyTools.h"

@implementation FileCopyTools

- (id)initWithFileInfo {
    if (self=[super init]) {
        self.fileUrl = 0;
        self.destinationUrl = 0;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)main {
    @try {
        
        if([self.opType isEqualToString:@"copy"]){
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            BOOL bRet = [fileMgr fileExistsAtPath:self.fileUrl];
            if (bRet) {
                if ([fileMgr copyItemAtPath:self.fileUrl toPath:self.destinationUrl error:&err] != YES){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[err localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
                    [alert show];
                    NSLog(@"Unable to move file: %@", [err localizedDescription]);
                }
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
                [alert show];
            }
            if (!err) {
            }
        }
//        else if([self.opType isEqualToString:@"move"]){
//            NSFileManager *fileMgr = [NSFileManager defaultManager];
//            NSError *err;
//            BOOL bRet = [fileMgr fileExistsAtPath:self.fileUrl];
//            if (bRet) {
//                if ([fileMgr moveItemAtPath:self.fileUrl toPath:self.destinationUrl error:&err] != YES){
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[err localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
//                    [alert show];
//                    NSLog(@"Unable to move file: %@", [err localizedDescription]);
//                }
//            }else{
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
//                [alert show];
//            }
//            if (!err) {
//            }
//        }
    }
    @catch (NSException *exception) {
        
    }
}
@end
