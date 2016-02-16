//
//  Tools.h
//  HelloTest
//
//  Created by apple1 on 15/9/9.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"
#import "PhotoTools.h"
#import "KxMovieDecoderVer2.h"
#import <AVFoundation/AVFoundation.h>

@interface FileTools : NSObject
+ (NSMutableDictionary *)getAllFiles:(NSString *)path skipDescendents:(bool)skip isShowAlbum:(bool)isShowAlbum;
+ (NSMutableDictionary *)getAllFilesByType:(NSString *)path skipDescendents:(bool)skip fileExtend:(NSArray*)fileExtendArray;

+ (NSMutableDictionary *)getAllDirByPath:(NSString *)path;//获取path下的目录

+ (NSDictionary *)getAudioDataInfoFromFileURL:(NSURL *)fileURL;
+ (int)deleteFilesByUrl:(NSDictionary*)fileUrlsDic;//删除本地文件
+ (int)deleteFileByUrl:(NSString*)fileUrl;//删除本地单个文件

//+ (int) copyFileByUrl:(NSString*)fileUrl toPath: (NSString*)destinationUrl;
+ (int)moveFileByUrl:(NSString*)fileUrl toPath: (NSString*)destinationUrl;

+ (int) saveFileFromAsset:(ALAsset *)cellAsset toPath: (NSString*)destinationUrl;
//获取用户设置信息的保存路径
+ (NSString*)getUserDataFilePath;
+(void) saveIPInPlist:(NSString *) textFieldIp;
+(void) removeUserFromPliset;
+ (void) saveUserInPlist: (NSString *) userName passWord:(NSString *)passWord isAutoLogin:(BOOL *)isAutoLogin;
+(long long)getFileSize:(NSString*)fileNamePath;

//获取path目录下的所有文件
+ (NSArray *)getAllFilesUrl:(NSString *)path;
//获取path目录下的所有目录
+ (NSArray *)getAllDirs:(NSString *)path;

//将相册移动到指定目录下
- (void) moveAssets:(NSDictionary *)paramsDic;
+(UIImage*)getVideoDuartionAndThumb:(NSString *)videoURL;

+(NSString *)convertFileSize:(NSString *) byte;

#pragma mark -
#pragma mark getDuplicateFileNames 返回指定目录下的所有重名文件名称
+(NSMutableArray*)getDuplicateFileNames:(NSString*)path fileNames:(NSArray*)fileNamesArray;
//获取path目录下的所有文件，不递归
+ (NSArray *)getFilesByPath:(NSString *)path;
@end
