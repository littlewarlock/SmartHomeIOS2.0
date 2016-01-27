//
//  AlarmMessageDetailViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "AlarmMessageDetailViewController.h"
#import "AlarmMessagePlayViewController.h"
#import "KxMovieViewController.h"
#import "AlarmMessagePopUpViewController.h"
#import "CameraDetailViewController.h"

// 2016 01 21
#define definedAlarmType01      @"移动侦测报警"
// 2016 01 21

static NSString *AlarmMessageDetailCellIdentifier = @"AlarmMessageDetailCellIdentifier";

@interface AlarmMessageDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageSnapshot;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBarNew;
//label
@property (strong, nonatomic) IBOutlet UILabel *labelFrom;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlay;


// 2015 11 25
@property (strong, nonatomic) KxMovieViewController *kxvc;
@property (strong, nonatomic) UIButton *buttonFullScreen;
@property (strong, nonatomic) UIButton *buttonClose;
@property (strong, nonatomic) UIButton *buttonBack;
@property BOOL isFullScreen;

@end

@implementation AlarmMessageDetailViewController

//- (instancetype)init
//{
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    [self.navigationItem setTitle:@"消息详细"];
    //
    NSLog(@"detail ====== %@",self.rowData);
    //
    NSLog(@"self.recordVideoUrl===%@",self.recordVideoUrl);
    NSLog(@"self.messageID===%@",self.messageID);
    //
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"实时视频"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(gotoRealTimeStream)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
//    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"history-bj"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    //
    [self.tableView setScrollEnabled:NO];
    //
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comeFromRemoteNoti:) name:@"PUSHTOALARMDETAIL" object:nil];
    //

    
}

-(void)comeFromRemoteNoti:(NSNotification*)notification{
    NSLog(@"dsffsdfsdfsdf");
    NSObject *content = [notification object];
    NSLog(@"dsffsdfsdfsdf==%@",content);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //2016 01 12
//    [self.imageSnapshot setImage:[self getImageFromURL:self.rowData[@"snapshotUrl"]]];
//    [self.imageSnapshot setImage:[UIImage imageNamed:@"alarmBackground"]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [self getImageFromURL:self.rowData[@"snapshotUrl_L"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.isVisiable) {
                [self.imageSnapshot setImage:image];
            }
        });
        
    });
    //2016 01 12
    
    [self.labelFrom setText:[NSString stringWithFormat:@"来自%@",self.rowData[@"devname"]]];
    [self.labelTime setText:self.rowData[@"datetime"]];
    //20151203 hgc
    if ([self.rowData[@"videoUrl"] isEqualToString:@""]) {
        [self.buttonPlay setEnabled:NO];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //toolbar
    UIBarButtonItem *buttonFlexLeft = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonFlexRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonRecordPlay = [[UIBarButtonItem alloc]initWithTitle:@"播放消息录像" style:UIBarButtonItemStylePlain target:self action:@selector(buttonPlayAlarmVideoPressed:)];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self setToolbarItems:[NSArray arrayWithObjects:buttonFlexLeft,buttonRecordPlay,buttonFlexRight, nil] animated:YES];

}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //    [self.navigationController setToolbarHidden:YES animated:YES];
    NSLog(@"somehtingndgg");
    if (self.isFullScreen) {
        NSLog(@"helolololo");
        [self closeKXVC];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 40;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlarmMessageDetailCellIdentifier];
    switch (indexPath.row) {
        case 0:
//            cell.textLabel.text = @"移动监测报警";
//            cell.textLabel.text = self.rowData[@"type"];
            if ([self.rowData[@"type"]isEqualToString:@"0"]) {
                cell.textLabel.text = definedAlarmType01;
            }else{
                cell.textLabel.text = self.rowData[@"type"];
            }
            //
            [cell setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
            [cell.textLabel setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
            break;
        case 1:
            cell.textLabel.text = @"来自办公室大厅";
            cell.textLabel.text = [NSString stringWithFormat:@"来自%@",self.rowData[@"devname"]];
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            break;
        case 2:
            cell.textLabel.text = @"2015-11-18 12:00:00";
            cell.textLabel.text = self.rowData[@"datetime"];
            
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (IBAction)playVideo:(UIButton *)sender {
    
    //2015 11 25 hgc
    self.isFullScreen = NO;
    //kxvc
    //local
//    NSString *stream = @"/Users/apple2/Desktop/makeup/advertise.mp4";
//    NSString *stream = @"/Users/apple2/Desktop/hgctestmp4-00000-00030.mp4";
    //http
//        NSString *stream = @"http://172.16.9.95:82/smarthome/video/8-1video-H264-1";
    //right
    NSString *stream = self.rowData[@"videoUrl"];
    
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
    self.kxvc.view.frame = CGRectMake(8, 72, self.view.bounds.size.width - 16, 202);
    [self.view addSubview:self.kxvc.view];
    [self.kxvc toolBarHidden];
    [self.kxvc setAllControlHidden];
    [self.kxvc fullscreenMode:YES];
    [self.kxvc bottomBarAppears];
    
    //为kxvc添加一个新view
    //buttonFullScreen
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
    //buttonClose
    if (self.buttonClose == NULL) {
        self.buttonClose = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30)];
        [self.buttonClose setImage:[UIImage imageNamed:@"close-record"] forState:UIControlStateNormal];
        [self.buttonClose addTarget:self action:@selector(closeKXVC) forControlEvents:UIControlEventTouchUpInside];
        [self.kxvc.view addSubview:self.buttonClose];
    }else{
        [self.kxvc.view addSubview:self.buttonClose];
    }
    //buttonBack
    if (self.buttonBack == NULL) {
        self.buttonBack = [[UIButton alloc]initWithFrame:CGRectMake(20, 10, 10, 30)];
        [self.buttonBack setImage:[UIImage imageNamed:@"left-icon"] forState:UIControlStateNormal];
        [self.buttonBack addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
        [self.kxvc.view addSubview:self.buttonBack];
    }else{
        [self.kxvc.view addSubview:self.buttonBack];
    }
    [self.buttonBack setHidden:YES];

}

- (IBAction)buttonPlayAlarmVideoPressed:(UIBarButtonItem *)sender {
    NSLog(@"AlarmMessagePlayViewController");
    //    //跳转到日历页面 hgc 2015 11 03
    AlarmMessagePlayViewController *alarmMessagePlayViewController =
    [[AlarmMessagePlayViewController alloc]initWithNibName:@"AlarmMessagePlayViewController" bundle:nil];
    
    [self.navigationController pushViewController:alarmMessagePlayViewController animated:YES];
    alarmMessagePlayViewController.recordVideoUrl = self.messageID;
}

- (void)fullScreen
{
    NSLog(@"fullscreen");
    
    if (self.isFullScreen) {
        //status bar
        self.isFullScreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        //
//        [self.navigationController setToolbarHidden:NO animated:YES];
        self.navigationController.navigationBarHidden = NO;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        //
        self.kxvc.view.frame = CGRectMake(8, 72, self.view.bounds.size.width - 16, 202);
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30);
        //buttonBack
        self.buttonBack.hidden = YES;
    }else{
        //status bar
        self.isFullScreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController setToolbarHidden:YES animated:YES];
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
        //
        self.kxvc.view.frame = self.view.frame;
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.height - 40 ,self.kxvc.view.frame.size.width - 40, 30, 30);
        NSLog(@"self.kxvc.view.frame.size.width==%f",self.kxvc.view.frame.size.width);
        NSLog(@"self.kxvc.view.frame.size.height==%f",self.kxvc.view.frame.size.height);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.height - 40, 10, 30, 30);
        //buttonBack
        self.buttonBack.hidden = NO;
    }
}

