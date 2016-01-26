//
//  UploadFileTools.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProgressBarViewController.h"

@class UploadFileTools;

@protocol UploadFileDelegate <NSObject>

@required

- (void)uploadFileError:(UploadFileTools *)upLoad errorWhitConnection:(NSString *)error;
- (void)uploadFileFinish:(UploadFileTools *)upLoad;

@end

enum {
    kUploadBufferSize = 8000,
};

@interface UploadFileTools : NSObject <NSStreamDelegate> {
    NSString *	userName;
    NSString *	passWord;
    
    NSString *	connectPath;
    NSString *	serverPath;
    long long int serverSize;
    
    NSString *  localPath;
    NSString *	fileName;
    long long int 	localSize;
    
    NSInteger	bufferOffset;
    NSInteger	bufferLimit;
    uint8_t	_buffer[kUploadBufferSize];
    
    CFWriteStreamRef ftpStream;
    NSInputStream  *  fileStream;
    
    NSString *	strStatus;
    
    CFRunLoopRef runLoop;
    long long int	lastUpdSize; //记录上传时达到指定数时，更新进度条
    id<UploadFileDelegate> delegate;
    
}

- (uint8_t *)buffer;

- initWithLocalPath:(NSString *)localStr withServer:(NSString*)serverStr withName:(NSString*)theName withPass:(NSString*)thePass;
- initWithLocalPath:(NSString *)localStr withServer:(NSString*)serverStr;

- (void)parseLocalPath:(NSString*)localStr withServer:(NSString*)serverStr;
- (void) theWriteCallBack; 
- (void)start;
- (void)threadMain:(id)arg;
- (void)resume;
- (void)resumeRead;
- (void)stopWithStatus:(NSString *)statusString;

// - (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;

@property (nonatomic, strong) NSString * serverPath;
@property (nonatomic, strong) NSString * connectPath;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * passWord;
@property (nonatomic, strong) NSString * localPath;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, assign) CFWriteStreamRef ftpStream;
@property (nonatomic, strong) NSInputStream * fileStream;
@property (nonatomic, strong) NSString * strStatus;
@property (nonatomic, strong) NSString * taskId;


@property (nonatomic, assign) long long int   serverSize;
@property (nonatomic, assign) long long int   localSize;
@property (nonatomic, assign) NSInteger   bufferOffset;
@property (nonatomic, assign) NSInteger   bufferLimit;
@property (nonatomic, assign) long long int   lastUpdSize;

@end