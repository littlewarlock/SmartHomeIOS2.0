//
//  SwipeableCell.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/9/9.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserEditCell;
@protocol SwipeableCellDelegate <NSObject>
- (void)updateButtonAction:(UIButton *)btn;
- (void)deleteButtonAction:(UIButton *)btn;
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
- (void)closeInput:(UIControl *)view;
@end


@interface UserEditCell : UITableViewCell

@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;
- (void)openCell;
- (IBAction)closeInput:(id)sender;
- (void)prepareForReuse;

@end
