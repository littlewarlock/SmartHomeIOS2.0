//
//  CameraDetailViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraDetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CameraRecordHistoryViewController.h"
#import "DeviceNetworkInterface.h"
#import "KxMovieViewController.h"
#import "CameraListSetSingleViewController.h"
#import "UIButton+UIButtonExt.h"
#import "CameraRecodHistoryCanlender.h"
#import "net/if_var.h"

//#include "avformat.h"

@interface CameraDetailViewController ()
//label
@property (strong, nonatomic) IBOutlet UILabel *labelControl;
@property (strong, nonatomic) IBOutlet UILabel *lableSnapshot;
@property (strong, nonatomic) IBOutlet UILabel *labelRecord;

@property (strong, nonatomic) IBOutlet UIImageView *movieView;
@property (strong, nonatomic) IBOutlet UIButton *buttonControl;
@property (strong, nonatomic) IBOutlet UIButton *buttonSnapshot;
@property (strong, nonatomic) IBOutlet UIButton *buttonRecond;
@property (strong, nonatomic) IBOutlet UIButton *buttonHistory;
@property (strong, nonatomic) IBOutlet UIButton *buttonControlUp;
@property (strong, nonatomic) IBOutlet UIButton *buttonControlDown;
@property (strong, nonatomic) IBOutlet UIButton *buttonControlLeft;
@property (strong, nonatomic) IBOutlet UIButton *buttonControlRight;
@property (strong, nonatomic) IBOutlet UIButton *buttonControlBack;

@property (strong,nonatomic) UIImageView *imageViewRecord;
@property (strong,nonatomic) NSString *ptz;
@property (strong,nonatomic) NSString *monitoring;
@property (strong,nonatomic) NSString *recording;
@property (strong,nonatomic) NSString *mode;
@property (strong,nonatomic) UIImageView *imageViewModeRecord;

@property UIView *toolBarView;
@property (strong,nonatomic) UIButton *buttonFullScreen;
@property (strong,nonatomic) UIButton *buttonSetting;

//1111
@property BOOL isFullScreen;
@property BOOL isRecord;
@property BOOL isControl;
@property BOOL canControl;
@property (strong,nonatomic) UIButton *buttonControlFullScreen;
@property (strong,nonatomic) UIButton *buttonSnapshotFullScreen;
@property (strong,nonatomic) UIButton *buttonRecordFullScreen;
@property (strong,nonatomic) UIView *topBarViewFullScreen;
@property (strong,nonatomic) UILabel *labelNameFullScreen;
@property (strong,nonatomic) UIButton *buttonLeftControlFullScreen;
@property (strong,nonatomic) UIButton *buttonRightControlFullScreen;
@property (strong,nonatomic) UIButton *buttonUpControlFullScreen;
@property (strong,nonatomic) UIButton *buttonDownControlFullScreen;
//1112
typedef NS_ENUM(NSUInteger, cameraControlDirection) {
    cameraControlDirectionLeft,
    cameraControlDirectionRight,
    cameraControlDirectionUp,
    cameraControlDirectionDown,
    cameraControlDirectionNull,
    cameraControlDirectionStop
};

@property (strong,nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign,nonatomic) cameraControlDirection cameraControlDirection;

//1124
@property (strong,nonatomic) UILabel *labelForDownloadSpeed;
@property (strong,nonatomic) UILabel *labelForReceivedData;
@property (assign,nonatomic) CGFloat downloadSpeedForDisplay;
@property (assign,nonatomic) CGFloat receivedDataForDispaly;
@property (assign,nonatomic) NSInteger savedReceivedData;
@property (assign,nonatomic) NSInteger originalReceivedData;
//1231
@property KxMovieViewController *kxvc;

@property NSTimer *timeTest;

@end

@implementation CameraDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //
    // 2016 01 14 start
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rtspPauseToPlay) name:@"CameraDetailGoOnPlay" object:nil];
    // 2015 01 14 end
    //
// 2015 1111
    self.isFullScreen = NO;
    self.isControl = NO;
    
//    self.navigationItem.title = @"摄像头详细";
    self.navigationItem.title = self.deviceName;
    NSLog(@"ip======%@",self.deviceID);

    //hgc 2015 11 02 history转移
    self.buttonHistory.hidden = YES;
    
    //摄像头设置页 navigation右按钮
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"历史"
                                style:UIBarButtonItemStylePlain
                                target:self
                                 action:@selector(recordHistory:)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
//    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"history-bj"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    //2015 12 24 add
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    //2015 12 24 end
    
    //摄像头设置页 navigatison Left按钮
// 2015 11 04 hgc 左侧按钮使用系统自带样式 start
//    UIBarButtonItem *leftBTN = [[UIBarButtonItem alloc]
//                                initWithImage:[UIImage imageNamed:@"back"]
//                                style:UIBarButtonItemStylePlain
//                                target:self
//                                action:@selector(cancelCameraDetail)];
//    self.navigationItem.leftBarButtonItem = leftBTN;
// 2015 11 04 hgc 左侧按钮使用系统自带样式 end
    
    // hgc 2015 11 02 start
//    [self.buttonControl centerImageAndTitle];
//    [self.buttonRecond centerImageAndTitle];
//    [self.buttonSnapshot centerImageAndTitle];
    //hgc 2015 11 02 end
    
    self.buttonControlBack.hidden = YES;
    self.buttonControlUp.hidden = YES;
    self.buttonControlDown.hidden = YES;
    self.buttonControlLeft.hidden = YES;
    self.buttonControlRight.hidden = YES;
    
    //data
    
//    [self getRealTimeStream];
    

    
}

