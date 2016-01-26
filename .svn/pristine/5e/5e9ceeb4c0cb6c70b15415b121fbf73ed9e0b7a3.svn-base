//
//  FDTableViewCell.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/8.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfo.h"
#import "ImageFactory.h"
//#import "KxMovieDecoderVer2.h"

#define _CHECK_BOX_BUTTON_ 5


@interface FDTableViewCell : UITableViewCell{
    FileInfo *fileinfo;
    BOOL select;
    BOOL hasUpdate;
    BOOL isSync;
    UIImageView *iconImage;
    UILabel *progressLabel;
//    KxMovieDecoderVer2      *_decoder;
}


@property (strong,nonatomic) UIButton *checkButton;
@property (nonatomic) BOOL select;
@property (strong,nonatomic) FileInfo *fileinfo;
@property (nonatomic,setter = setHasUpdate:) BOOL hasUpdate;
@property (nonatomic,setter = setisSync:) BOOL isSync;



- (id)initWithFile:(FileInfo *)file;
- (id)getCellButton;
//- (void)Selected:(BOOL)selected animated:(BOOL)animated;
- (void)setHasUpdate:(BOOL)flag;
- (void)setIsSync:(BOOL)flag;
- (void)setIcon:(BOOL)flag;
- (void)setDetailText;
//- (void)HiddenButton;


@end


