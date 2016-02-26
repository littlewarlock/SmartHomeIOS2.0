//
//  Tools.m
//  HelloTest
//
//  Created by apple1 on 15/9/9.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import "FileTools.h"
#import "RequestConstant.h"
#import "DataManager.h"
@implementation FileTools

+ (NSMutableDictionary *)getAllFiles:(NSString *)path skipDescendents:(bool)skip isShowAlbum:(bool)isShowAlbum{
    int dirNum = 0;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSMutableDictionary* tableDataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray* fileDataArray = [[NSMutableArray alloc] init];
    NSString* documentsPath = path;
    
    NSString* filePath = documentsPath;
    NSDirectoryEnumerator *direnu = [fm enumeratorAtPath:documentsPath];
    BOOL flag;
    if (tableDataDic != nil) {
        [tableDataDic removeAllObjects];
    }
    if([documentsPath isEqualToString:kDocument_Folder] && isShowAlbum){ //如果是本地根目录，需要在第一行添加相册的访问入口
        FileInfo *dirList = [[FileInfo alloc] init];
        dirList.fileName = @"My Photos";
        dirList.fileType = @"folder"; //文件夹
        dirList.fileSubtype = @"folder";
        [tableDataDic setObject:dirList forKey:[NSString stringWithFormat:@"%d", dirNum]];
        dirNum++;
    }
    
    
    while((filePath = [direnu nextObject])!=nil)
    {
        NSString *fileUrl = [documentsPath stringByAppendingPathComponent:filePath];
        [fm fileExistsAtPath:fileUrl isDirectory:&flag];
        if([filePath length]>=9)
        {
            NSString *extendFileName = [filePath substringFromIndex:[filePath length]-9];
            if ([extendFileName isEqualToString:@".DS_Store"]) { //如果文件扩展名等于.DS_Store不加入文件列表
                //NSLog(@"扩展类型是=====%@",extendFileName);
                continue;
            }
        }
        NSDictionary *dic = [fm attributesOfItemAtPath:[documentsPath stringByAppendingPathComponent:filePath] error:nil];
        FileInfo *dirList = [[FileInfo alloc] init];
        if(flag == YES)
        {
            dirList.fileName = [filePath lastPathComponent];
            dirList.fileUrl = fileUrl;
            dirList.fileSize =[FileTools convertFileSize:[dic objectForKey:@"NSFileSize"]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *destDateString = [dateFormatter stringFromDate:[dic objectForKey:NSFileModificationDate]];
            dirList.fileChangeTime = destDateString;
            dirList.fileType = @"folder"; //文件夹
            dirList.fileSubtype = @"folder";
            
            if([documentsPath isEqualToString:kDocument_Folder]){
                
            }
            [tableDataDic setObject:dirList forKey:[NSString stringWithFormat:@"%d", dirNum]];
            dirNum++;
            [direnu skipDescendents]; //跳过子目录
        }else{
            dirList.fileName = [filePath lastPathComponent];
            dirList.fileUrl = fileUrl;
            dirList.fileSize =[FileTools convertFileSize:[dic objectForKey:@"NSFileSize"]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *destDateString = [dateFormatter stringFromDate:[dic objectForKey:NSFileModificationDate]];
            dirList.fileChangeTime = destDateString;
            dirList.fileType = @"file";
            dirList.fileSubtype = [filePath pathExtension];
            [fileDataArray addObject:dirList];
        }
    }
    for (int i =0; i<[fileDataArray count]; i++) {
        if (dirNum==0) {
            [tableDataDic setObject:fileDataArray[i] forKey:[NSString stringWithFormat:@"%d", dirNum]];
            dirNum++;
        }else{
            [tableDataDic setObject:fileDataArray[i] forKey:[NSString stringWithFormat:@"%d", dirNum++]];
        }
        
    }
    if([tableDataDic count]<=0){
        return nil;
    }
    return tableDataDic;
}

+ (NSMutableDictionary *)getAllFilesByType:(NSString *)path skipDescendents:(bool)skip fileExtend:(NSArray*)fileExtendArray{
    int rowNum = 0;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSMutableDictionary* _tableDataDict = [[NSMutableDictionary alloc] init];
    
    NSString* documentsPath = path;
    NSString* filePath = documentsPath;
    NSDirectoryEnumerator *direnu = [fm enumeratorAtPath:documentsPath];
    BOOL flag;
    if (_tableDataDict != nil) {
        [_tableDataDict removeAllObjects];
        
    }
    while((filePath = [direnu nextObject])!=nil)
    {
        NSString *fileUrl = [documentsPath stringByAppendingPathComponent:filePath];
        [fm fileExistsAtPath:fileUrl isDirectory:&flag];
        if([filePath length]>=9)
        {
            NSString *extendFileName = [filePath substringFromIndex:[filePath length]-9];
            if ([extendFileName isEqualToString:@".DS_Store"]) { //如果文件扩展名等于.DS_Store不加入文件列表
                continue;
            }
        }
        if(!flag){//如果不是文件夹就判断文件类型
            for(int i=0;i<fileExtendArray.count;i++)
            {
                NSString* fileExt=[[filePath pathExtension]  lowercaseString];
                if ([fileExt isEqualToString:fileExtendArray[i]]) {
                    FileInfo *dirList = [[FileInfo alloc] init];
                    dirList.fileName = [filePath lastPathComponent];
                    dirList.fileUrl = fileUrl;
                    
                    //    dirList.fileSize = [dic objectForKey:@"NSFileSize"] ;
                    NSDictionary *dic = [fm attributesOfItemAtPath:[documentsPath stringByAppendingPathComponent:filePath] error:nil];
                    dirList.fileSize =[FileTools convertFileSize:[dic objectForKey:@"NSFileSize"]];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString *destDateString = [dateFormatter stringFromDate:[dic objectForKey:NSFileModificationDate]];
                    dirList.fileChangeTime = destDateString;
                    dateFormatter = nil;
                    
                    dirList.fileType = @"file";
                    dirList.fileSubtype = [filePath pathExtension];
                    [_tableDataDict setObject:dirList forKey:[NSString stringWithFormat:@"%d", rowNum]];
                    rowNum++;
                }
            }
        }
    }
    if(rowNum==0){
        return nil;
    }
    return _tableDataDict;
}

//-(NSString *)notRounding:(float)price afterPoint:(int)position{
//    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
//    NSDecimalNumber *ouncesDecimal;
//    NSDecimalNumber *roundedOunces;
//
//    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
//    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
//    ouncesDecimal =nil ;
//    return [NSString stringWithFormat:@"%@",roundedOunces];
//}

#pragma mark -
#pragma mark getAllDirByPath 根据路径获取当前目录下的所有目录
+ (NSMutableDictionary *)getAllDirByPath:(NSString *)path{
    int rowNum=0;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSMutableDictionary* _tableDataDict = [[NSMutableDictionary alloc] init];
    NSString* documentsPath = path;
    NSString* filePath = documentsPath;
    NSDirectoryEnumerator *direnu = [fm enumeratorAtPath:documentsPath];
    BOOL flag;
    if (_tableDataDict != nil) {
        [_tableDataDict removeAllObjects];
        
    }
    while((filePath = [direnu nextObject])!=nil)
    {
        NSString *fileUrl = [documentsPath stringByAppendingPathComponent:filePath];
        [fm fileExistsAtPath:fileUrl isDirectory:&flag];
        if([filePath length]>=9)
        {
            NSString *extendFileName = [filePath substringFromIndex:[filePath length]-9];
            if ([extendFileName isEqualToString:@".DS_Store"]) { //如果文件扩展名等于.DS_Store不加入文件列表
                continue;
            }
        }
        NSDictionary *dic = [fm attributesOfItemAtPath:[documentsPath stringByAppendingPathComponent:filePath] error:nil];
        FileInfo *dirList = [[FileInfo alloc] init];
        if(flag == YES) //只获取文件夹
        {
            dirList.fileName = [filePath lastPathComponent];
            dirList.fileUrl = fileUrl;
            dirList.fileSize =[FileTools convertFileSize:[dic objectForKey:@"NSFileSize"]];
            dirList.fileChangeTime = [dic objectForKey:@"fileChangeTime"];
            dirList.fileType = @"folder"; //文件夹
            dirList.fileSubtype = @"folder";
            [_tableDataDict setObject:dirList forKey:[NSString stringWithFormat:@"%d", rowNum]];
            rowNum++;
            [direnu skipDescendents]; //跳过子目录
            
        }
    }
    if(rowNum==0){
        return nil;
    }
    return _tableDataDict;
}
#pragma mark -
#pragma mark getAudioDataInfoFromFileURL 根据路径获取音频文件的相关数据
+ (NSDictionary *)getAudioDataInfoFromFileURL:(NSURL *)fileURL
{
    // 创建字典
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 创建信号量(将异步变成同步)
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    [asset loadValuesAsynchronouslyForKeys:@[@"commonMetadata"]
                         completionHandler:^{
                             // 发送信号量
                             dispatch_semaphore_signal(semaphore);
                         }];
    
    // 无限等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    // 获取数据
    NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
    for (AVMetadataItem *item in artworks)
    {
        if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3])
        {
            UIImage  *image;
            if([(id)item.value isKindOfClass:[NSMutableDictionary class]])
            {
                NSMutableDictionary *dict = [item.value copyWithZone:nil];
                image = [UIImage imageWithData:[dict objectForKey:@"data"]];
            }else{
                image = [UIImage imageWithData:(NSData*)item.value];
            }
            // 获取图片
            [dic setObject:image forKey:@"Artwork"];
        }
        if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
        {
            // 获取图片
            UIImage *image = [UIImage imageWithData:[item.value copyWithZone:nil]];
            [dic setObject:image forKey:@"Artwork"];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dic];
}
+ (int)deleteFilesByUrl:(NSDictionary*)fileUrlsDic
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    for (NSString *fileUrl in [fileUrlsDic allKeys]) {
        BOOL bRet = [fileMgr fileExistsAtPath:fileUrl];
        if (bRet) {
            [fileMgr removeItemAtPath:fileUrl error:&err];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
        }
    }
    if (!err) {
        return 0;
    }
    return -1;
}