- (void)cancelCameraDetail{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cameraSetting
{
    CameraListSetSingleViewController *cameraListSetSingleVC = [[CameraListSetSingleViewController alloc]initWithNibName:@"CameraListSetSingleViewController" bundle:nil];
    [self.navigationController pushViewController:cameraListSetSingleVC animated:YES];
    
    cameraListSetSingleVC.deviceID = _deviceID;
    
    NSLog(@"去往camera独立设置页 from cameraDetail");
}

//-(void)openmovie
//
//{
//    
//    MPMoviePlayerViewController *movie =
//    [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:@"rtsp://admin:888888@172.16.9.28:10554/tcp/av0_1"]];
//    
//    
////    MPMoviePlayerViewController *movie =
////    [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:@"http://tv.sohu.com/20151010/n422863561.shtml"]];
//    
//
//    
//    [movie.moviePlayer prepareToPlay];
//    
//    [self presentMoviePlayerViewControllerAnimated:movie];
//    
//    [movie.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
//    
//    [movie.view setBackgroundColor:[UIColor clearColor]];
//    
//    [movie.view setFrame:self.view.bounds];
//    
//    movie.moviePlayer.shouldAutoplay = YES;
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieFinishedCallback:)
//                                                name:MPMoviePlayerPlaybackDidFinishNotification object:movie.moviePlayer];
//    
//}
//
//-(void)movieFinishedCallback:(NSNotification*)notify{
//    
//    
//    
//    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
//    
//    
//    
//    MPMoviePlayerController* theMovie = [notify object];
//    
//    
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//     
//     
//     
//                                                  name:MPMoviePlayerPlaybackDidFinishNotification
//     
//     
//     
//                                                object:theMovie];
//    
//    
//    
//    [self dismissMoviePlayerViewControllerAnimated];
//    
//    
//    
//}


-(void)getRealTimeStream{

    [DeviceNetworkInterface realTimeCameraStreamWithDeviceId:self.deviceID withBlock:^(NSString *result, NSString *message, NSString *stream, NSString *ptz, NSString *monitoring, NSString *recording, NSString *mode, NSString *onlining, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
            NSLog(@"stream===%@",stream);
            NSLog(@"ptc===%@",ptz);
            NSLog(@"monitoring===%@",monitoring);
            NSLog(@"recording===%@",recording);
            NSLog(@"mode===%@",mode);
            NSLog(@"onlining===%@",onlining);
            
            //add 2015 10 28 hgc
            
            self.ptz = [NSString stringWithFormat:@"%@",ptz];
            self.monitoring = [NSString stringWithFormat:@"%@",monitoring];
            self.recording = [NSString stringWithFormat:@"%@",recording];
            self.mode = [NSString stringWithFormat:@"%@",mode];
            self.onlining = [NSString stringWithFormat:@"%@",onlining];
            //
            if ([self.onlining isEqualToString:@"1"]) {
                //zai xian
                [self.buttonControl setEnabled:YES];
                [self.buttonRecond setEnabled:YES];
                [self.buttonSnapshot setEnabled:YES];
                [self.kxvc.view setHidden:NO];
                self.buttonSetting.enabled = YES;
            }else {
                [self.buttonControl setEnabled:NO];
                [self.buttonRecond setEnabled:NO];
                [self.buttonSnapshot setEnabled:NO];
                [self.kxvc.view setHidden:YES];
                self.buttonSetting.enabled = NO;
                
                if ([self.isFromAlarmDetail isEqualToString:@"fromalarmdetail"]) {
                    //2016 01 08 start hgc
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 72, self.view.bounds.size.width - 16, 202)];
                    [imageView setImage:[UIImage imageNamed:@"camera_disconnect"]];
                    [self.view addSubview:imageView];
                    //2016 01 08 end hgc
                }else{
                    NSLog(@"from camera list VC");
                }
                
            }
            //
            if ([self.ptz isEqualToString:@"0"]) {
                [self.buttonControl setEnabled:NO];
                self.canControl = NO;
                NSLog(@"self.buttonControl==0");
            }else{
                self.canControl = YES;
            }
            NSLog(@"self.ptz===%@",self.ptz);
            if ([self.monitoring isEqualToString:@"0"]) {
                
//                self.buttonRecond.titleLabel.text = @"录制";
                [self.buttonRecond setTitle:@"录制" forState:UIControlStateNormal];
                self.isRecord = NO;
            }else{
//                self.buttonRecond.titleLabel.text = @"停止";
                [self.buttonRecond setTitle:@"停止" forState:UIControlStateNormal];
                self.isRecord = YES;
                //hgc 2015 11 02 贴图 start
                [self.buttonRecond setImage:[UIImage imageNamed:@"transcribe-start"] forState:UIControlStateNormal];
                [self.buttonRecond setImage:[UIImage imageNamed:@"transcribe-start-down"] forState:UIControlStateHighlighted];
                //hgc 2015 11 02 贴图 end
            }
            NSLog(@"self.buttonRecond.titleLabel.text11===%@",self.buttonRecond.titleLabel.text);
            NSLog(@"self.monitoring111===%@",self.monitoring);
            //add 2015 10 28 hgc
            
            if ([stream isEqual:[NSNull null]] || [stream isEqualToString:@""]) {
                NSLog(@"steam is null,please check interface.");
            }else{
            
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
                
//                if (self.kxvc != NULL) {
//                    [self.kxvc.view removeFromSuperview ];
//                    // 2015 12 23 hgc start
//                    [self.kxvc removeFromParentViewController];
//                    // 2015 12 23 hgc ended
//                    self.kxvc = NULL;
//                }
                
                self.kxvc = [KxMovieViewController movieViewControllerWithContentPath:stream parameters:parameters];
                
                [self addChildViewController:self.kxvc];
                self.kxvc.view.frame = CGRectMake(8, 72, self.view.bounds.size.width - 16, 202);
                [self.movieView setFrame:self.kxvc.view.frame];
                
                //2015 12 18 hgc
                NSLog(@"self.kxvc.view.frame===%f",self.kxvc.view.frame.size.width);
                NSLog(@"self.kxvc.view.frame===%f",[self.kxvc frameView].frame.size.width);
                //2015 12 18 hgc
                
                //            [self.kxvc.view setFrame:self.movieView.bounds];
                [self.view addSubview:self.kxvc.view];
                [self.movieView setHidden:YES];
                //
                //            [self.movieView addSubview:self.kxvc.view];
                [self.kxvc setHidesBottomBarWhenPushed:YES];
                [self.kxvc toolBarHidden];
                [self.kxvc setAllControlHidden];
            
                // 2015 11 02 hgc
                if (![self.monitoring isEqualToString:@"0"]){
                    if (self.imageViewRecord == NULL) {
                        self.imageViewRecord = [[UIImageView alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.width - 50, 10, 40, 20)];
                        self.imageViewRecord.image = [UIImage imageNamed:@"rec-small"];
                    }
                    [self.kxvc.view addSubview:self.imageViewRecord];
                }
                // 2015 11 02 hgc
                // 2016 01 06 hgc
                NSLog(@"self.recording==%@",self.recording);
                if (![self.recording isEqualToString:@""]){
                    if (self.imageViewModeRecord == NULL) {
                        self.imageViewModeRecord = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 37, 37)];
                    }
                    //
                    if (![self.recording isEqualToString:@"0"]) {
                        //模式录像开启
                        if ([self.mode isEqualToString:@"0"]) {
                            //在家
                            self.imageViewModeRecord.image = [UIImage imageNamed:@"at_home_camera"];
                            NSLog(@"guanlemeiyou");
                        }else if ([self.mode isEqualToString:@"1"]){
                            //外出
                            self.imageViewModeRecord.image = [UIImage imageNamed:@"go_out_camera"];
                        }else if([self.mode isEqualToString:@"2"]){
                            //睡眠
                            self.imageViewModeRecord.image = [UIImage imageNamed:@"sleep_camera"];
                        }
                    }else{
                        //模式录像关闭
                        if ([self.mode isEqualToString:@"0"]) {
                            //在家
                            self.imageViewModeRecord.image = [UIImage imageNamed:@"at_home_prohibt"];
                            NSLog(@"guanbi");
                            
                        }else if ([self.mode isEqualToString:@"1"]){
                            //外出
                            self.imageViewModeRecord.image = [UIImage imageNamed:@"go_out_prohibt"];
                        }else if([self.mode isEqualToString:@"2"]){
                            //睡眠
                            self.imageViewModeRecord.image = [UIImage imageNamed:@"sleep_prohibt"];
                        }
                    }
                    //
                    [self.kxvc.view addSubview:self.imageViewModeRecord];
                }
                // 2016 01 06 hgc
                
                //为kxvc添加一个新view
                if (self.toolBarView == NULL) {
                    NSLog(@"self.toolBarView == NUL");
//toolBarView
//                    self.toolBarView = [[UIView alloc]initWithFrame:CGRectMake(8, self.kxvc.view.frame.size.height + 68 - 50, self.kxvc.view.frame.size.width, 50)];
                    self.toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.kxvc.view.frame.size.height - 50, self.kxvc.view.frame.size.width, 50)];
                    self.toolBarView.backgroundColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:0.5];
