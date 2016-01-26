//
//  AppCellTableViewCell.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/28.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AppTableViewCell.h"
#import "AppButton.h"
#import "AppInfo.h"
#define RMarginX 8
#define RMarginY 0
#define RStartTag 80

@implementation AppTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initButtons];
    }
    return self;
}

- (void)initButtons
{
    
    //MyLog(@"初始化按钮");
    AppButton *btn = [[AppButton alloc] init];
    btn.frame = CGRectMake( RMarginX, RMarginY, 60, RCellHeight - 2*RMarginY);
    btn.tag = RStartTag ;
    [self.contentView addSubview:btn];
    
    //    AppInfo *appInfo = appList[0];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(RMarginX+70,RMarginY,150,RCellHeight - 2*RMarginY)];
    label.tag = RStartTag+1;
    //背景颜色为红色
    //btn.backgroundColor= [UIColor redColor];
    //设置字体颜色为白色
    label.textColor = [UIColor grayColor];
    //文字居中显示
    label.textAlignment = NSTextAlignmentLeft;
    //设置字体
    //label.font=[UIFont fontWithName:@"Arial-BoldItalicMT" size:17];
    label.font=[UIFont systemFontOfSize: 17.0];
    [self.contentView addSubview:label];
    
    UIButton *arrow = [[UIButton alloc] init];
    arrow.frame = CGRectMake( [[UIScreen mainScreen] bounds].size.width -20, RMarginY , 20, RCellHeight - 2*RMarginY);
    arrow.tag = RStartTag+2 ;
    [self.contentView addSubview:arrow];
    
}

- (void)bindApps:(NSArray *)appList
{
    
    AppButton *btn = (AppButton *)[self.contentView viewWithTag:RStartTag ];
    
    AppInfo *appInfo = (AppInfo *)appList;
    btn.tag = appInfo.appKey;
    self.actionIndex =appInfo.appKey;
    UIImage *image = [UIImage imageNamed:appInfo.appIconName];
    [btn setFrame:CGRectMake(RMarginX, RMarginY + 10, image.size.width * 2.5, image.size.height * 2.5)];
    [btn setImage:[UIImage imageNamed:appInfo.appIconName] forState:UIControlStateNormal];
    //[btn setTitle:appInfo.appName forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = (UILabel *)[self.contentView viewWithTag:RStartTag +1];
    [label setText:appInfo.appName ];
    
    UIButton *arrow = (UIButton *)[self.contentView viewWithTag:RStartTag +2];
    arrow.tag = appInfo.appKey;
    [arrow setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [arrow addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark -
#pragma mark buttonTapped 按钮绑定的方法
- (void)buttonTapped:(AppButton *)sender
{
    //MyLog(@"%d", sender.tag);
    [_cellDelegate appCell:self actionWithFlag:sender.tag];
}

#pragma mark -
#pragma mark arrowAction 按钮绑定的方法
- (void)arrowAction:(UIButton *)sender
{
    //MyLog(@"%d", sender.tag);
    [_cellDelegate appCell:self actionWithFlag:sender.tag];
    
}

@end
