//
//  FileDowanLoadTools.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/12.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "ProgressBarViewController.h"


@interface FileDownloadTools : NSOperation
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *cachePath;
@property (atomic, retain)ProgressBarViewController * progressBarView;
@property (nonatomic, strong) NSString * taskId;
@property (nonatomic, assign) long long int   lastUpdSize;

- (id)initWithFileInfo;

@end