//view add button fullscreen
//buttonFullScreen
                    self.buttonFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.toolBarView.frame.size.width - 40 , self.toolBarView.frame.size.height - 40, 30, 30)];
//                    self.buttonFullScreen.backgroundColor = [UIColor redColor];
                    [self.buttonFullScreen setImage:[UIImage imageNamed:@"full-screen"] forState:UIControlStateNormal];
                    [self.buttonFullScreen addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
//view add button setting
                    self.buttonSetting = [[UIButton alloc]initWithFrame:CGRectMake(25 , self.toolBarView.frame.size.height - 40, 30, 30)];
                    [self.buttonSetting setImage :[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
                    [self.buttonSetting addTarget:self action:@selector(cameraSetting) forControlEvents:UIControlEventTouchUpInside];
//labelForDownloadSpeed
                    self.labelForDownloadSpeed = [[UILabel alloc]initWithFrame:CGRectMake(65 , self.toolBarView.frame.size.height - 40, 70, 30)];
                    [self.labelForDownloadSpeed setText:[NSString stringWithFormat:@"%.1fK/s",self.downloadSpeedForDisplay]];
                    [self.labelForDownloadSpeed setTintColor:[UIColor whiteColor]];
                    [self.labelForDownloadSpeed setTextColor:[UIColor whiteColor]];
                    [self.labelForDownloadSpeed setTextAlignment:NSTextAlignmentRight];
//labelForReceivedData
                    self.labelForReceivedData = [[UILabel alloc]initWithFrame:CGRectMake(145 , self.toolBarView.frame.size.height - 40, 70, 30)];
                    [self.labelForReceivedData setText:[NSString stringWithFormat:@"%.1fMB",self.receivedDataForDispaly]];
                    [self.labelForReceivedData setTextColor:[UIColor whiteColor]];
                    
//addsubview
                    [self.toolBarView addSubview:self.buttonFullScreen];
//                    [self.view addSubview:self.toolBarView];
                    [self.kxvc.view addSubview:self.toolBarView];
                    [self.toolBarView addSubview:self.buttonSetting];
                    [self.toolBarView addSubview:self.labelForDownloadSpeed];
                    [self.toolBarView addSubview:self.labelForReceivedData];
                }else{
                    [self.toolBarView setHidden:NO];
                    NSLog(@"oolBarView setHidden:NO");
                    [self.toolBarView addSubview:self.buttonFullScreen];
//                    [self.view addSubview:self.toolBarView];
                    [self.kxvc.view addSubview:self.toolBarView];
                    [self.toolBarView addSubview:self.buttonSetting];
                    [self.toolBarView addSubview:self.labelForDownloadSpeed];
                    [self.toolBarView addSubview:self.labelForReceivedData];
                }
                [self.buttonFullScreen setEnabled:YES];
                
                
            }
//            self.navigationController.navigationBarHidden = YES;
////            [self.kxvc toolBarHidden];
//                        [self presentViewController:self.kxvc animated:YES completion:nil];
//            [self.navigationController pushViewController:self.kxvc animated:YES];
            //   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        else{
            NSLog(@"realTimeCameraStreamWithDeviceId error");
        }
    }];
}

