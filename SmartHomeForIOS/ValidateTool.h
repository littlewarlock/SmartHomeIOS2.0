//
//  ValidateTool.h
//  SmartHomeForIOS
//
//  Created by apple3 on 16/1/15.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidateTool : NSObject
+(BOOL) isEqualToKeyword:(NSString*) Keyword;
+(BOOL) isInKeywordFolder:(NSString*) dir;
@end
