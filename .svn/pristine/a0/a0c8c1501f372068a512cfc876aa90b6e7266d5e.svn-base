//
//  CustomActionSheet.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/30.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomActionSheet;
@protocol CustomActionSheetDelegate<NSObject>

//点击取消的回调接口
-(void)cancleAction;
//不同按钮的回调接口
-(void) customActionSheet:(NSInteger)buttonIndex;

@end

@interface CustomActionSheet : UIView
@property(strong, nonatomic)UIView* contentView;
@property(strong, nonatomic)UIButton* cancleBtn;
@property(assign, nonatomic) id<CustomActionSheetDelegate> delegate;
+(instancetype)styleDefault;
-(void)showSheet:(UIViewController *)controller;
-(void)dismissSheet:(UIViewController *)controller;
-(void)handleSingleTap:(UITapGestureRecognizer *)sender;
-(void)setButtonState:(NSInteger)buttonIndex buttonState:(BOOL)enabled;
@end