-(void)fullScreen{
    NSLog(@"fullScreenfullScreen");
    NSLog(@"setfullScreen");
    if (self.isFullScreen) {
        //status bar
        self.isFullScreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = NO;
        [self.buttonSetting setHidden:NO];
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        //
        self.kxvc.view.frame = CGRectMake(8, 72, self.view.bounds.size.width - 16, 202);
        //
        self.toolBarView.frame = CGRectMake(0, self.kxvc.view.frame.size.height - 50, self.kxvc.view.frame.size.width, 50);
        self.buttonFullScreen.frame = CGRectMake(self.toolBarView.frame.size.width - 40 , self.toolBarView.frame.size.height - 40, 30, 30);
        [self.buttonFullScreen setImage:[UIImage imageNamed:@"full-screen"] forState:UIControlStateNormal];
        self.labelForDownloadSpeed.frame = CGRectMake(65 , self.toolBarView.frame.size.height - 40, 70, 30);
        [self.labelForDownloadSpeed setTextAlignment:NSTextAlignmentRight];
        self.labelForReceivedData.frame = CGRectMake(145 , self.toolBarView.frame.size.height - 40, 70, 30);
        //
        [self.buttonRecordFullScreen setHidden:YES];
        [self.buttonSnapshotFullScreen setHidden:YES];
        [self.buttonControlFullScreen setHidden:YES];
        //imageViewRecord
        self.imageViewRecord.frame = CGRectMake(self.kxvc.view.frame.size.width - 50, 10, 40, 20);
        //imageViewModeRecord
        self.imageViewModeRecord.frame = CGRectMake(10, 10, 37, 37);
        //1112 GeestureRecognizerPan
        [self.kxvc.view removeGestureRecognizer:self.panGestureRecognizer];
        //topView
        [self.topBarViewFullScreen setHidden:YES];
        //control hidden
        [self controlButtonFullScreenHidden];
        
    }else{
        //status bar
        self.isFullScreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = YES;
        [self.buttonSetting setHidden:YES];
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
        //
        self.kxvc.view.frame = self.view.frame;
        self.toolBarView.frame = CGRectMake(0, self.kxvc.view.frame.size.width - 50, self.kxvc.view.frame.size.height, 50);
        self.buttonFullScreen.frame = CGRectMake(self.toolBarView.frame.size.width - 40 , self.toolBarView.frame.size.height - 43, 35, 35);
        [self.buttonFullScreen setImage:[UIImage imageNamed:@"full-screen-fullscreen"] forState:UIControlStateNormal];
        self.labelForDownloadSpeed.frame = CGRectMake(self.toolBarView.frame.size.width - 180 , self.toolBarView.frame.size.height - 40, 70, 30);
        [self.labelForDownloadSpeed setTextAlignment:NSTextAlignmentRight];
        self.labelForReceivedData.frame = CGRectMake(self.toolBarView.frame.size.width - 180 + 80 , self.toolBarView.frame.size.height - 40, 70, 30);
        
        //buttonControlFullScreen
        self.buttonControlFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(30 , self.toolBarView.frame.size.height - 43, 35, 35)];
        [self.buttonControlFullScreen setImage:[UIImage imageNamed:@"cloud-fullscreen"] forState:UIControlStateNormal];
        [self.buttonControlFullScreen setImage:[UIImage imageNamed:@"cloud-down-fullscreen"] forState:UIControlStateHighlighted];
        [self.buttonControlFullScreen addTarget:self action:@selector(buttonControlFullScreenPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBarView addSubview:self.buttonControlFullScreen];
        if (!self.canControl) {
            //2016 01 19 hgc
            [self.buttonControlFullScreen setImage:[UIImage imageNamed:@"cloud-prohibt-fullscreen"] forState:UIControlStateNormal];
            //2016 01 19
            [self.buttonControlFullScreen setEnabled:NO];
        }
        if (self.isControl) {
            [self.buttonControlFullScreen setImage:[UIImage imageNamed:@"cloud-down-fullscreen"] forState:UIControlStateNormal];
        }
        //buttonSnapshotFullScreen
        self.buttonSnapshotFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(30 + self.buttonControlFullScreen.frame.size.width + 20, self.toolBarView.frame.size.height - 43, 35, 35)];
        [self.buttonSnapshotFullScreen setImage:[UIImage imageNamed:@"screenshot-fullscreen"] forState:UIControlStateNormal];
        [self.buttonSnapshotFullScreen setImage:[UIImage imageNamed:@"screenshot-down-fullscreen"] forState:UIControlStateHighlighted];
        [self.buttonSnapshotFullScreen addTarget:self action:@selector(buttonSnapshotPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBarView addSubview:self.buttonSnapshotFullScreen];
        //buttonRecordFullScreen
        self.buttonRecordFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.buttonSnapshotFullScreen.frame.origin.x + 35 + 20 , self.toolBarView.frame.size.height - 43, 35, 35)];
        [self.buttonRecordFullScreen setImage:[UIImage imageNamed:@"transcribe-fullscreen"] forState:UIControlStateNormal];
        [self.buttonRecordFullScreen setImage:[UIImage imageNamed:@"transcribe-down-fullscreen"] forState:UIControlStateHighlighted];
        [self.buttonRecordFullScreen addTarget:self action:@selector(buttonRecordPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBarView addSubview:self.buttonRecordFullScreen];
        if (self.isRecord) {
            [self.buttonRecordFullScreen setImage:[UIImage imageNamed:@"transcribe-down-fullscreen"] forState:UIControlStateNormal];
        }
        //imageViewRecord
        self.imageViewRecord.frame = CGRectMake(self.kxvc.view.frame.size.height - 50, 10, 40, 20);
        //imageViewModeRecord
        self.imageViewModeRecord.frame = CGRectMake(10, 10 + 40 , 37, 37);
        //1112 GeestureRecognizerPan
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlerPanGesture:)];
        if (self.isControl) {
            [self.kxvc.view addGestureRecognizer:self.panGestureRecognizer];
        }
       
        //topview
        if (self.topBarViewFullScreen == NULL) {
            self.topBarViewFullScreen = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.kxvc.view.frame.size.height, 50)];
            self.topBarViewFullScreen.backgroundColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:0.5];
            //labelNameFullScreen
            self.labelNameFullScreen = [[UILabel alloc]initWithFrame:CGRectMake(self.topBarViewFullScreen.frame.size.width/2.0f - 50, 0, 100, self.topBarViewFullScreen.frame.size.height)];
            [self.labelNameFullScreen setTextAlignment:NSTextAlignmentCenter];
            self.labelNameFullScreen.text = self.deviceName;
            [self.labelNameFullScreen setTextColor:[UIColor whiteColor]];
            NSLog(@"self.deviceName==%@",self.deviceName);
            [self.topBarViewFullScreen addSubview:self.labelNameFullScreen];
            [self.kxvc.view addSubview:self.topBarViewFullScreen];
        }else{
            [self.topBarViewFullScreen setHidden:NO];
            //test 2016 01 21
            [self.kxvc.view addSubview:self.topBarViewFullScreen];
        }

        //control
        self.buttonUpControlFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.height/2 - 18 , 23 + 50, 35, 30)];
        [self.buttonUpControlFullScreen setImage:[UIImage imageNamed:@"arrow-up-fullscreen"] forState:UIControlStateNormal];
        [self.kxvc.view addSubview:self.buttonUpControlFullScreen];
        //
        self.buttonLeftControlFullScreen =[[UIButton alloc]initWithFrame:CGRectMake(23, self.kxvc.view.frame.size.width/2 - 15, 30, 38)];
        [self.buttonLeftControlFullScreen setImage:[UIImage imageNamed:@"arrow-left-fullscreen"] forState:UIControlStateNormal];
        [self.kxvc.view addSubview:self.buttonLeftControlFullScreen];
        //
        self.buttonRightControlFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.height- 23 - 35 , self.kxvc.view.frame.size.width/2 - 15, 30, 38)];
        [self.buttonRightControlFullScreen setImage:[UIImage imageNamed:@"arrow-right-fullscreen"] forState:UIControlStateNormal];
        [self.kxvc.view addSubview:self.buttonRightControlFullScreen];
        //
        self.buttonDownControlFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.height/2 - 18 , self.kxvc.view.frame.size.width - 30 - 50 - 23, 35, 30)];
        [self.buttonDownControlFullScreen setImage:[UIImage imageNamed:@"arrow-down-fullscreen"] forState:UIControlStateNormal];
        [self.kxvc.view addSubview:self.buttonDownControlFullScreen];
        //control hidden
        [self controlButtonFullScreenHidden];
        

        //buttonFullScreen
