//
//  FileCopyAndMoveTools.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/24.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileCopyTools : NSOperation{
}

@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) NSString *destinationUrl;
@property (nonatomic, strong) NSString *opType;
- (id)initWithFileInfo;

@end