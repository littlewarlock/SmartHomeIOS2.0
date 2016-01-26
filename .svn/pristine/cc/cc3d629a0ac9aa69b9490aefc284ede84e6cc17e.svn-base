//
//  UploadFileTools.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "UploadFileTools.h"

#import "FileInfo.h"
#import "CFNetwork/CFFTPStream.h"
#import "RequestConstant.h"
#import "DataManager.h"



void theWriteCallBack (CFWriteStreamRef stream,
                       CFStreamEventType eventType,
                       void *clientCallBackInfo) {
    UploadFileTools * ud = (__bridge UploadFileTools*)clientCallBackInfo;
  //  ud.serverPath = [ud.serverPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    switch (eventType) {
        case kCFStreamEventOpenCompleted: {
            ud.strStatus = @"Opened connection";
            NSLog(@"connection opened for %@", ud.serverPath);
            BOOL success = (ud.serverSize > 0);
            
            // Open a stream for the file we're going to receive into.
            //将文件名utf8解码后，才可获取输入流否则，上传时为空
            if (ud.serverSize < ud.localSize){
                ud.fileStream = [NSInputStream inputStreamWithFileAtPath: [ud.localPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]];
                [ud.fileStream open];
                if (success){
                    long lsize = ud.serverSize;
                    [ud.fileStream setProperty:[NSNumber numberWithLong:lsize] forKey:NSStreamFileCurrentOffsetKey];
                    ud.strStatus = @"server file existing, appending the data";
                } else {
                    ud.strStatus = @"uploading the file from the starting point";
                }
                assert(ud.fileStream != nil);
            } else {
                ud.strStatus = @"local file size <= server file, aborting...";
                [ud stopWithStatus:@"file size not match!"];
            }
        } break;
        case kCFStreamEventCanAcceptBytes: {
            // If we don't have any data buffered, go read the next chunk of data.
            if (ud.bufferOffset == ud.bufferLimit) {
                uint8_t * buffer = ud.buffer;
                NSInteger bytesRead = [ud.fileStream read:buffer maxLength:kUploadBufferSize];
                if (bytesRead == -1) {
                    [ud stopWithStatus:@"local file read error!"];
                } else if (bytesRead == 0) {
                    [ud stopWithStatus:nil];
                } else {
                    ud.bufferOffset = 0;
                    ud.bufferLimit  = (int)bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            if (ud.bufferOffset != ud.bufferLimit) {
                NSInteger   bytesWritten;
                uint8_t		* buffer = ud.buffer;
                bytesWritten = CFWriteStreamWrite(ud.ftpStream, &(buffer[ud.bufferOffset]), (CFIndex)(ud.bufferLimit - ud.bufferOffset));
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [ud stopWithStatus:@"Network write error"];
                } else {
                    ud.bufferOffset += (int)bytesWritten;
                    ud.serverSize += (int)bytesWritten;
                }
            }
            ud.strStatus = [NSString stringWithFormat:@"sending %lld/%lld", ud.serverSize, ud.localSize];
            int progress = (int)(float)(ud.localSize-ud.lastUpdSize)/(float)ud.localSize*100;
            if(progress>=1 || ud.localSize==ud.localSize )
            {
                NSNumber* currentProgress = [NSNumber numberWithFloat: ((float)ud.serverSize/(float)ud.localSize)];
                NSMutableDictionary * progressDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:ud.taskId,@"taskId",currentProgress ,@"progress", nil];
                //在主线程刷新UI
                [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(updateProgress:) withObject:progressDic waitUntilDone:YES];
                ud.lastUpdSize = ud.serverSize;
            }

        } break;
        case kCFStreamEventErrorOccurred: {
            CFErrorRef error = CFWriteStreamCopyError(ud.ftpStream);
            CFStringRef  desc = CFErrorCopyDescription(error);
            CFStringRef reason = CFErrorCopyFailureReason(error);
            CFStringRef suggest= CFErrorCopyRecoverySuggestion(error);
            NSLog(@"write stream error %@: reason:%@, suggest:%@",
                  (__bridge NSString*)desc,
                  (__bridge NSString*)reason,
                  (__bridge NSString*)suggest);
            
            [ud stopWithStatus:@"Stream open error"];
            break;
        } break;
        default: {
            assert(NO);
        } break;
    }
}

@implementation UploadFileTools
@synthesize serverPath;
@synthesize connectPath;
@synthesize userName;
@synthesize passWord;
@synthesize localPath;
@synthesize fileName;
@synthesize ftpStream;
@synthesize fileStream;
@synthesize strStatus;
@synthesize serverSize;
@synthesize localSize;
@synthesize bufferOffset;
@synthesize bufferLimit;