+ (int)deleteFileByUrl:(NSString*)fileUrl
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    BOOL bRet = [fileMgr fileExistsAtPath:fileUrl];
    if (bRet) {
        [fileMgr removeItemAtPath:fileUrl error:&err];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
        [alert show];
        return -1;
    }
    if (!err) {
        return 0;
    }
    return -1;
}


+ (int)moveFileByUrl:(NSString*)fileUrl toPath: (NSString*)destinationUrl
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    BOOL bRet = [fileMgr fileExistsAtPath:fileUrl];
    if (bRet) {
        
        if([fileMgr fileExistsAtPath:destinationUrl]){
            [FileTools deleteFileByUrl:destinationUrl];
        }
        
        if ([fileMgr moveItemAtPath:fileUrl toPath:destinationUrl error:&err] != YES){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[err localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
            NSLog(@"Unable to move file: %@", [err localizedDescription]);
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
        [alert show];
        return -1;
    }
    if (!err) {
        return 0;
    }
    return -1;
}

//+ (int) copyFileByUrl:(NSString*)fileUrl toPath: (NSString*)destinationUrl
//{
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    NSError *err;
//    BOOL bRet = [fileMgr fileExistsAtPath:fileUrl];
//    if (bRet) {
//        if ([fileMgr copyItemAtPath:fileUrl toPath:destinationUrl error:&err] != YES){
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[err localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
//            [alert show];
//            NSLog(@"Unable to move file: %@", [err localizedDescription]);
//        }
//    }else{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
//        [alert show];
//        return -1;
//    }
//    if (!err) {
//        return 0;
//    }
//    return -1;
//}


+ (int) saveFileFromAsset:(ALAsset *)cellAsset toPath: (NSString*)destinationUrl
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    NSUInteger byteArraySize = (NSUInteger)cellAsset.defaultRepresentation.size;
    NSMutableData* rawData = [[NSMutableData alloc]initWithCapacity:byteArraySize];
    void* bufferPointer = [rawData mutableBytes];
    NSError* error=nil;
    [cellAsset.defaultRepresentation getBytes:bufferPointer fromOffset:0 length:byteArraySize error:&error];
    if (error)
        NSLog(@"%@",error);
    rawData = [NSMutableData dataWithBytes:bufferPointer length:byteArraySize];
    
    BOOL bRet = [fileMgr fileExistsAtPath:destinationUrl];
    if (!bRet) {
        if ([rawData writeToFile:destinationUrl atomically:YES] != YES){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[err localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
            NSLog(@"Unable to write file: %@", [err localizedDescription]);
        }
    }else{
        [fileMgr removeItemAtPath:destinationUrl error:nil];
        if ([rawData writeToFile:destinationUrl atomically:YES] != YES){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[err localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
            NSLog(@"Unable to write file: %@", [err localizedDescription]);
        }
    }
    if (!err) {
        return 0;
    }
    return -1;
}

+ (NSString*)getUserDataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    return documentsDirectory;
}


+(void) saveIPInPlist:(NSString *) textFieldIp{
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *ipListPath = [documentsDirectory stringByAppendingPathComponent:@"IpInfo.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:ipListPath];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc]init];
    }
    NSMutableArray *oldAdressArray = [dictionary objectForKey:@"IpInfo"];
    if (!oldAdressArray) {
        oldAdressArray =[[NSMutableArray alloc]init];
    }
    
    [dictionary removeObjectForKey:@"IpInfo"];
    //去重
    __block BOOL isContain = NO;
    __block NSInteger index = 0;
    __block NSString *ipKey ;
    [oldAdressArray enumerateObjectsUsingBlock:^(NSDictionary *desDictionary, NSUInteger idx, BOOL *stop) {
        if ( [[desDictionary objectForKey:@"ipAddress"] compare:textFieldIp options:NSCaseInsensitiveSearch] == NO) {
            isContain = YES;
            index  = idx;
            ipKey = [desDictionary objectForKey:@"ipKey"];
        }
    }];
    if (isContain) {
        [oldAdressArray removeObjectAtIndex:index];
    }else{
        ipKey =[NSString stringWithFormat: @"%zi",oldAdressArray.count] ;
    }
    
    [oldAdressArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:ipKey,@"ipKey",textFieldIp,@"ipAddress", nil] atIndex:0];
    [dictionary setObject:oldAdressArray forKey:@"IpInfo"];
    int result = [dictionary writeToFile:ipListPath atomically:YES];
    NSLog(@"result===%d",result);
}
+(void) removeUserFromPliset{
    
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *ipListPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:ipListPath];
    NSMutableArray *oldAdressArr  =  [dictionary objectForKey:@"UserInfo"];
    [dictionary removeObjectForKey:@"UserInfo"];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc]init];
    }
    if(!oldAdressArr){
        oldAdressArr = [[NSMutableArray alloc]init];
    }
    [oldAdressArr removeAllObjects];
    [dictionary setObject:oldAdressArr forKey:@"UserInfo"];
    [dictionary writeToFile:ipListPath atomically:YES];
    
}

