//
//  AlarmMessagePlayViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "AlarmMessagePlayViewController.h"
#import "KxMovieViewController.h"
#import "AlarmMessagePopUpViewController.h"

@interface AlarmMessagePlayViewController ()

@property (strong, nonatomic) KxMovieViewController *kxvc;
@property (strong, nonatomic) UIButton *buttonFullScreen;
@property (strong, nonatomic) UIButton *buttonClose;
@property BOOL isFullScreen;

@end

@implementation AlarmMessagePlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPushContent:) name:@"PUSHCONTENT" object:nil];
    //
    
    NSLog(@"self.recordVideoUrl===%@",self.recordVideoUrl);
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"实时视频"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(gotoRealTimeStream)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"history-bj"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
//    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isFullScreen = NO;
    //
    //kxvc
    //local
    NSString *stream = @"/Users/apple2/Desktop/VLC/H264/3-1video-H264-1";
    //http
    //    NSString *stream = @"http://172.16.9.95:82/smarthome/video/8-1video-H264-1";
    //
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    if (self.kxvc != NULL) {
        [self.kxvc.view removeFromSuperview ];
    }
    self.kxvc = [KxMovieViewController movieViewControllerWithContentPath:stream parameters:parameters];
    //    kxvc set
    //    [self presentViewController:self.kxvc animated:YES completion:nil];
    [self addChildViewController:self.kxvc];
    NSLog(@"self.view.frame===%f",self.view.frame.size.width);
    self.kxvc.view.frame = CGRectMake(8, 70, self.view.bounds.size.width - 16, 202);
    [self.view addSubview:self.kxvc.view];
    [self.kxvc toolBarHidden];
    [self.kxvc setAllControlHidden];
    [self.kxvc fullscreenMode:YES];
    [self.kxvc bottomBarAppears];
    
    //为kxvc添加一个新view
    if (self.buttonFullScreen == NULL) {
        NSLog(@"self.toolBarView == NUL");
        
        self.buttonFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30)];
        [self.buttonFullScreen addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonFullScreen setImage:[UIImage imageNamed:@"full-screen"] forState:UIControlStateNormal];
        [self.kxvc.view addSubview:self.buttonFullScreen];
        
    }else{
        NSLog(@"toolBarView setHidden:NO");
        [self.kxvc.view addSubview:self.buttonFullScreen];
    }
    //
    if (self.buttonClose == NULL) {
        self.buttonClose = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30)];
        [self.buttonClose setImage:[UIImage imageNamed:@"close-record"] forState:UIControlStateNormal];
        [self.buttonClose addTarget:self action:@selector(closeKXVC) forControlEvents:UIControlEventTouchUpInside];
        [self.kxvc.view addSubview:self.buttonClose];
    }else{
        [self.kxvc.view addSubview:self.buttonClose];
    }
}

-(void)receivedPushContent:(NSNotification*)notification{
    NSLog(@"dsffsdfsdfsdf");
    NSObject *content = [notification object];
    NSLog(@"dsffsdfsdfsdf==%@",content);
}

- (void)fullScreen
{
    NSLog(@"fullscreen");


    if (self.isFullScreen) {
        //status bar
        self.isFullScreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = NO;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        //
        self.kxvc.view.frame = CGRectMake(8, 68, self.view.bounds.size.width - 16, 202);
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30);
    }else{
        //status bar
        self.isFullScreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = YES;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
        //
        self.kxvc.view.frame = self.view.frame;
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.height - 40 ,self.kxvc.view.frame.size.width - 40, 30, 30);
        NSLog(@"self.kxvc.view.frame.size.width==%f",self.kxvc.view.frame.size.width);
        NSLog(@"self.kxvc.view.frame.size.height==%f",self.kxvc.view.frame.size.height);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.height - 40, 10, 30, 30);
    }
}

- (void)closeKXVC
{
    NSLog(@"closeKXVC");
    if (self.isFullScreen){
        //status bar
        self.isFullScreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = NO;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        //
        self.kxvc.view.frame = CGRectMake(8, 68, self.view.bounds.size.width - 16, 202);
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30);
    }
    if (self.kxvc != NULL) {
        [self.kxvc.view removeFromSuperview ];
    }
    
}
- (void)gotoRealTimeStream{
    NSLog(@"gotoRealTimeStream");
    
    //
    // 初始化本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        // 设置通知的提醒时间
        NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [currentDate dateByAddingTimeInterval:5.0];
        
        // 设置重复间隔
//        notification.repeatInterval = kCFCalendarUnitDay;
        notification.repeatInterval = 0;
        
        // 通知提示音 使用默认的
        notification.soundName= UILocalNotificationDefaultSoundName;
        
        // 设置应用程序右上角的提醒个数
        notification.applicationIconBadgeNumber++;
        
        // 设定通知的userInfo，用来标识该通知
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        aUserInfo[@"kLocalNotificationID"] = @"LocalNotificationID";
        notification.userInfo = aUserInfo;
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//status bar delegate
- (BOOL)prefersStatusBarHidden{
    if (self.isFullScreen) {
        return YES;
    }else{
        return NO;
    }
}

@end
