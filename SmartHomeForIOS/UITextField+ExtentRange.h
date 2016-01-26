//
//  UITextField+ExtentRange.h
//  SmartHomeForIOS
//
//  Created by riqiao on 16/1/20.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (ExtentRange)
- (NSRange) selectedRange;
- (void) setSelectedRange:(NSRange) range;

@end
