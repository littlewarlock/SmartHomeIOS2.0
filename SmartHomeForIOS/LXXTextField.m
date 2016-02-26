//
//  LXXTextField.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/2/22.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "LXXTextField.h"

@implementation LXXTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //边框宽度为1
        self.layer.borderWidth = 1;
        //边框颜色为淡灰色
        self.layer.borderColor = [[UIColor colorWithRed:222.0/255 green:222.0/255 blue:222.0/255 alpha:1.0] CGColor];

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
     if (self = [super initWithCoder:aDecoder]) {

    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor colorWithRed:222.0/255 green:222.0/255 blue:222.0/255 alpha:1.0] CGColor];
     }
    return self;
}

@end
