//
//  AppCellTableViewCell.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/28.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RCellHeight 60

@class AppTableViewCell;
@protocol AppCellDelegate <NSObject>
@optional
- (void)appCell:(AppTableViewCell *)cell actionWithFlag:(NSInteger)flag;
@end

@interface AppTableViewCell : UITableViewCell
@property (strong, nonatomic) id<AppCellDelegate> cellDelegate;
- (void)bindApps:(NSArray *)appList;
@property (nonatomic,assign) NSInteger actionIndex;
@end
