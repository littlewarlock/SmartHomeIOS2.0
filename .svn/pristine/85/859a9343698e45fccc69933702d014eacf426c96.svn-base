//
//  ValidateTool.m
//  SmartHomeForIOS
//
//  Created by apple3 on 16/1/15.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "ValidateTool.h"
#import "KeyWordConstant.h"

@implementation ValidateTool


+(BOOL) isEqualToKeyword:(NSString*) Keyword{
    
    if(
        [Keyword isEqualToString:SHARE_FOLDER]  ||
        [Keyword isEqualToString:USB_FOLDER]    ||
        [Keyword isEqualToString:CAMERA_FOLDER] ||
        [Keyword isEqualToString:PUBLIC_FOLDER]
       ){
        return true;
    }else{
        return false;
    }
}

+(BOOL) isInKeywordFolder:(NSString*) dir{
    if(
       [dir isEqualToString:[@"/" stringByAppendingString: SHARE_FOLDER]]  ||
       [dir isEqualToString:[@"/" stringByAppendingString: USB_FOLDER]]    ||
       [dir isEqualToString:[@"/" stringByAppendingString: CAMERA_FOLDER]] ||
       [dir isEqualToString:[@"/" stringByAppendingString: PUBLIC_FOLDER]]
       ){
        return YES;
    }else{
        
        BOOL isInChildFolder = NO;
        if([dir length]>= [[@"/" stringByAppendingString: SHARE_FOLDER] length]){                NSString *sourcefileUrl  = [@"/" stringByAppendingString: SHARE_FOLDER];
            if([dir rangeOfString:sourcefileUrl].location !=NSNotFound)
            {
                NSString *subPath = [dir componentsSeparatedByString:sourcefileUrl][1];
                NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
                NSString *firstSubPathComponent = subPathComponentArray[0];
                if([firstSubPathComponent isEqualToString:@""] ){
                    isInChildFolder = YES;
                }
            }
        }
        
        if([dir length]>= [[@"/" stringByAppendingString: USB_FOLDER] length]){                NSString *sourcefileUrl  = [@"/" stringByAppendingString: USB_FOLDER];
            if([dir rangeOfString:sourcefileUrl].location !=NSNotFound)
            {
                NSString *subPath = [dir componentsSeparatedByString:sourcefileUrl][1];
                NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
                NSString *firstSubPathComponent = subPathComponentArray[0];
                if([firstSubPathComponent isEqualToString:@""] ){
                    isInChildFolder = YES;
                }
            }
        }
        
        if([dir length]>= [[@"/" stringByAppendingString: CAMERA_FOLDER] length]){                NSString *sourcefileUrl  = [@"/" stringByAppendingString: CAMERA_FOLDER];
            if([dir rangeOfString:sourcefileUrl].location !=NSNotFound)
            {
                NSString *subPath = [dir componentsSeparatedByString:sourcefileUrl][1];
                NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
                NSString *firstSubPathComponent = subPathComponentArray[0];
                if([firstSubPathComponent isEqualToString:@""] ){
                    isInChildFolder = YES;
                }
            }
        }
        
        if([dir length]>= [[@"/" stringByAppendingString: PUBLIC_FOLDER] length]){                NSString *sourcefileUrl  = [@"/" stringByAppendingString: PUBLIC_FOLDER];
            if([dir rangeOfString:sourcefileUrl].location !=NSNotFound)
            {
                NSString *subPath = [dir componentsSeparatedByString:sourcefileUrl][1];
                NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
                NSString *firstSubPathComponent = subPathComponentArray[0];
                if([firstSubPathComponent isEqualToString:@""] ){
                    isInChildFolder = YES;
                }
            }
        }
        
        if(isInChildFolder){
            return YES;
        }else{
            return NO;
        }
    }
}

@end
