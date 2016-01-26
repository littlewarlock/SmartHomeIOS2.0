//
//  FileInfo.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/8.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "FileInfo.h"

@implementation FileInfo






- (id)init
{
    self = [super init];
    if (self) {
        self.fileId =@"";
        self.fileName =@"";
        self.fileSize = @"";
        self.fileChangeTime = @"";
        self.fileType = @"";
        self.fileSubtype = @"";
        self.isShare = @"";
        self.cpath   = @"";
        self.isSelect = false;
    }
    
    return self;
}


+ (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@",       trimmedStr]];
            
            NSLog(@"result=====%@,--------trimmedStr===%@",result,trimmedStr);
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"ftp"  options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}


+ (uint64_t) getFTPStreamSize:(CFReadStreamRef)stream {
    return 0ll;
}


+ (NSString*) pathForDocument {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        NSString *userDocumentsPath = [paths objectAtIndex:0];
        // Implementation continues...
        return userDocumentsPath;
    }
    
    return nil;
}

+ (uint64_t) getFileSize:(NSString *)filePath {
  //  NSData *nameData;
   // NSString *newName;
    NSFileManager * fileManager = [NSFileManager defaultManager];
//    nameData = [filePath dataUsingEncoding:NSMacOSRomanStringEncoding];
//    if (nameData != nil) {
//        newName = [[NSString alloc] initWithData:nameData encoding:NSMacOSRomanStringEncoding];
//    }
    NSString * oriStr = [filePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary  * dict = [fileManager attributesOfItemAtPath:oriStr error:nil];
    return [dict fileSize];
}

@end