//        self.buttonFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.toolBarView.frame.size.width - 40 , self.toolBarView.frame.size.height - 40, 30, 30)];
//        //                    self.buttonFullScreen.backgroundColor = [UIColor redColor];
//        [self.buttonFullScreen setImage:[UIImage imageNamed:@"full-screen"] forState:UIControlStateNormal];
//        [self.buttonFullScreen addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
        
        NSLog(@"self.kxvc.view.frame.size.width==%f",self.kxvc.view.frame.size.width);
        NSLog(@"self.kxvc.view.frame.size.height==%f",self.kxvc.view.frame.size.height);

    }

}

-(void)controlButtonFullScreenHidden{
    [self.buttonDownControlFullScreen setHidden:YES];
    [self.buttonLeftControlFullScreen setHidden:YES];
    [self.buttonRightControlFullScreen setHidden:YES];
    [self.buttonUpControlFullScreen setHidden:YES];
}

- (BOOL)prefersStatusBarHidden{
    if (self.isFullScreen) {
        return YES;
    }else{
        return NO;
    }
}

- (void)handlerPanGesture:(UIPanGestureRecognizer *)recognizer
{
//    NSLog(@"handlerPanGesture");
    if (recognizer.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan");
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (self.cameraControlDirection == cameraControlDirectionNull||self.cameraControlDirection ==cameraControlDirectionStop) {
            CGPoint offset = [recognizer translationInView:self.kxvc.view];
            //        NSLog(@"offset.x===%f",offset.x);
            //        NSLog(@"offset.y===%f",offset.y);
            if (fabs(offset.x) <= fabs(offset.y) && offset.y <= -20.0f) {
                NSLog(@"camera move off");
                NSLog(@"camera up");
                self.cameraControlDirection = cameraControlDirectionUp;
                //
//                [self cameraControlStopForFullScreen];
                [self cameraControlForFullScreenWithGestureDireciton:self.cameraControlDirection];
                [self.buttonUpControlFullScreen setHidden:NO];
            }else if(fabs(offset.x)<= fabs(offset.y) && offset.y >= 20.0f){
                NSLog(@"camera move off");
                NSLog(@"camera down");
                self.cameraControlDirection = cameraControlDirectionDown;
                //
//                [self cameraControlStopForFullScreen];
                [self cameraControlForFullScreenWithGestureDireciton:self.cameraControlDirection];
                [self.buttonDownControlFullScreen setHidden:NO];
            }else if(fabs(offset.y) < fabs(offset.x) && offset.x <= -20.0f){
                NSLog(@"camera move off");
                NSLog(@"camera left");
                self.cameraControlDirection = cameraControlDirectionLeft;
                //
//                [self cameraControlStopForFullScreen];
                [self cameraControlForFullScreenWithGestureDireciton:self.cameraControlDirection];
                [self.buttonLeftControlFullScreen setHidden:NO];
            }else if(fabs(offset.y)< fabs(offset.x) && offset.x >= 20.0f){
                NSLog(@"camera move off");
                NSLog(@"camera right");
                self.cameraControlDirection = cameraControlDirectionRight;
                //
//                [self cameraControlStopForFullScreen];
                [self cameraControlForFullScreenWithGestureDireciton:self.cameraControlDirection];
                [self.buttonRightControlFullScreen setHidden:NO];
            }
        }
        NSLog(@"UIGestureRecognizerStateChanged");
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.cameraControlDirection = cameraControlDirectionStop;
        [self cameraControlStopForFullScreen];
        [self controlButtonFullScreenHidden];
        NSLog(@"UIGestureRecognizerStateEnded");
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        self.cameraControlDirection = cameraControlDirectionStop;
        [self cameraControlStopForFullScreen];
        [self controlButtonFullScreenHidden];
        NSLog(@"UIGestureRecognizerStateCancelled");
    }else
    {
//        self.cameraControlDirection = cameraControlDirectionStop;
//        [self cameraControlStopForFullScreen];
        NSLog(@"something WRONG!!!");
    }
}