+ (void) saveUserInPlist: (NSString *) userName passWord:(NSString *)passWord isAutoLogin:(BOOL *)isAutoLogin{
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *userListPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:userListPath];
    NSMutableArray *oldAdressArr  =  [dictionary objectForKey:@"UserInfo"];
    [dictionary removeObjectForKey:@"UserInfo"];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc]init];
    }
    if(!oldAdressArr){
        oldAdressArr = [[NSMutableArray alloc]init];
    }
    //去重
    __block BOOL isContain = NO;
    __block NSInteger index = 0;
    __block NSString *userKey ;
    [oldAdressArr enumerateObjectsUsingBlock:^(NSDictionary *desDictionary, NSUInteger idx, BOOL *stop) {
        if ([[desDictionary objectForKey:@"userName"] compare:userName options:NSCaseInsensitiveSearch] == NO) {
            isContain = YES;
            index  = idx;
            userKey = [desDictionary objectForKey:@"userKey"];
        }
    }];
    if (isContain) {
        [oldAdressArr removeObjectAtIndex:index];
        ;
    }else{
        userKey =[NSString stringWithFormat: @"%zi",oldAdressArr.count] ;
    }
    [oldAdressArr removeAllObjects];
    [oldAdressArr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:userKey,@"userKey",userName,@"userName",passWord,@"userPassword",[NSString stringWithFormat:@"%@",isAutoLogin?@"YES":@"NO"],@"isAutoLogin", nil] atIndex:0];
    [dictionary setObject:oldAdressArr forKey:@"UserInfo"];
    [dictionary writeToFile:userListPath atomically:YES];
}

