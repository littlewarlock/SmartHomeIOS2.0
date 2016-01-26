//
//  UIButton+UIButtonExt.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/24.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "UIButton+UIButtonExt.h"

@implementation UIButton (UIButtonExt)

- (void)centerImageAndTitle:(float)spacing
{
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}

- (void)centerImageAndTitle
{
    const int DEFAULT_SPACING = 6.0f;
    [self centerImageAndTitle:DEFAULT_SPACING];
}


//
//-(void)layoutSubviews {
//    [super layoutSubviews];
//    
//    // Center image
//    CGPoint center = self.imageView.center;
//    center.x = self.frame.size.width/2;
//    center.y = self.imageView.frame.size.height/2;
//    self.imageView.center = center;
//    
//    //Center text
//    CGRect newFrame = [self titleLabel].frame;
//    newFrame.origin.x = 0;
//    newFrame.origin.y = self.imageView.frame.size.height + 5;
//    newFrame.size.width = self.frame.size.width;
//    
//    self.titleLabel.frame = newFrame;
//    self.titleLabel.textAlignment = UITextAlignmentCenter;
//}

@end