- (void)cameraControlForFullScreenWithGestureDireciton:(cameraControlDirection)direction {
    NSString *string;
    if (direction == cameraControlDirectionUp) {
        string = @"0";
    }else if (direction == cameraControlDirectionRight){
        string = @"1";
    }else if (direction == cameraControlDirectionLeft){
        string = @"3";
    }else if (direction == cameraControlDirectionDown){
        string = @"2";
    }else if (direction == cameraControlDirectionStop){
    
    }
    if (string) {
        [DeviceNetworkInterface cameraControlWithDirection:string withDeviceId:_deviceID withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                NSLog(@"result===%@",result);
                NSLog(@"mseeage===%@",message);
            }
            else{
                NSLog(@"cameraControlWithDirection error");
            }
        }];
    }
}

- (void)cameraControlStopForFullScreen{
    [self buttonUpPressed:nil];
}

- (void)reloadData:(id)sender{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //2015 12 31 hgc start
//    [self.navigationController setToolbarHidden:YES animated:NO];

    //2015 12 31 hgc end
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.buttonFullScreen setEnabled:NO];
    [self getRealTimeStream];
    self.cameraControlDirection = cameraControlDirectionNull;
// 2015 11 11 离线摄像头
    if ([self.onlining isEqualToString:@"1"]) {
        //zai xian
        [self.buttonControl setEnabled:YES];
        [self.buttonRecond setEnabled:YES];
        [self.buttonSnapshot setEnabled:YES];
        [self.kxvc.view setHidden:NO];
        self.buttonSetting.enabled = YES;
        
    }else {
        //li xian
        [self.buttonControl setEnabled:NO];
        [self.buttonRecond setEnabled:NO];
        [self.buttonSnapshot setEnabled:NO];
        [self.kxvc.view setHidden:YES];
        self.buttonSetting.enabled = NO;
        
        if ([self.isFromAlarmDetail isEqualToString:@"fromalarmdetail"]) {
            NSLog(@"from alarm detail VC");
        }else{
            //2016 01 08 start hgc
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 72, self.view.bounds.size.width - 16, 202)];
            [imageView setImage:[UIImage imageNamed:@"camera_disconnect"]];
            [self.view addSubview:imageView];
            //2016 01 08 end hgc
        }

    }
// 2015 11 11
    NSLog(@"view did appera--------------------------");
    
//test 1124
    self.downloadSpeedForDisplay = 0.0f;
    self.receivedDataForDispaly = 0.0f;
    self.originalReceivedData = 0;
    NSArray *array =[self getDataCounters];
    NSString *string = array[0];
    self.savedReceivedData = string.intValue;
    self.originalReceivedData = string.intValue;
    //
    self.timeTest = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(getNetWorkSpeed) userInfo:nil repeats:YES];
    [self.timeTest fire];
//    NSArray *WifiTest = [self getDataCounters];
//    NSLog(@"WifiTest===%@",WifiTest);
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if (self.kxvc != NULL) {
        [self.kxvc.view removeFromSuperview ];
        // 2015 12 23 hgc start
        [self.kxvc removeFromParentViewController];
        // 2015 12 23 hgc ended
        self.kxvc = NULL;
    }
    //
    NSLog(@"self.kxvc1212==%@",self.kxvc);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //
    if (self.isFullScreen) {
        [self fullScreen];
    }
    
    [self.timeTest invalidate];
    self.savedReceivedData = 0.0f;
    self.receivedDataForDispaly = 0.0f;
    self.originalReceivedData = 0;
    //
    NSLog(@"self.kxvc==%@",self.kxvc);
    
}

- (void)getNetWorkSpeed{
    NSLog(@"sdfsfsfsf");
    NSArray *array =[self getDataCounters];
    NSString *string = array[0];
    self.downloadSpeedForDisplay = (string.intValue - self.savedReceivedData) / 3.0f /1024.0f ;
    self.receivedDataForDispaly = (string.intValue - self.originalReceivedData) / 1024.0f / 1024.0f;
    self.savedReceivedData = string.intValue;
    //
    [self.labelForDownloadSpeed setText:[NSString stringWithFormat:@"%.1fK/s",self.downloadSpeedForDisplay]];
    [self.labelForReceivedData setText:[NSString stringWithFormat:@"%.0fMB",self.receivedDataForDispaly]];
    NSLog(@"downloadSpeedForDisplay===%.1fK/s",self.downloadSpeedForDisplay);
    NSLog(@"receivedDataForDispaly===%.1fMB",self.receivedDataForDispaly);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)recordHistory:(UIButton *)sender {
    
    //跳转到日历页面 hgc 2015 11 03
    CameraRecodHistoryCanlender *cameraRecordHistoryCanlender =
    [[CameraRecodHistoryCanlender alloc]initWithNibName:@"CameraRecodHistoryCanlender" bundle:nil];
    
    [self.navigationController pushViewController:cameraRecordHistoryCanlender animated:YES];
    
//    [self presentViewController:cameraRecordHistoryCanlender animated:YES completion:^{
//        NSLog(@"cameraRecordHistoryCanlender over");
//    }];
    
    //传入inputdate
    cameraRecordHistoryCanlender.inputDate = [NSDate date];
    cameraRecordHistoryCanlender.deviceID = _deviceID;
    NSLog(@"去往camera Canlender");
    //跳转到日历页面 hgc 2015 11 03
    
    
//    CameraRecordHistoryViewController *cameraRecordHistoryViewController =
//    [[CameraRecordHistoryViewController alloc]initWithNibName:@"CameraRecordHistoryViewController" bundle:nil];
//    [self.navigationController pushViewController:cameraRecordHistoryViewController animated:YES];
//    cameraRecordHistoryViewController.deviceID = _deviceID;
//    
//    NSLog(@"去往camera history");
    
}
- (IBAction)buttonControlPressed:(UIButton *)sender {
    
    self.buttonControl.hidden = YES;
    self.buttonSnapshot.hidden = YES;
    self.buttonRecond.hidden = YES;
    self.buttonHistory.hidden = YES;
    self.labelControl.hidden = YES;
    self.labelRecord.hidden = YES;
    self.lableSnapshot.hidden = YES;
    
    self.buttonControlBack.hidden = NO;
    self.buttonControlUp.hidden = NO;
    self.buttonControlDown.hidden = NO;
    self.buttonControlLeft.hidden = NO;
    self.buttonControlRight.hidden = NO;
    
    //1112
    self.isControl = YES;

}