+(long long)getFileSize:(NSString*)fileNamePath{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary *dic = [fm attributesOfItemAtPath:fileNamePath error:nil];
    long long fileSize = [[dic objectForKey:@"NSFileSize"] longLongValue];
    if (fileSize>=0) {
        NSLog(@"getFileSize===========%lld",fileSize);
        return fileSize;
    }
    return 0;
}

+ (NSArray *)getAllFilesUrl:(NSString *)path{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSMutableArray* fileDataArray = [[NSMutableArray alloc] init];
    NSString* documentsPath = path;
    
    NSString* filePath = documentsPath;
    NSDirectoryEnumerator *direnu = [fm enumeratorAtPath:documentsPath];
    BOOL flag=YES;
    while((filePath = [direnu nextObject])!=nil)
    {
        NSString *fileUrl = [documentsPath stringByAppendingPathComponent:filePath];
        [fm fileExistsAtPath:fileUrl isDirectory:&flag];
        NSDictionary *dic = [fm attributesOfItemAtPath:[documentsPath stringByAppendingPathComponent:filePath] error:nil];
        FileInfo *dirList = [[FileInfo alloc] init];
        if(!flag)
        {
            dirList.fileName = [filePath lastPathComponent];
            dirList.fileUrl = fileUrl;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *destDateString = [dateFormatter stringFromDate:[dic objectForKey:NSFileModificationDate]];
            dirList.fileChangeTime = destDateString;
            dirList.fileType = @"file";
            dirList.fileSubtype = [filePath pathExtension];
            [fileDataArray addObject:dirList.fileUrl];
        }
    }
    return fileDataArray;
}

