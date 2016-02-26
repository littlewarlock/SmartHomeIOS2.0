//
//  ProgressBarViewController1.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#define  PROGRESSHEIGHT  64
#define  TOOLBARHEIGHT   44
#define  NAVIGATIONBARHEIGHT   60
#define  MARGINTOP 0
#import "ProgressBarViewController.h"


@interface ProgressBarViewController ()
{
    UIButton* rightBtn;
    UIButton *leftBtn;
}
@end

@implementation ProgressBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"进度管理";
    UIImage* img=[UIImage imageNamed:@"back"];
    leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame =CGRectMake(200, 0, 32, 32);
    [leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    [leftBtn addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self setTabBarStyle];
}


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ProgressBarViewController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ProgressBarViewController alloc] initWithNibName:@"ProgressBarViewController" bundle:nil];
        instance.taskDic = [[NSMutableDictionary alloc] init];
        
        instance.uploadProgressBarDic = [[NSMutableDictionary alloc] init];
        instance.uploadTaskDic =[[NSMutableDictionary alloc] init];
        instance.downloadProgressBarDic = [[NSMutableDictionary alloc] init];
        instance.downloadTaskDic = [[NSMutableDictionary alloc] init];
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        //上传进度条的scrollView
        instance.uploadScrollView = [[UIScrollView alloc]init];
        instance.uploadScrollView.frame = CGRectMake(0,NAVIGATIONBARHEIGHT+TOOLBARHEIGHT, size.width, size.height-TOOLBARHEIGHT-TOOLBARHEIGHT-NAVIGATIONBARHEIGHT);
        instance.uploadScrollView.bounces = NO;
        instance.uploadScrollView.alwaysBounceVertical = NO;
        instance.uploadScrollView.showsVerticalScrollIndicator = NO;
        [instance.uploadScrollView setContentSize:CGSizeMake(instance.uploadScrollView.frame.size.width , instance.uploadScrollView.frame.size.height)];
        [instance.view addSubview:instance.uploadScrollView];
        //下载进度条的scrollView
        instance.downloadScrollView = [[UIScrollView alloc]init];
        instance.downloadScrollView.frame = CGRectMake(0,NAVIGATIONBARHEIGHT+TOOLBARHEIGHT, size.width, size.height-TOOLBARHEIGHT-TOOLBARHEIGHT-NAVIGATIONBARHEIGHT);
        
        instance.downloadScrollView.bounces = NO;
        instance.downloadScrollView.alwaysBounceVertical = NO;
        instance.downloadScrollView.showsVerticalScrollIndicator = NO;
        [instance.downloadScrollView setContentSize:CGSizeMake(instance.downloadScrollView.frame.size.width , instance.downloadScrollView.frame.size.height)];
        [instance.view addSubview:instance.downloadScrollView];
    });
    return instance;
}


