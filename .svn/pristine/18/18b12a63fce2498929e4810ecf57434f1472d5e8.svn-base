//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by CaoJie on 14-5-5.
//  Copyright (c) 2014年 yiban. All rights reserved.
//

#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"

@interface PlayViewController () {
    BOOL _ifOpreate;
    BOOL _played;
    UIButton *leftBtn;
    NSString *_totalTime;
    NSDateFormatter *_dateFormatter;
    UISlider*   volumeSlider;
    UIView* rectView;
    CGRect initVolumeSliderFrame;
    CGRect initRectViewFrame;
}

@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) id playbackTimeObserver;
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *videoProgress;

@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (nonatomic) BOOL fullScreenFlag;
@property (nonatomic) CGRect initPlayViewFrame;

- (IBAction)fullScreen:(id)sender;
- (IBAction)showTools:(id)sender;
- (IBAction)stateButtonTouched:(id)sender;
- (IBAction)videoSlierChangeValue:(id)sender;
- (IBAction)videoSlierChangeValueEnd:(id)sender;

@end

@implementation PlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage* img=[UIImage imageNamed:@"back"];
    leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame =CGRectMake(200, 0, 32, 32);
    [leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    [leftBtn addTarget: self action: @selector(returnBeforeWIndowAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationController.navigationBarHidden = YES;
    self.videoTitle.text = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
    _ifOpreate=YES;
    NSURL *videoUrl;
    if([self.netOrLocalFlag isEqualToString:@"0"]){//云端
         videoUrl = [NSURL URLWithString:self.filePath];
    }else{
         videoUrl = [NSURL fileURLWithPath: self.filePath];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.player = _player;
    self.stateButton.enabled = NO;
    
    self.fullScreenFlag = YES;
    self.initPlayViewFrame = self.playerView.frame;
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    CGFloat SCREEN_HEIGHT =  [UIScreen mainScreen].bounds.size.height;
    rectView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*1/4, 60,SCREEN_HEIGHT*1/2)];
    rectView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5f];
    rectView.layer.cornerRadius = 5.0f;

    [self.view addSubview:rectView];

    volumeSlider= [[UISlider alloc] initWithFrame:CGRectMake(-SCREEN_HEIGHT*1/7, SCREEN_HEIGHT*1/2, SCREEN_HEIGHT*3/8, 5)];
    volumeSlider.maximumValue=1;
    volumeSlider.minimumValue=0;
    volumeSlider.value = 0.5;
    volumeSlider.transform = CGAffineTransformMakeRotation(-90* M_PI/180);
    [volumeSlider addTarget:self action:@selector(volumeSet:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:volumeSlider];
    initVolumeSliderFrame = volumeSlider.frame;
    initRectViewFrame = rectView.frame;
    [self fullScreen:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        [weakSelf.videoSlider setValue:currentSecond animated:YES];
        NSString *timeString = [self convertTime:currentSecond];
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,_totalTime];
    }];
}

// KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            self.stateButton.enabled = YES;
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            [self customVideoSlider:duration];// 自定义UISlider外观
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerView.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)customVideoSlider:(CMTime)duration {
    self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

- (IBAction)stateButtonTouched:(id)sender {
    if (!_played) {
        [self.playerView.player play];
        [self.stateButton setImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateNormal];
    } else {
        [self.playerView.player pause];
        [self.stateButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
    }
    _played = !_played;
}

- (IBAction)videoSlierChangeValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value change:%f",slider.value);
    
    if (slider.value == 0.000000) {
        __weak typeof(self) weakSelf = self;
        [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.playerView.player play];
        }];
    }
}

- (IBAction)videoSlierChangeValueEnd:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    
    __weak typeof(self) weakSelf = self;
    [self.playerView.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        [weakSelf.playerView.player play];
        [weakSelf.stateButton setImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateNormal];
    }];
}

- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.videoSlider setValue:currentSecond animated:YES];
}


- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    
    __weak typeof(self) weakSelf = self;
    [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.videoSlider setValue:0.0 animated:YES];
                [weakSelf.stateButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
    }];
}

- (NSString *)convertTime:(CGFloat)second{
    
    NSString* timeStr = @"2000-01-01 00:00:00";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *d = [NSDate dateWithTimeInterval:second sinceDate:[formatter dateFromString:timeStr]];
//    if (second/3600 >= 1) {
//        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
//    } else {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
//    }
    NSString *showtimeNew = [[self dateFormatter] stringFromDate:d];
    return showtimeNew;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.playerView.player removeTimeObserver:self.playbackTimeObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//音量设置
-(void)volumeSet:(UISlider*)slider
{
    self.player.volume= slider.value;
}

- (IBAction)fullScreen:(id)sender {
    if (self.fullScreenFlag) {
//        [sender setImage:[UIImage imageNamed:@"pui_zoomoutbtn@2x"] forState:UIControlStateNormal];
        self.fullScreenFlag = !self.fullScreenFlag;
        self.playerView.frame = [[UIScreen mainScreen] bounds];
        [self.view bringSubviewToFront:self.view];
        //        playerLayer.videoGravity = AVLayerVideoGravityResize;//视频填充模式
        //旋转屏幕，但是只旋转当前的View
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.bounds = CGRectMake(0, 0, frame.size.height, frame.size.width);
        CGFloat SCREEN_WIDTH =  [UIScreen mainScreen].bounds.size.width;
        rectView.frame = CGRectMake(0, SCREEN_WIDTH*1/4, 80,SCREEN_WIDTH*1/2);
        volumeSlider.frame= CGRectMake(SCREEN_WIDTH*1/8, SCREEN_WIDTH*5/16, 5, SCREEN_WIDTH*3/8);
       
        [self didAfterHidden];
    } else {
        [self didAfterShow];
//        [sender setImage:[UIImage imageNamed:@"pui_zoominbtn@2x"] forState:UIControlStateNormal];
        self.fullScreenFlag = !self.fullScreenFlag;
        self.playerView.frame = self.initPlayViewFrame;
        self.playerView.frame =self.initPlayViewFrame ;
        [self.view bringSubviewToFront:self.view];
        //旋转屏幕，但是只旋转当前的View
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        self.view.transform = CGAffineTransformMakeRotation(M_PI*2);
        rectView.frame = initRectViewFrame;
        volumeSlider.frame= initVolumeSliderFrame;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.bounds = CGRectMake(0, 0, frame.size.height, frame.size.width);
        //显示导航栏
    }
}

- (IBAction)showTools:(id)sender {
    if(_ifOpreate==YES){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didAfterHidden)];
        [UIView setAnimationDuration:0.5];
        [self.toolView setAlpha:0.0f];
        [self.topView setAlpha:0.0f];
        [rectView setAlpha:0.0f];
        [volumeSlider setAlpha:0.0f];
        [UIView commitAnimations];
    }else{
        [self.toolView setAlpha:1.0f];
        [self.topView setAlpha:1.0f];
        [rectView setAlpha:1.0f];
        [volumeSlider setAlpha:1.0f];
        [self didAfterShow];
    }
}

-(void)didAfterHidden{
    [self.topView setHidden:YES];
    [self.toolView setHidden:YES];
    [volumeSlider setHidden:YES];
    [rectView setHidden:YES];
    _ifOpreate = NO;
}

-(void)didAfterShow{
    [self.topView setHidden:NO];
    [self.toolView setHidden:NO];
    [volumeSlider setHidden:NO];
    [rectView setHidden:NO];
    _ifOpreate = YES;
}

- (IBAction)returnBeforeWIndowAction:(id)sender {
    
    if (self.playerView.player.rate == 1) {
        [self.playerView.player pause];
    }
    self.playerView.player = nil;
    self.playbackTimeObserver = nil;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"---------home KEY pressed--------");
}

@end
