//
//  ProgressBarViewController1.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressView.h"

@interface ProgressBarViewController : UIViewController
@property (assign, nonatomic) float  uploadViewY;
@property (assign, nonatomic) float  downloadViewY;
@property (strong, nonatomic)  UIScrollView *uploadScrollView;
@property (strong, nonatomic)  UIScrollView *downloadScrollView;

@property (strong, nonatomic)  NSMutableDictionary *uploadProgressBarDic; //保存所有上传进度条的字典
@property (strong, nonatomic)  NSMutableDictionary *downloadProgressBarDic; //保存所有下载进度条的字典
@property (strong, nonatomic)  NSMutableDictionary *taskDic;//保存所有任务的字典
@property (strong, nonatomic)  NSMutableDictionary *uploadTaskDic;//保存所有上传任务的字典
@property (strong, nonatomic)  NSMutableDictionary *downloadTaskDic;
@property (assign, nonatomic)  int  showTabIndex;//0:显示上传进度条 1:显示下载进度条

@property (strong, nonatomic) IBOutlet UIButton *uploadTabBtn;
@property (strong, nonatomic) IBOutlet UIButton *downloadTabBtn;
@property (strong, nonatomic) IBOutlet UIView *leftTabLineView;
@property (strong, nonatomic) IBOutlet UIView *rightTabLineView;

/**
 *  判断是否是由“相册控制器”进入到ProgressBarViewController
 */
@property (weak, nonatomic) NSString *sourceType;
/**
 *  判断是进入到ProgressBarViewController时是“上传”还是“下载”
 */
@property (weak, nonatomic) NSString *progressType;

-(void)addProgressBarRow:(TaskInfo *)taskInfo;

-(void)updateProgress:(NSMutableDictionary*) currentProgressDic;
-(void)setPauseBtnState:(NSMutableDictionary*) btnStateDic;
-(void)setTaskStatusInfo:(NSMutableDictionary *)taskStatusDic;
-(void)setPauseBtnStateCaptionAndTaskStatus:(NSMutableDictionary *)taskStatusDic;

#pragma mark 设置progressView的TaskInfo对象
- (void)setProgressViewTaskInfo:(TaskInfo *)taskInfo;
+ (instancetype)sharedInstance;
-(IBAction)switchTabAction:(id)sender;
-(void) setTabBarStyle;
- (IBAction)clearFinishedTask:(id)sender;
- (IBAction)clearProgressBarAction:(id)sender;
@end