- (void)closeKXVC
{
    NSLog(@"closeKXVC");
    if (self.isFullScreen){
        //status bar
        self.isFullScreen = NO;
        //
//1126        [self.navigationController setToolbarHidden:NO animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = NO;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        //
        self.kxvc.view.frame = CGRectMake(8, 72, self.view.bounds.size.width - 16, 202);
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30);
    }
    if (self.kxvc != NULL) {
        [self.kxvc.view removeFromSuperview ];
        [self.kxvc removeFromParentViewController];
    }
    
}
- (void)gotoRealTimeStream{
    NSLog(@"gotoRealTimeStream");

    // for test
    // 初始化本地通知对象
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    if (notification) {
//        // 设置通知的提醒时间
//        NSDate *currentDate   = [NSDate date];
//        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
//        notification.fireDate = [currentDate dateByAddingTimeInterval:5.0];
//        
//        // 设置重复间隔
//        //        notification.repeatInterval = kCFCalendarUnitDay;
//        notification.repeatInterval = 0;
//        
//        // 设置提
//        
//        // 通知提示音 使用默认的
//        notification.soundName= UILocalNotificationDefaultSoundName;
//        
//        // 设置应用程序右上角的提醒个数
//        notification.applicationIconBadgeNumber++;
//        
//        // 设定通知的userInfo，用来标识该通知
//        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
//        aUserInfo[@"kLocalNotificationID"] = @"LocalNotificationID";
//        notification.userInfo = aUserInfo;
//        
//        // 将通知添加到系统中
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
    
    
    //
    if (self.kxvc != NULL) {
        [self.kxvc.view removeFromSuperview ];
        [self.kxvc removeFromParentViewController];
    }
    
    //goto detail
    CameraDetailViewController *vc = [[CameraDetailViewController alloc]initWithNibName:@"CameraDetailViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    //
    vc.deviceID = self.rowData[@"devid"];
    vc.deviceName = self.rowData[@"devname"];
    vc.isFromAlarmDetail = @"fromalarmdetail";
    //
    
    
}

//status bar delegate
- (BOOL)prefersStatusBarHidden{
    if (self.isFullScreen) {
        return YES;
    }else{
        return NO;
    }
}
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    // hgc add debug
    //    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //    NSString *documentsDirectory=[paths objectAtIndex:0];
    //    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:@"saveFore.jpg"];
    //    NSLog(@"savedImagePath==%@",savedImagePath);
    //    [data writeToFile:savedImagePath atomically:YES];
    // hgc add
    
    result = [UIImage imageWithData:data];
    
    return result;
}

- (BOOL)isVisiable{
    return (self.isViewLoaded&&self.view.window);
}

@end
