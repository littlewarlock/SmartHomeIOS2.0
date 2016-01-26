//
//  AppButton.m
//  SmartHomeForIOS
//重写button按钮，显示图片和文字
//  Created by riqiao on 15/8/28.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AppButton.h"
#define RImageHeightPercent 0.7

@implementation AppButton


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * RImageHeightPercent;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = contentRect.size.height * RImageHeightPercent;
    CGFloat width = contentRect.size.width;
    CGFloat height = contentRect.size.height * (1 - RImageHeightPercent);
    
    return CGRectMake(x, y, width, height);
}

@end