- (uint8_t *) buffer {
    return self->_buffer;
}

- initWithLocalPath:(NSString *)localStr withServer:(NSString*)serverStr
           withName:(NSString*)theName withPass:(NSString*)thePass {
    self = [super init];
    if (self == nil)
        return nil;
    [self parseLocalPath:localStr withServer:serverStr];
    
    self.userName = theName;
    self.passWord = thePass;
    
    NSLog(@"userName=%@, passWord=%@", theName, thePass);
    
    self.bufferOffset = self.bufferLimit = 0;
    return self;
}

- initWithLocalPath:(NSString *)localStr withServer:(NSString*)serverStr {
    return [self initWithLocalPath:localStr withServer:serverStr withName:nil withPass:nil];
}

// assume everything is right
- (void)parseLocalPath:(NSString*)localStr withServer:(NSString*)serverStr {
    localStr = [localStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.localPath = localStr;
    
    self.serverPath = [serverStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //ftp上传必须去掉端口号
    
    NSString * requestHost = [g_sDataManager requestHost];
    NSRange range  = [requestHost rangeOfString:@":"];
    if (range.location != NSNotFound) {
        requestHost = [requestHost substringToIndex:range.location];
    }
    self.connectPath = requestHost;

    self.fileName  = [localStr lastPathComponent];
    NSString * name = [serverStr lastPathComponent];
    if ([name compare:self.fileName] != NSOrderedSame)
    {
        self.serverPath = [self.serverPath stringByAppendingPathComponent:self.fileName];
    }
    NSLog(@"localPath = %@, connectPath = %@, serverPath = %@", self.localPath, self.connectPath, self.serverPath);
    
    // get local file size
    self.localSize = (int)[FileInfo getFileSize: self.localPath];
    NSLog(@"Uploading %@ from %@ to %@", self.fileName, self.localPath, self.serverPath);
}

- (void)start {
    [NSThread detachNewThreadSelector:@selector(threadMain:) toTarget:self withObject:nil];
}

- (void)threadMain:(id)arg {
 //   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @autoreleasepool {
        runLoop = CFRunLoopGetCurrent();
        void * p = runLoop;
        NSLog(@" the current thread's loop is %p", p);
        
        [self resumeRead];
        // [self resume];
        // CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1000, NO);
        CFRunLoopRun();
        
        self.fileStream.delegate = nil;
        [self.fileStream close];
        self.fileStream = nil;
        
        NSLog(@"thread exiting...");
    }
 //   [pool release];
}

- (void)resumeRead {
    // First get and check the URL.
   // NSString * urlStr = [self.connectPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [FileInfo smartURLForString: self.connectPath ];
    BOOL success = (url != nil);
    self.serverSize = 0;
    
    if ( ! success) {
        self.strStatus = @"Invalid URL";
    } else {
        NSLog(@"url=%@", url);
        // Open a CFFTPStream for the URL.
        CFReadStreamRef fs = CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
        assert(fs != NULL);
        self.fileStream = (__bridge NSInputStream *) fs;
        
        if (self.userName != 0) {
            success = [self.fileStream setProperty:self.userName forKey:(id)kCFStreamPropertyFTPUserName];
            assert(success);
            success = [self.fileStream setProperty:self.passWord forKey:(id)kCFStreamPropertyFTPPassword];
            assert(success);
        }
        
        success = [self.fileStream setProperty:(id)kCFBooleanTrue forKey:(id)kCFStreamPropertyFTPFetchResourceInfo];
        
        self.fileStream.delegate = self;
        [self.fileStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.fileStream open];
        
        CFRelease(fs);
    }
}


- (void)resume {
    // First get and check the URL.
    NSLog(@"－－－－－－－－－－－－dddddd－－－－－－－－－－－－－");
    NSLog(self.serverPath);
    NSURL * url = [FileInfo smartURLForString: self.serverPath];
    BOOL success = (url != nil);
    
    if ( ! success) {
        self.strStatus = @"Invalid URL";
    } else {
        // Open a CFFTPStream for the URL.
        self.ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
    
                CFOptionFlags flag2 = kCFStreamEventOpenCompleted | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred;
        if (self.userName != 0) {
            success = CFWriteStreamSetProperty(self.ftpStream, kCFStreamPropertyFTPUserName, (__bridge CFTypeRef)(self.userName));
            assert(success);
            success = CFWriteStreamSetProperty(self.ftpStream, kCFStreamPropertyFTPPassword, (__bridge CFTypeRef)(self.passWord));
            assert(success);
        }
        success = CFWriteStreamSetProperty(self.ftpStream, kCFStreamPropertyFTPFileTransferOffset, (__bridge CFTypeRef)([NSNumber numberWithUnsignedLongLong: self.serverSize]));
        success = CFWriteStreamSetProperty(self.ftpStream, kCFStreamPropertyAppendToFile, kCFBooleanFalse);
        
        CFStreamClientContext context = {
            0,  (__bridge void*)self, NULL, NULL, NULL
        };
        CFOptionFlags flag = kCFStreamEventOpenCompleted | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred;
        CFWriteStreamSetClient(self.ftpStream, flag, theWriteCallBack, &context);
        
        CFWriteStreamScheduleWithRunLoop (self.ftpStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFWriteStreamOpen(self.ftpStream);
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            if (aStream == self.fileStream) {
                // get the server size from ftp
                self.serverSize = 0;
                // check server file's size
                NSNumber * cfSize = [self.fileStream propertyForKey:(id)kCFStreamPropertyFTPResourceSize];
                if (cfSize != nil) {
                    uint64_t size = [cfSize unsignedLongLongValue];
                    self.strStatus = [NSString stringWithFormat:@"Existing server size is %llu", size];
                    self.serverSize = (int)size;
                } else {
                    self.serverSize = 0;
                }
                [self.fileStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                self.fileStream.delegate = nil;
                [self.fileStream close];
                self.fileStream = nil;
                
                // OK, let's start uploading now.
                [self resume];
                return;
            }
            
            self.strStatus = @"Opened connection";
            NSLog(@"connection opened for %@", self.serverPath);
            
            // Open a stream for the file we're going to receive into.
            if (self.serverSize < self.localSize){

                self.fileStream = [NSInputStream inputStreamWithFileAtPath:self.localPath ];
                [self.fileStream open];
                assert(self.fileStream != nil);
                uint64_t lsize = self.serverSize;
                [self.fileStream setProperty:[NSNumber numberWithUnsignedLongLong:lsize] forKey:NSStreamFileCurrentOffsetKey];
                self.strStatus = [NSString stringWithFormat:@"write to file from %llu", lsize];
                
            } else {
                self.strStatus = @"local file size <= server file, aborting...";
                [self stopWithStatus:@"file size not match!"];
            }
            
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            if (aStream == self.fileStream)
                return;
            uint8_t  * buf = self.buffer;
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:buf maxLength:kUploadBufferSize];
                
                if (bytesRead == -1) {
                    [self stopWithStatus:@"File read error"];
                } else if (bytesRead == 0) {
                    [self stopWithStatus:nil];
                    return;
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  =(int) bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            if (self.bufferOffset != self.bufferLimit) {
                long   bytesWritten;
                bytesWritten = [(__bridge NSOutputStream *)self.ftpStream write:&buf[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self stopWithStatus:@"Network write error"];
                    return;
                } else {
                    self.bufferOffset += bytesWritten;
                    self.serverSize += bytesWritten;
                }
            }
            self.strStatus = [NSString stringWithFormat:@"sending %lld/%lld", self.serverSize, self.localSize];
            

        } break;
        case NSStreamEventErrorOccurred: {
            if (aStream == self.fileStream)
                [self stopWithStatus:@"Stream open error"];
            return;
        } break;
        case NSStreamEventEndEncountered: {
            if (aStream == self.fileStream)
                [self stopWithStatus:@"Upload Completed."];
            return;
        } break;
        default: {
            assert(NO);
        } break;
    }
}


- (void)stopWithStatus:(NSString *)statusString
{
    if (self.ftpStream != NULL) {
        CFWriteStreamUnscheduleFromRunLoop(self.ftpStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFWriteStreamClose(self.ftpStream);
        CFRelease(self.ftpStream);
        self.ftpStream = NULL;
    }
    if (self.fileStream != NULL) {
        [self.fileStream close];
        self.fileStream = NULL;
    }
    if (statusString != nil) {
        self.strStatus = statusString;
        [delegate uploadFileError:self errorWhitConnection:statusString];
    } else {
        self.strStatus = @"Uploading Completed.";
        [delegate uploadFileFinish:self];
    }
    CFRunLoopStop(runLoop);
}

- (void)dealloc {
//    [userName release];
//    [passWord release];
//    
//    [serverPath release];
//    [localPath release];
//    [fileName release];
//    
//    [strStatus release];
//    
//    [super dealloc];
}

@end
