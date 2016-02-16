//
//  LocalHander.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/16.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalFileHandlerDelegate.h"
#import "FDTableViewCell.h"
@interface LocalFileHandler : NSObject<UITextFieldDelegate>
@property(assign, nonatomic) NSUInteger opType;
@property(assign, nonatomic) id<LocalFileHandlerDelegate> localFileHandlerDelegate;
@property (copy, nonatomic) NSString *selectedFileName;
@property (strong, nonatomic) NSMutableDictionary * tableDataDic;
@property (copy, nonatomic) NSString *cpath;
@property (strong, nonatomic) FileInfo *fileInfo;
@property (strong, nonatomic) NSOperationQueue *queue;
#pragma mark -
#pragma mark downLoadFiles 新建文件夹的处理
- (void)createFolderAction;
- (void)downloadAction;
-(void)deleteFiles:(NSMutableDictionary*) selectedItemsDic;
-(void)renameFile:(FileInfo *) fileInfo;

@end