+ (NSArray *)getAllDirs:(NSString *)path{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *tempDirArray = [fm subpathsOfDirectoryAtPath:path error:nil];
    NSMutableArray *subDirArray =[[NSMutableArray alloc]init];
    BOOL isFolder = NO;
    for (int i=0; i<tempDirArray.count; i++) {
        NSString * fileUrl = [path stringByAppendingPathComponent:tempDirArray[i]];
        [fm fileExistsAtPath:fileUrl isDirectory:&isFolder];
        if(isFolder){
            [subDirArray addObject:tempDirArray[i]];
        }
        isFolder = NO;
    }
    return subDirArray;
}

+(NSString *)convertFileSize:(NSString *) byte{
    
    NSString *returnStr;
    if([byte intValue]>=(1024*1024*1024)){
        returnStr = [NSString stringWithFormat:@"%.1fG",[byte floatValue]/(1024*1024*1024)] ;
    }
    else if([byte intValue]<(1024*1024*1024)
            && [byte intValue]>=(1024*1024)){
        returnStr = [NSString stringWithFormat:@"%.1fM",[byte floatValue]/(1024*1024)] ;
    }
    else if([byte intValue] <(1024*1024) &&
            [byte intValue] >= (1024)){
        returnStr = [NSString stringWithFormat:@"%.1fK",[byte floatValue]/(1024)] ;
    }
    else if([byte intValue] <(1024) &&
            [byte intValue] >= (0)){
        returnStr = [NSString stringWithFormat:@"%.1fB",[byte floatValue]] ;
    }
    
    return returnStr;
}