-(void)addProgressBarRow:(TaskInfo *)taskInfo
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat viewWidth = size.width;
    if ([taskInfo.taskType isEqualToString:@"上传"] || [taskInfo.taskType isEqualToString:@"备份"]) {
        if (self.uploadProgressBarDic.count==0) {
            self.uploadViewY = MARGINTOP;
        }else{
            self.uploadViewY = self.uploadViewY+PROGRESSHEIGHT+MARGINTOP;
        }
    }
    else if([taskInfo.taskType isEqualToString:@"下载"]) {
        if (self.downloadProgressBarDic.count==0) {
            self.downloadViewY = MARGINTOP;
        }else{
            self.downloadViewY = self.downloadViewY+PROGRESSHEIGHT+MARGINTOP;
        }
    }
    ProgressView *progressView =(ProgressView*)[[[NSBundle mainBundle] loadNibNamed:@"ProgressView" owner:self options:nil] lastObject];
    [progressView setTaskTypeImageViewByTaskType:taskInfo.taskType];
    progressView.taskInfo = taskInfo;
    if ([taskInfo.taskType isEqualToString:@"上传"] || [taskInfo.taskType isEqualToString:@"备份"]) {
        progressView.frame = CGRectMake(0, self.uploadViewY, viewWidth, PROGRESSHEIGHT);
    }else if([taskInfo.taskType isEqualToString:@"下载"]){
        progressView.frame = CGRectMake(0, self.downloadViewY, viewWidth, PROGRESSHEIGHT);
    }
    
    progressView.progressBar.progress = 0.0f;
    progressView.progressBar.layer.masksToBounds = YES;
    progressView.progressBar.layer.cornerRadius = 2;
    progressView.taskNameLabel.text = [taskInfo.taskName lastPathComponent];
    progressView.taskNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    //  progressView.taskDetailLabel.text = taskInfo.taskType;
    if ([taskInfo.taskType isEqualToString:@"上传"] || [taskInfo.taskType isEqualToString:@"备份"]) {
        progressView.pauseBtn.hidden = YES;
    }
    progressView.percentLabel.text =@"0%";
    progressView.taskInfo = taskInfo;
    
    if([taskInfo.taskType isEqualToString:@"上传"] || [taskInfo.taskType isEqualToString:@"备份"])
    {
        [self.uploadProgressBarDic setObject:progressView forKey:taskInfo.taskId];
        [self.uploadScrollView addSubview:progressView];
        [self.uploadScrollView setContentSize:CGSizeMake(self.uploadScrollView.frame.size.width ,([self.uploadProgressBarDic count]*(PROGRESSHEIGHT+MARGINTOP)))];
        if (self.uploadScrollView.frame.size.height<self.uploadScrollView.contentSize.height) {
            self.uploadScrollView.showsVerticalScrollIndicator = YES;
        }
    }else{
        [self.downloadProgressBarDic setObject:progressView forKey:taskInfo.taskId];
        [self.downloadScrollView addSubview:progressView];
        [self.downloadScrollView setContentSize:CGSizeMake(self.downloadScrollView.frame.size.width ,([self.downloadProgressBarDic count]*(PROGRESSHEIGHT+MARGINTOP)))];
        if (self.downloadScrollView.frame.size.height<self.downloadScrollView.contentSize.height) {
            self.downloadScrollView.showsVerticalScrollIndicator = YES;
        }
    }
}

#pragma mark addProgressView 添加进度条
-(void) addProgressView: (ProgressView *) progressView{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat viewWidth = size.width;
    TaskInfo *taskInfo = progressView.taskInfo;
    if([taskInfo.taskType isEqualToString:@"上传"] || [taskInfo.taskType isEqualToString:@"备份"])
    {
        if ([self.uploadScrollView.subviews count]==0) {
            self.uploadViewY = MARGINTOP;
        }else {
            self.uploadViewY = self.uploadViewY+PROGRESSHEIGHT+MARGINTOP;
        }
        progressView.frame = CGRectMake(0, self.self.uploadViewY, viewWidth, PROGRESSHEIGHT);
        [self.uploadScrollView addSubview:progressView];
        [self.uploadScrollView setContentSize:CGSizeMake(self.uploadScrollView.frame.size.width ,([self.uploadTaskDic count]*(PROGRESSHEIGHT+MARGINTOP)))];
        if (self.uploadScrollView.frame.size.height<self.uploadScrollView.contentSize.height) {
            self.uploadScrollView.showsVerticalScrollIndicator = YES;
        }
    }else{
        if ([self.downloadScrollView.subviews count]==0) {
            self.downloadViewY = MARGINTOP;
        }else {
            self.downloadViewY = self.downloadViewY+PROGRESSHEIGHT+MARGINTOP;
        }
        [progressView setTaskTypeImageViewByTaskType:taskInfo.taskType];
        progressView.frame = CGRectMake(0, self.self.downloadViewY,viewWidth, PROGRESSHEIGHT);
        [self.downloadScrollView addSubview:progressView];
        [self.downloadScrollView setContentSize:CGSizeMake(self.downloadScrollView.frame.size.width ,([self.downloadTaskDic count]*(PROGRESSHEIGHT+MARGINTOP)))];
        if (self.downloadScrollView.frame.size.height<self.downloadScrollView.contentSize.height) {
            self.downloadScrollView.showsVerticalScrollIndicator = YES;
        }
    }
}