- (IBAction)buttonControlBackPressed:(UIButton *)sender {
    
    [self ViewAnimation:self.buttonControl willHidden:NO];
    [self ViewAnimation:self.buttonSnapshot willHidden:NO];
    [self ViewAnimation:self.buttonRecond willHidden:NO];
//    [self ViewAnimation:self.buttonHistory willHidden:NO];
    self.labelControl.hidden = NO;
    self.labelRecord.hidden = NO;
    self.lableSnapshot.hidden = NO;

    [self ViewAnimation:self.buttonControlBack willHidden:YES];
    [self ViewAnimation:self.buttonControlUp willHidden:YES];
    [self ViewAnimation:self.buttonControlDown willHidden:YES];
    [self ViewAnimation:self.buttonControlLeft willHidden:YES];
    [self ViewAnimation:self.buttonControlRight willHidden:YES];
//    self.buttonControl.hidden = YES;
//    self.buttonSnapshot.hidden = YES;
//    self.buttonRecond.hidden = YES;
//    self.buttonHistory.hidden = YES;
//    
//    self.buttonControlBack.hidden = YES;
//    self.buttonControlUp.hidden = YES;
//    self.buttonControlDown.hidden = YES;
//    self.buttonControlLeft.hidden = YES;
//    self.buttonControlRight.hidden = YES;
    
    
    //1112
    self.isControl = NO;
}

- (IBAction)buttonUpPressing:(UIButton *)sender {
    
    NSString *string = [[NSString alloc]initWithFormat:@"%ld",(long)sender.tag];
    
    [DeviceNetworkInterface cameraControlWithDirection:string withDeviceId:_deviceID withBlock:^(NSString *result, NSString *message, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
//            NSLog(@"++++++++++++++++camera uping++++++++++++++++");
        }
        else{
            NSLog(@"cameraControlWithDirection error");
        }
    }];
}

- (IBAction)buttonUpPressed:(UIButton *)sender {
    [DeviceNetworkInterface cameraControlStopwithDeviceId:_deviceID withBlock:^(NSString *result, NSString *message, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
            NSLog(@"++++++++++++++++camera uping++++++++++++++++");
        }
        else{
            NSLog(@"cameraControlStopwithDeviceId error");
        }
    }];
}

- (IBAction)buttonRecordPressed:(UIButton *)sender {

    if (self.imageViewRecord == NULL) {
        self.imageViewRecord = [[UIImageView alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.width - 50, 10, 40, 20)];
        self.imageViewRecord.image = [UIImage imageNamed:@"rec-small"];
    }
    NSLog(@"self.buttonRecond.titleLabel.text=%@",self.buttonRecond.titleLabel.text);
    if ([self.buttonRecond.titleLabel.text isEqualToString: @"录制"]) {
        [DeviceNetworkInterface cameraRecordwithDeviceId:_deviceID withSwitchParam:@"1" withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                if ([result isEqualToString:@"success"]) {
                    NSLog(@"camera recording result===%@",result);
                    NSLog(@"camera recording mseeage===%@",message);
                    
                    //hgc 2015 11 12 start
                    self.isRecord = YES;
                    if (self.isFullScreen) {
                        self.imageViewRecord.frame = CGRectMake(self.kxvc.view.frame.size.height - 50, 10, 40, 20);
                        NSLog(@"transcribe-down-fullscreen");
                    }
                    //hgc 2015 11 12 end
                    
                    [self.buttonRecond setTitle:@"停止" forState:UIControlStateNormal];
                    
                    //test
                    NSLog(@"self.buttonRecond.titleLabel.text=%@",self.buttonRecond.titleLabel.text);
                    
                    //hgc 2015 11 02 贴图 start
                    [self.buttonRecond setImage:[UIImage imageNamed:@"transcribe-start"] forState:UIControlStateNormal];
                    [self.buttonRecond setImage:[UIImage imageNamed:@"transcribe-start-down"] forState:UIControlStateHighlighted];
                    //hgc 2015 11 02 贴图 end
                    
                    //图片
                    [self.kxvc.view addSubview:self.imageViewRecord];
                    
                    //hgc 2015 11 12 start
                    if (self.isFullScreen) {
                        NSLog(@"self.isRecord===%d",self.isRecord);
                        if (self.isRecord) {
                            [self.buttonRecordFullScreen setImage:[UIImage imageNamed:@"transcribe-down-fullscreen"] forState:UIControlStateNormal];
//                            self.imageViewRecord.frame = CGRectMake(self.kxvc.view.frame.size.height - 50, 10, 40, 20);
                        }else{
                            [self.buttonRecordFullScreen setImage:[UIImage imageNamed:@"transcribe-fullscreen"] forState:UIControlStateNormal];
                        }
                        NSLog(@"transcribe-down-fullscreen");
                    }
                    //hgc 2015 11 12 end
                    
                    }
            }
            else{
                NSLog(@"cameraRecordwithDeviceId error");
            }
         }];
    }else{
        [DeviceNetworkInterface cameraRecordwithDeviceId:_deviceID withSwitchParam:@"0" withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                if ([result isEqualToString:@"success"]) {
                    NSLog(@"camera recording stop result===%@",result);
                    NSLog(@"camera recording stop mseeage===%@",message);
                    //                self.buttonRecond.titleLabel.text = @"录制";
                    [self.buttonRecond setTitle:@"录制" forState:UIControlStateNormal];
                    self.isRecord = NO;
                    //hgc 2015 11 02 贴图 start
                    [self.buttonRecond setImage:[UIImage imageNamed:@"transcribe"] forState:UIControlStateNormal];
                    [self.buttonRecond setImage:[UIImage imageNamed:@"transcribe-down"] forState:UIControlStateHighlighted];
                    //hgc 2015 11 02 贴图 end
                    //hgc 2015 11 12 start
                    if (self.isFullScreen) {
                        NSLog(@"self.isRecord===%d",self.isRecord);
                        if (self.isRecord) {
                            [self.buttonRecordFullScreen setImage:[UIImage imageNamed:@"transcribe-down-fullscreen"] forState:UIControlStateNormal];
                            self.imageViewRecord.frame = CGRectMake(self.kxvc.view.frame.size.height - 50, 10, 40, 20);
                        }else{
                            [self.buttonRecordFullScreen setImage:[UIImage imageNamed:@"transcribe-fullscreen"] forState:UIControlStateNormal];
                        }
                        NSLog(@"transcribe-down-fullscreen");
                    }
                    //hgc 2015 11 12 end
                    //图片
                    [self.imageViewRecord removeFromSuperview];
                }
            }
            else{
                NSLog(@"cameraRecordwithDeviceId error");
            }
        }];
    }
  
}