- (void) moveAssets:(NSDictionary *)paramsDic
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *targetPath;
    NSMutableDictionary *selectedItemsDic;
    if([[paramsDic allKeys]containsObject:@"targetPath"]){
        targetPath = [paramsDic objectForKey:@"targetPath"];
    }
    if([[paramsDic allKeys]containsObject:@"selectedItemsDic"]){
        selectedItemsDic = [paramsDic objectForKey:@"selectedItemsDic"];
    }
    for (NSString *filePath in [selectedItemsDic allKeys])
    {
        ALAsset *asset = [selectedItemsDic objectForKey:filePath];
        NSUInteger byteArraySize = (NSUInteger)asset.defaultRepresentation.size;
        NSMutableData* rawData = [[NSMutableData alloc]initWithCapacity:byteArraySize];
        void* bufferPointer = [rawData mutableBytes];
        NSError* error=nil;
        [asset.defaultRepresentation getBytes:bufferPointer fromOffset:0 length:byteArraySize error:&error];
        if (error)
            NSLog(@"%@",error);
        rawData = [NSMutableData dataWithBytes:bufferPointer length:byteArraySize];
        NSString *fileName = [filePath lastPathComponent];
        NSString *destinationUrl =[targetPath stringByAppendingPathComponent:fileName];
        BOOL bRet = [fileMgr fileExistsAtPath:destinationUrl];
        if (!bRet) {
            [rawData writeToFile:destinationUrl atomically:YES];
        }else{
            [fileMgr removeItemAtPath:destinationUrl error:nil];
            [rawData writeToFile:destinationUrl atomically:YES];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"移动成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
        [alert show];
    });
}



+(UIImage*)getVideoDuartionAndThumb:(NSString *)videoURL
{
    
    KxMovieDecoderVer2 *_decoder = [[KxMovieDecoderVer2 alloc] init];
    
    [_decoder openFile:videoURL error:nil];
    NSArray *ar =  [_decoder decodeFrames:1.0f];
    KxMovieFrameVer2 *frame;
    
    for (KxMovieFrameVer2 *frames in ar)
    {
        if (frames.type == KxMovieFrameTypeVideo) {
            frame =  ar.lastObject;
            break;
        }
    }
    
    KxVideoFrameRGBVer2 *rgbFrame = (KxVideoFrameRGBVer2 *)frame;
    UIImage *imageKX = [rgbFrame asImage];
    [_decoder closeFile];
    _decoder = nil;
    
    return imageKX;
}

#pragma mark -
#pragma mark getFilesByPath 获取path目录下的所有文件，不递归
+ (NSArray *)getFilesByPath:(NSString *)path{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSMutableArray* fileDataArray = [[NSMutableArray alloc] init];
    NSArray *filesArray = [fm contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in filesArray) {
        [fileDataArray addObject:fileName];
    }
    return fileDataArray;
}
#pragma mark getDuplicateFileNames 返回指定目录下的所有重名文件名称
+(NSMutableArray*)getDuplicateFileNames:(NSString*)path fileNames:(NSArray*)fileNamesArray{
    NSArray *existFileNamesArray = [self getFilesByPath:path];
    NSMutableArray *duplicateFileNamesArray = [[NSMutableArray alloc] init];
    for (int i=0; i<fileNamesArray.count; i++) {
        for (int j=0; j<existFileNamesArray.count; j++){
            NSString * fileName = [existFileNamesArray[j] lastPathComponent];
            if ([(NSString*)fileNamesArray[i] isEqualToString:fileName]) {
                [duplicateFileNamesArray addObject:fileNamesArray[i]];
            }
        }
    }
    return duplicateFileNamesArray;
}

@end