#pragma mark updateProgress 刷新进度条进度的方法
-(void)updateProgress:(NSMutableDictionary*) currentProgressDic
{
    ProgressView* progressView ;
    if ([[currentProgressDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [currentProgressDic objectForKey:@"taskId"];
        if ([self.uploadProgressBarDic.allKeys containsObject:taskId]) {
            progressView =[self.uploadProgressBarDic objectForKey:taskId];
        }else if([self.downloadProgressBarDic.allKeys containsObject:taskId]){
            progressView =[self.downloadProgressBarDic objectForKey:taskId];
        }
        
        if ([[currentProgressDic allKeys]containsObject:@"progress"]) {
            NSNumber * progress = [currentProgressDic objectForKey:@"progress"];
            [progressView.progressBar setProgress:[progress floatValue] animated:NO];
            float currentProgress =[progress floatValue]*100;
            progressView.percentLabel.text =[NSString stringWithFormat:@"%d%%",(int)currentProgress];
        }else{//当备份时，更新进度
            if([[currentProgressDic allKeys]containsObject:@"sendBytes"]){
                NSNumber * sendBytes = [currentProgressDic objectForKey:@"sendBytes"];
                long long  totalBytes = progressView.taskInfo.totalBytes;
                //progressView.taskInfo.transferedBytes+= [sendBytes longLongValue];
                float currentProgress =(float)progressView.taskInfo.transferedBytes/(float)totalBytes*100;
                NSLog(@"currentProgress===========================%f,transferedBytes===%lld",currentProgress,progressView.taskInfo.transferedBytes);
                [progressView.progressBar setProgress:currentProgress/100 animated:NO];
                progressView.percentLabel.text =[NSString stringWithFormat:@"%d%%",(int)currentProgress];
            }
            if ([[currentProgressDic allKeys]containsObject:@"fileName"]){
                NSString *fileName = [currentProgressDic objectForKey:@"fileName"];
                progressView.taskNameLabel.text =fileName;
                progressView.taskNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            }
            
        }
    }
}
#pragma mark setPauseBtnState 设置进度条暂停按钮的状态
-(void)setPauseBtnState:(NSMutableDictionary*) btnStateDic{
    if ([[btnStateDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [btnStateDic objectForKey:@"taskId"];
        ProgressView* progressView =[self.downloadProgressBarDic objectForKey:taskId];
        if ([[btnStateDic allKeys]containsObject:@"btnState"]) {
            NSString * btnState = [btnStateDic objectForKey:@"btnState"];
            if([btnState isEqualToString:@"enable"]){
                [progressView setPauseBtnState:YES];
            }else{
                [progressView setPauseBtnState:NO];       }
        }
    }
}

#pragma mark setTaskStatusInfo 设置当前任务的状态信息
- (void)setTaskStatusInfo:(NSMutableDictionary *)taskStatusDic{
    if ([[taskStatusDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [taskStatusDic objectForKey:@"taskId"];
        ProgressView* progressView =[self.downloadProgressBarDic objectForKey:taskId];
        if ([[taskStatusDic allKeys]containsObject:@"taskStatus"]) {
            NSString * taskStatus = [taskStatusDic objectForKey:@"taskStatus"];
            [progressView setTaskStatusInfo:taskStatus];
        }
    }
}

#pragma mark setPauseBtnStateCaptionAndTaskStatus 设置暂停按钮的状态、标题以及任务的当前状态
- (void)setPauseBtnStateCaptionAndTaskStatus:(NSMutableDictionary *)taskStatusDic{
    if ([[taskStatusDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [taskStatusDic objectForKey:@"taskId"];
        ProgressView* progressView =[self.downloadProgressBarDic objectForKey:taskId];
        NSString * taskStatusInfo;
        NSString * caption;
        BOOL enabled;
        if ([[taskStatusDic allKeys]containsObject:@"taskStatus"]) {
            taskStatusInfo= [taskStatusDic objectForKey:@"taskStatus"];
        }
        if ([[taskStatusDic allKeys]containsObject:@"btnState"]) {
            NSString * btnState = [taskStatusDic objectForKey:@"btnState"];
            if ([btnState isEqualToString:@"enable"]) {
                enabled = YES;
            }else{
                enabled = NO;
            }
        }
        if ([[taskStatusDic allKeys]containsObject:@"caption"]) {
            caption = [taskStatusDic objectForKey:@"caption"];
        }
        [progressView setPauseBtnStateCaptionAndTaskStatus:enabled caption:caption taskStatus:taskStatusInfo];
    }
}

#pragma mark returnAction 返回父页面的方法
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark clearProgressBarAction 清除所有进度条方法
- (IBAction)clearProgressBarAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定删除所有的任务吗？" delegate:self cancelButtonTitle:@"确定"  otherButtonTitles: @"取消",nil];
    [alert show];

}

#pragma mark 设置progressView的TaskInfo对象
- (void)setProgressViewTaskInfo:(TaskInfo *)taskInfo{
    if ([taskInfo.taskType isEqualToString:@"下载"]) {
        ProgressView* progressView =[self.downloadProgressBarDic objectForKey:taskInfo.taskId];
        [self.downloadTaskDic setObject:taskInfo forKey:taskInfo.taskId];
        progressView.taskInfo = taskInfo;
    }else if([taskInfo.taskType isEqualToString:@"上传"]){
        ProgressView* progressView =[self.uploadProgressBarDic objectForKey:taskInfo.taskId];
        [self.uploadTaskDic setObject:taskInfo forKey:taskInfo.taskId];
        progressView.taskInfo = taskInfo;
        
    }
    
}

#pragma mark 切换上传进度条和下载进度条
- (IBAction)switchTabAction:(id)sender{
    UIButton *btn = (UIButton*)sender;
    if(btn.tag==0){ //上传文件的进度条显示
        self.uploadScrollView.hidden = NO;
        self.downloadScrollView.hidden = YES;
        self.showTabIndex = 0;
    }else{//下载文件的进度条显示
        self.uploadScrollView.hidden = YES;
        self.downloadScrollView.hidden = NO;
        self.showTabIndex = 1;
    }
    [self setTabBarStyle];
}

-(void) setTabBarStyle{
    if(self.showTabIndex==0){
        [self.downloadTabBtn setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]forState:UIControlStateNormal];
        [self.uploadTabBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1.0f]forState:UIControlStateNormal];
        self.downloadScrollView.hidden = YES;
        self.uploadScrollView.hidden = NO;
        self.leftTabLineView.hidden = NO;
        self.rightTabLineView.hidden = YES;
    }else{
        [self.downloadTabBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1.0f] forState:UIControlStateNormal];
        
        [self.uploadTabBtn setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]forState:UIControlStateNormal];
        
        self.downloadScrollView.hidden = NO;
        self.uploadScrollView.hidden = YES;
        self.leftTabLineView.hidden = YES;
        self.rightTabLineView.hidden = NO;
    }
}

- (IBAction)clearFinishedTask:(id)sender {
    for (NSString *taskId in [self.downloadProgressBarDic allKeys]) {
        ProgressView* progressView =[self.downloadProgressBarDic objectForKey:taskId];
        if ([progressView.taskInfo.taskStatus isEqualToString:FINISHED]) {
            [self.downloadProgressBarDic removeObjectForKey:taskId];
            [self.downloadTaskDic removeObjectForKey:taskId];
        }
    }
    [self.downloadScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.downloadViewY = MARGINTOP;
    for (NSString *taskId in [self.downloadProgressBarDic allKeys]) {
        ProgressView* progressView =[self.downloadProgressBarDic objectForKey:taskId];
        [self addProgressView:progressView];
    }
    self.uploadViewY = MARGINTOP;
    for (NSString *taskId in [self.uploadProgressBarDic allKeys]) {
        ProgressView* progressView =[self.uploadProgressBarDic objectForKey:taskId];
        if ([progressView.taskInfo.taskStatus isEqualToString:FINISHED]) {
            [self.uploadProgressBarDic removeObjectForKey:taskId];
            [self.uploadTaskDic removeObjectForKey:taskId];
        }
    }
    [self.uploadScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSString *taskId in [self.uploadProgressBarDic allKeys]) {
        ProgressView* progressView =[self.uploadProgressBarDic objectForKey:taskId];
        [self addProgressView:progressView];
    }
}
#pragma mark -
#pragma mark alertView的委托方法
-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self.uploadScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.downloadScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.uploadTaskDic removeAllObjects];
        [self.downloadTaskDic removeAllObjects];
        [self.uploadProgressBarDic removeAllObjects];
        [self.downloadProgressBarDic removeAllObjects];
        [[NSOperationDownloadQueue sharedInstance] cancelAllOperations];
        [[NSOperationUploadQueue sharedInstance] cancelAllOperations];
    }
}
@end