- (IBAction)buttonSnapshotPressed:(UIButton *)sender {
    NSLog(@"buttonSnapshotPressed");
    //
    [self.buttonSnapshot setEnabled:NO];
    //
    [DeviceNetworkInterface realTimeCameraSnapshotWithDeviceId:_deviceID withBlock:^(NSString *result, NSString *message, NSString *image, NSError *error) {
        if (!error) {
            
            NSLog(@"realTimeCameraSnapshotWithDeviceId result===%@",result);
            NSLog(@"realTimeCameraSnapshotWithDeviceId mseeage===%@",message);
            NSLog(@"realTimeCameraSnapshotWithDeviceId image===%@",image);
            // 2015 10 26
            if ([result isEqualToString:@"success"]) {
                
                
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.kxvc.view.frame.size.height - 90, 150, 90)];
                imageView.image = [self getImageFromURL:image];
                //
                //2016 01 21 start
                if (self.isCurrentViewControllerVisible) {
                    [self.kxvc.view addSubview:imageView];
                    [self.buttonSnapshotFullScreen setEnabled:NO];
                }
                //2016 01 21 end
                // 1112 start
                if (self.isFullScreen) {
                    imageView.frame = CGRectMake(0, self.kxvc.view.frame.size.width - 180 - 50, 300, 180);
                }
                //1112 end
                [UIImageView animateWithDuration:2.5 animations:^{
                    imageView.alpha = 0.1;
                } completion:^(BOOL finished) {
                    [imageView removeFromSuperview];
                    //2016 01 21 start
                    [self.buttonSnapshot setEnabled:YES];
                    [self.buttonSnapshotFullScreen setEnabled:YES];
                    //2016 01 21 end
                }];
            }

        }
        else{
            NSLog(@"cameraRecordwithDeviceId error");
            //2016 01 26
            [self.buttonSnapshot setEnabled:YES];
        }
    }];
    
}

- (void)buttonControlFullScreenPressed{
    NSLog(@"buttonControlFullScreenPressed");
    if (self.isControl) {
        [self.buttonControlFullScreen setImage:[UIImage imageNamed:@"cloud-fullscreen"] forState:UIControlStateNormal];
    }else{
        [self.buttonControlFullScreen setImage:[UIImage imageNamed:@"cloud-down-fullscreen"] forState:UIControlStateNormal];
    }
    self.isControl = !self.isControl;
    if (self.isControl) {
        [self.kxvc.view addGestureRecognizer:self.panGestureRecognizer];
    }else{
        [self.kxvc.view removeGestureRecognizer:self.panGestureRecognizer];
    }
    NSLog(@"self===%d",self.isControl);
}




//自定义方法：
- (void)ViewAnimation:(UIView*)view willHidden:(BOOL)hidden {
    
    [UIView animateWithDuration:0.3 animations:^{
        [view setHidden:hidden];

    } completion:^(BOOL finished) {
        [view setHidden:hidden];
    }];
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
}
//全屏模式
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

//test
- (NSArray *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name=[[NSString alloc]init];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
//            NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
//                    NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
//                    NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
//                    NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
//                    NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
//    NSLog(@"wifi==%@",[NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent], [NSNumber numberWithInt:WiFiReceived],[NSNumber numberWithInt:WWANSent],[NSNumber numberWithInt:WWANReceived], nil]);
    
    NSInteger receive = WiFiReceived + WWANReceived;
    NSString *stringReceiveByte = [NSString stringWithFormat:@"%d",receive];
//    return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiReceived],[NSNumber numberWithInt:WWANReceived], nil];
    return [NSArray arrayWithObject:stringReceiveByte];
}

- (void)rtspPauseToPlay{
    NSLog(@"i am back");
    if (![self.kxvc playing]) {
        [self.kxvc play];
    }
    
}
//2016 01 21
- (BOOL)isCurrentViewControllerVisible
{
    return (self.isViewLoaded && self.view.window);
    
}

@end
