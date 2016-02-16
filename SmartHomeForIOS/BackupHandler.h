//
//  BackupHandler.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/29.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackupHandler : NSObject
@property(nonatomic,strong)NSArray * sourceFilesArray; //存储所有需要备份的文件
@property(nonatomic,strong)NSArray * sourceDirsArray;//存储所有需要备份的文件夹
@property(nonatomic,strong)NSString * targetDir;//存储备份到目标文件夹下
@property(nonatomic,strong)NSString * userName;
@property(nonatomic,strong)NSString * password;
@property(nonatomic,strong)NSString * taskId;
@property(nonatomic,strong)NSString * localCurrentDir;//本地当前路径
- (id)init:(NSArray *)sourceFilesArray sourceDirsArray:(NSArray*)sourceDirsArray localCurrentDir:(NSString*)localCurrentDir targetDir:(NSString*)targetDir userName:(NSString*)userName password:(NSString*)password;
-(void) backupHandle;
@end
