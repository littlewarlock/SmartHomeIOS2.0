//
//  AlbumHeaderCell.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/23.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AlbumHeaderCell.h"


@implementation AlbumHeaderCell
- (NSString *)text{
    return self.label.text;
}

- (void)setText:(NSString *)text{
    self.label.text = text;
}

- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self){
        self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.label.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
     //   self.label.backgroundColor = [UIColor blackColor];
        self.label.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.label];
        
    }
    return self;
}

@end
