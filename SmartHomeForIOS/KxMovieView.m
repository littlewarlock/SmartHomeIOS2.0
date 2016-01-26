//
//  ViewController.m
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import "KxMovieView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMovieDecoderVer2.h"
#import "KxAudioManager.h"
#import "KxMovieGLView.h"
#import "KxLogger.h"


#import "UPnPDeviceTableViewCell.h"
#import "AppDelegate.h"
#import "CloudFileViewController.h"
//NSString * const KxMovieParameterMinBufferedDuration = @"KxMovieParameterMinBufferedDuration";
//NSString * const KxMovieParameterMaxBufferedDuration = @"KxMovieParameterMaxBufferedDuration";
//NSString * const KxMovieParameterDisableDeinterlacing = @"KxMovieParameterDisableDeinterlacing";

////////////////////////////////////////////////////////////////////////////////

static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSMutableString *format = [(isLeft && seconds >= 0.5 ? @"-" : @"") mutableCopy];
    if (h != 0) [format appendFormat:@"%d:%0.2d", h, m];
    else        [format appendFormat:@"%d", m];
    [format appendFormat:@":%0.2d", s];
    
    return format;
}

////////////////////////////////////////////////////////////////////////////////

enum {
    
    KxMovieInfoSectionGeneral,
    KxMovieInfoSectionVideo,
    KxMovieInfoSectionAudio,
    KxMovieInfoSectionSubtitles,
    KxMovieInfoSectionMetadata,
    KxMovieInfoSectionCount,
};

enum {
    
    KxMovieInfoGeneralFormat,
    KxMovieInfoGeneralBitrate,
    KxMovieInfoGeneralCount,
};

////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary * gHistory;

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

@interface KxMovieView () {
    
    NSDateFormatter     *_dateFormatter;
    MPVolumeView        *m_volumeView;
    UILabel             *_titleLable;
    UIView              *rectView;
    UIView              *barView;
    UIView              *_topBar;
    UIView              *_bottomView;
    
    KxMovieDecoderVer2      *_decoder;
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray      *_videoFrames;
    NSMutableArray      *_audioFrames;
    NSMutableArray      *_subtitles;
    NSData              *_currentAudioFrame;
    NSUInteger          _currentAudioFramePos;
    CGFloat             _moviePosition;
    BOOL                _disableUpdateHUD;
    NSTimeInterval      _tickCorrectionTime;
    NSTimeInterval      _tickCorrectionPosition;
    NSUInteger          _tickCounter;
    BOOL                _fullscreen;
    BOOL                _hiddenHUD;
    BOOL                _fitMode;
    BOOL                _infoMode;
    BOOL                _restoreIdleTimer;
    BOOL                _interrupted;
    
    KxMovieGLView       *_glView;
    UIImageView         *_imageView;
    UIView              *_topHUD;
    
    //    UIToolbar           *_topBar;
    UIToolbar           *_bottomBar;
    UISlider            *_progressSlider;
    UIButton            *_playBtn;
    UIButton            *_pauseBtn;
    //    UIBarButtonItem     *_playBtn;
    //    UIBarButtonItem     *_pauseBtn;
    UIBarButtonItem     *_rewindBtn;
    UIBarButtonItem     *_fforwardBtn;
    UIBarButtonItem     *_spaceItem;
    UIBarButtonItem     *_fixedSpaceItem;
    //hgc
    UISlider     *_sliderBar;
    //hgc
    
    UIButton            *_doneButton;
    UILabel             *_progressLabel;
    UILabel             *_leftLabel;
    UIButton            *_infoButton;//投屏按钮
    CGFloat             _Videotime;
    UITableView         *_tableView;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel             *_subtitlesLabel;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureRecognizer;
    
#ifdef DEBUG
    UILabel             *_messageLabel;
    NSTimeInterval      _debugStartTime;
    NSUInteger          _debugAudioStatus;
    NSDate              *_debugAudioStatusTS;
#endif
    
    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
    
    BOOL                _savedIdleTimer;
    
    NSDictionary        *_parameters;
    
    NSUInteger _currentVideoIndex;
}
@property (readwrite) BOOL playing;
@property (readwrite) BOOL decoding;
@property (readwrite, strong) KxArtworkFrameVer2 *artworkFrame;
//hgc add start
@property (strong,nonatomic)NSString *hgcPath;
@property (strong,nonatomic)NSDictionary *hgcParam;
@property Boolean hgcIsH264LocalFile;
//hgc add end


@property (nonatomic, strong) UIButton *btn;


@property (weak, nonatomic) IBOutlet UILabel *volumn;

@property (weak, nonatomic) IBOutlet UISlider *dlnaProgress;
@property (nonatomic, assign)NSInteger curIndex;

@property (weak, nonatomic) IBOutlet UISlider *volumnSlider;
@property (weak, nonatomic) IBOutlet UILabel *reltime;
@property (weak, nonatomic) IBOutlet UILabel *totaltime;
@property (weak, nonatomic) IBOutlet UIButton *playOrPause;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;



@end

@implementation KxMovieView

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

- (void)toolBarHidden
{
    [_topBar setHidden:YES];
    [_bottomView setHidden:YES];
    [_doneButton setEnabled:NO];
    
}

- (void)setAllControlHidden
{
    [_rewindBtn setEnabled:NO];
    [_fforwardBtn setEnabled:NO];
    [_topBar setHidden:YES];
    [_bottomView setHidden:YES];
    _progressSlider.hidden=YES;
    //    [_progressSlider setEnabled:NO];
    [_doneButton setHidden:YES];
    [_topHUD setHidden:YES];
    [m_volumeView setHidden:YES];
    [rectView setHidden:YES];
}

- (void)toolBarHiddens
{
    [_topBar setHidden:YES];
    [_bottomView setHidden:YES];
    [self setAllControlHidden];
}

-(void)bottomBarAppears
{
    [_bottomBar setHidden:NO];
    [_bottomBar setTintColor:[UIColor whiteColor]];
    //    [_bottomBar setBarTintColor:[UIColor clearColor]];
    [_bottomBar setBackgroundColor:[UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:0.5]];
    [_bottomBar setBackgroundColor:[UIColor blackColor]];
    [_bottomBar setAlpha:0.5];
    
    //    [_bottomBar ]
    
}

- (Boolean)isEndOfFile{
    if (_decoder.isEOF){
        return YES;
    }
    return NO;
}

- (id)movieReplay{
    
    _moviePosition = 0;
    _parameters = self.hgcParam;
    
    NSError *error = nil;
    [_decoder closeFile];
    [_decoder openFile:self.hgcPath error:&error];
    
    return self;
    //    return [self initWithContentPath:self.hgcPath parameters:self.hgcParam];
}


+ (void)initialize
{
    if (!gHistory)
        gHistory = [NSMutableDictionary dictionary];
}

- (BOOL)prefersStatusBarHidden { return YES; }

// 1130
+ (id)openH264File:(NSString *)path parameters:(NSDictionary *)parameters
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];
    return [[KxMovieView alloc] initWithContentPath: path parameters: parameters];
}
// 1130

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters
{
    
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];
    
    
    return [[KxMovieView alloc] initWithContentPath: path parameters: parameters];
}

- (id) initWithContentPath: (NSString *) path
                parameters: (NSDictionary *) parameters
{
    self.hgcParam = parameters;
    self.hgcPath = path;
    self.filePath = (NSMutableString *)path;
    _titleLable.text = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
    NSAssert(path.length > 0, @"empty path");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _moviePosition = 0;
        //        self.wantsFullScreenLayout = YES;
        
        _parameters = parameters;
        
        __weak KxMovieView *weakSelf = self;
        
        KxMovieDecoderVer2 *decoder = [[KxMovieDecoderVer2 alloc] init];
        
        decoder.interruptCallback = ^BOOL(){
            
            __strong KxMovieView *strongSelf = weakSelf;
            return strongSelf ? [strongSelf interruptDecoder] : YES;
        };
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSError *error = nil;
            [decoder openFile:path error:&error];
            
            __strong KxMovieView *strongSelf = weakSelf;
            if (strongSelf) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [strongSelf setMovieDecoder:decoder withError:error];
                });
            }
        });
    }
    return self;
}

- (void) dealloc
{
    [self pause];
    self.dlnaProgress.value = 0;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_dispatchQueue) {
        // Not needed as of ARC.
        //        dispatch_release(_dispatchQueue);
        _dispatchQueue = NULL;
    }
    [_decoder closeFile];
    LoggerStream(1, @"%@ dealloc", self);
}

//static BOOL checkError(OSStatus error, const char *operation)
//{
//    if (error == noErr)
//        return NO;
//    
//    char str[20] = {0};
//    // see if it appears to be a 4-char-code
//    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
//    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
//        str[0] = str[5] = '\'';
//        str[6] = '\0';
//    } else
//        // no, format it as an integer
//        sprintf(str, "%d", (int)error);
//    
//    LoggerStream(0, @"Error: %s (%s)\n", operation, str);
//    
//    //exit(1);
//    return YES;
//}


- (IBAction)returnBeforeWIndowAction:(id)sender {
    
    //[self pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    if (_dispatchQueue) {
//        // Not needed as of ARC.
//        //        dispatch_release(_dispatchQueue);
//        _dispatchQueue = NULL;
//    }

    self.navigationController.navigationBarHidden = NO;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
//    
//    _moviePosition = 0;
//    [_decoder closeFile];
    //[_decoder closeFile];
    //_decoder = nil;
}

- (void)loadView
{
    // LoggerStream(1, @"loadView");
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.tintColor = [UIColor blackColor];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.center = self.view.center;
    _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:_activityIndicatorView];
    
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
#ifdef DEBUG
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,40,width-40,40)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor redColor];
    _messageLabel.hidden = YES;
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.numberOfLines = 2;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_messageLabel];
#endif
    
    CGFloat topH = 50;
    CGFloat botH = 50;
    
    _topHUD    = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    _topBar    = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, topH)];
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height-botH-2, width, botH)];
    
    _topHUD.frame = CGRectMake(0,0,width,_topBar.frame.size.height);
    
    _topHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    _topHUD.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    _topBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    rectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    
    // top hud
    
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(0, 1, 100, topH);
    _doneButton.backgroundColor = [UIColor clearColor];
    [_doneButton setImage:[UIImage imageNamed:@"left-icon"] forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:18];
    _doneButton.showsTouchWhenHighlighted = YES;
    [_doneButton addTarget:self action:@selector(returnBeforeWIndowAction:)
          forControlEvents:UIControlEventTouchUpInside];
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_bottomView.frame.origin.x+width-250, _bottomView.frame.origin.y+1, 150, topH)];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.opaque = NO;
    _progressLabel.adjustsFontSizeToFitWidth = NO;
    _progressLabel.textAlignment = NSTextAlignmentRight;
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.text = @"";
    _progressLabel.font = [UIFont systemFontOfSize:12];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(_bottomView.frame.origin.x, _bottomView.frame.origin.y-topH/2, width, topH)];
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _progressSlider.continuous = NO;
    _progressSlider.value = 0;
    [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:16/255.0 green:142/255.0 blue:220/255.0 alpha:1]];
    [_progressSlider setMaximumTrackTintColor:[UIColor colorWithRed:107/255.0 green:107/255.0 blue:107/255.0 alpha:1]];
    //    [_progressSlider setThumbImage:[UIImage imageNamed:@"kxmovie.bundle/sliderthumb"]
    //                          forState:UIControlStateNormal];
    
    
    _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _infoButton.frame = CGRectMake(width-45, 17, 20, 16);
    _infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    [_infoButton setBackgroundImage:[UIImage imageNamed:@"for-screen"] forState:UIControlStateNormal];
    [_infoButton addTarget:self
                 action:@selector(showTableView)
       forControlEvents:UIControlEventTouchUpInside];

    
    
    
    // bottom hud
    
    _spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                               target:nil
                                                               action:nil];
    
    _fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                    target:nil
                                                                    action:nil];
    _fixedSpaceItem.width = 30;
    
    _rewindBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                               target:self
                                                               action:@selector(rewindDidTouch:)];
    
    //    _playBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
    //                                                             target:self
    //                                                             action:@selector(playDidTouch:)];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.frame = CGRectMake(_bottomView.frame.origin.x, _bottomView.frame.origin.y+1, 50, topH);
    _playBtn.backgroundColor = [UIColor clearColor];
    //    _doneButton.backgroundColor = [UIColor redColor];
    [_playBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_playBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
    _playBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    _playBtn.showsTouchWhenHighlighted = YES;
    [_playBtn addTarget:self action:@selector(playDidTouch:)
       forControlEvents:UIControlEventTouchUpInside];
    
    _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _pauseBtn.frame = CGRectMake(_bottomView.frame.origin.x, _bottomView.frame.origin.y+1, 50, topH);
    _pauseBtn.backgroundColor = [UIColor clearColor];
    //    _doneButton.backgroundColor = [UIColor redColor];
    [_pauseBtn setImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateNormal];
    _pauseBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    _pauseBtn.showsTouchWhenHighlighted = YES;
    [_pauseBtn addTarget:self action:@selector(playDidTouch:)
        forControlEvents:UIControlEventTouchUpInside];
    
    _playBtn.hidden  = NO;
    _pauseBtn.hidden = YES;
    
    barView = [[UIView alloc] initWithFrame:CGRectMake(110, 5, 1,40)];
    barView.backgroundColor = [UIColor whiteColor];
    rectView.layer.cornerRadius = 5.0f;
    
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(120, 1, 200, 50)];
    _titleLable.text = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
    [_titleLable setTextColor:[UIColor whiteColor]];
    
    rectView = [[UIView alloc] initWithFrame:CGRectMake(0, height*1/4, 60,height*1/2)];
    rectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    rectView.layer.cornerRadius = 5.0f;
    
    m_volumeView = [[MPVolumeView alloc]initWithFrame:CGRectMake(-height*1/7, height*1/2, height*3/8, 20)];
    /*
    [m_volumeView setMinimumVolumeSliderImage:[[UIImage imageNamed:@"LeftTrackImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)]forState:UIControlStateNormal];
    [m_volumeView setMaximumVolumeSliderImage:[[UIImage imageNamed:@"RightTrackImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 4)]forState:UIControlStateNormal];
*/
    m_volumeView.transform = CGAffineTransformMakeRotation(-90* M_PI/180);
    
    
    [self.view addSubview:_topBar];
    //[self.view addSubview:_topHUD];
    [self.view addSubview:_bottomView];
    [self.view addSubview:rectView];
    [self.view addSubview:m_volumeView];
    [self.view addSubview:_titleLable];
    [self.view addSubview:barView];
    [self.view addSubview:_playBtn];
    [self.view addSubview:_pauseBtn];
    [self.view addSubview:_doneButton];
    [self.view addSubview:_progressLabel];
    [self.view addSubview:_progressSlider];
    [self.view addSubview:_infoButton];
    
    
    [self updateBottomBar];
    
    if (_decoder) {
        
        [self setupPresentView];
        
    } else {
        
        _progressLabel.hidden = YES;
        _progressSlider.hidden = YES;
        _infoButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.playing) {
        
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0) {
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            
            LoggerStream(0, @"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
//     LoggerStream(1, @"viewDidAppear");
    
    [super viewDidAppear:animated];
    _fullscreen = YES;
    if (self.presentingViewController)
        [self fullscreenMode:nil];
    
    if (_infoMode)
        [self showInfoView:NO animated:NO];
    
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    
    [self showHUD: YES];
    
    if (_decoder) {
        
        [self restorePlay];
        
    } else {
        
        [_activityIndicatorView startAnimating];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
}
- (void)viewDidLoad
{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.dataSource = appDelegate.dataSource;
    
    //创建tableView
    [self setUpTableView];
    
    //创建reTryView
    [self setUpRetryView];
    
    self.isPlay = NO;
    
}


//创建tableView
- (void)setUpTableView
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.dataSource = appDelegate.dataSource;
    
    //创建tableView
    UITableView *tableView = [[UITableView alloc] init];
    CGFloat tableViewW = 216;
    CGFloat tableViewH = self.dataSource.count * 39 + 30;
    CGFloat tableViewX = (self.view.frame.size.height -  tableViewW) * 0.5;
    CGFloat tableViewY = (self.view.frame.size.width - tableViewH) * 0.5;
    tableView.frame = CGRectMake(tableViewX, tableViewY, tableViewW, tableViewH);
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    //提示label
    UILabel *renderLabel = [[UILabel alloc] init];
    CGFloat renderLabelY = self.dataSource.count * 39;
    renderLabel.frame = CGRectMake(0, renderLabelY, 216, 30);
    renderLabel.textAlignment = NSTextAlignmentCenter;
    renderLabel.font = [UIFont systemFontOfSize:12];
    renderLabel.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
    renderLabel.text = @"搜索到的设备";
    [self.tableView addSubview:renderLabel];
    
}

//创建reTryView
- (void)setUpRetryView
{
    CGFloat reTryViewW = 216;
    CGFloat reTryViewH = 110;
    CGFloat reTryViewX = self.view.frame.size.height * 0.5 - 216 * 0.5;
    CGFloat reTryViewY = self.view.frame.size.width * 0.5 - 110 * 0.5;
    UIView *reTryView = [[UIView alloc] initWithFrame:CGRectMake(reTryViewX, reTryViewY, reTryViewW, reTryViewH)];
    self.reTryView = reTryView;
    self.reTryView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    reTryView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:reTryView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(72, 16, 20, 20)];
    label1.text = @"没有发现设备";
    label1.font = [UIFont systemFontOfSize:12];
    [label1 sizeToFit];
    [self.reTryView addSubview:label1];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(39, 43.5, 1, 1)];
    label2.text = @"没有发现DLNA设备，点击重试";
    label2.textColor = [UIColor lightGrayColor];
    label2.font = [UIFont systemFontOfSize:10];
    [label2 sizeToFit];
    [self.reTryView addSubview:label2];
    
    //重试
    UIButton *reTryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 55, 72, 55)];
    [reTryButton setTitle:@"重试" forState:UIControlStateNormal];
    [reTryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    reTryButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.reTryView addSubview:reTryButton];
    [reTryButton addTarget:self action:@selector(reTryDlna) forControlEvents:UIControlEventTouchUpInside];
    
    //关于DLNA
    UIButton *aboutButton = [[UIButton alloc] initWithFrame:CGRectMake(72, 55, 72, 55)];
    [aboutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [aboutButton setTitle:@"关于DLNA" forState:UIControlStateNormal];
    aboutButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.reTryView addSubview:aboutButton];
    [aboutButton addTarget:self action:@selector(aboutDlna) forControlEvents:UIControlEventTouchUpInside];
    
    //取消
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(144, 55, 72, 55)];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.reTryView addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(cancelDlna) forControlEvents:UIControlEventTouchUpInside];
    
    
}
//重新搜索
- (void)reTryDlna
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.avCtrl search];
    self.dataSource = appDelegate.dataSource;
    [self.tableView reloadData];
    
    //进度轮
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    CGPoint center = self.tableView.center;
    [activity setCenter:center];
    //设置进度轮显示类型
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activity = activity;
    [self.view addSubview:activity];
    //开始动画
    [activity startAnimating];
    self.reTryView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    
    //3秒钟的搜索时间
    [self performSelector:@selector(showReSearchResult) withObject:nil afterDelay:3.0f];
}

//展示重新搜索的结果
- (void)showReSearchResult
{
    //停止动画
    [self.activity stopAnimating];
    if (self.dataSource.count != 0) {//如果能够重新搜索到设备
        
        //重新搜索后创建tableView
        [self setUpTableView];
        //让tableView显示出来
        [self showTableView];
        
    } else {//如果没有重新搜索到设备
        
        self.reTryView.transform = CGAffineTransformMakeScale(1, 1);
        
    }
}
//取消搜索
- (void)cancelDlna
{
    self.reTryView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    
}
//关于Dlna
- (void)aboutDlna
{}


//创建dlnaView
- (void)setUpDlna
{
    
    //创建dlnaView
    CGFloat width = [UIScreen mainScreen].bounds.size.height;
    CGFloat height = [UIScreen mainScreen].bounds.size.width;
    UIView *dlnaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width,height)];
    self.dlnaView = dlnaView;
    [self.view addSubview:self.dlnaView];
    
    UIView *aa = [[[NSBundle mainBundle] loadNibNamed:@"DlnaView" owner:self options:nil] objectAtIndex:0];
    aa.frame = self.dlnaView.frame;
    [self.dlnaView addSubview:aa];
    
    //默认音量为50；
    self.volumn.text = @"50.0";
    self.volumnSlider.transform = CGAffineTransformMakeRotation(-1.57079633);
    [self.dlnaProgress setThumbImage:[UIImage imageNamed:@"time_icon-1"] forState:UIControlStateNormal];
    [self.volumnSlider setThumbImage:[UIImage imageNamed:@"time_icon-1"] forState:UIControlStateNormal];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.dlnaProgress addGestureRecognizer:tap];
    
    //获得播放视频的时间信息
    CGUpnpAVPositionInfo *position = [self.renderer positionInfo];
    CGFloat relTime = [position relTime];//视频的当前播放时间
    CGFloat trackDuration = [position trackDuration];//视频的整体时间
    self.relTime = relTime;
    self.totalTime = trackDuration;
    self.playOrPause.selected = NO;
 

    //设置总时长label
    NSInteger totalHour = trackDuration / 3600;
    NSInteger totalMinute = (trackDuration < 3600) ? (NSInteger)trackDuration / 60 : (NSInteger)trackDuration % 3600 / 60;
    NSInteger totalSecond = (trackDuration < 60) ? (NSInteger)trackDuration % 60 : (NSInteger)trackDuration % 60 % 60;
    self.totaltime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",totalHour,totalMinute,totalSecond];

    //获得播放器播放的视频的时间
    CGFloat Videotime = _moviePosition - _decoder.startTime;
    _Videotime = Videotime;
    
    NSInteger timeHour = Videotime / 3600;
    NSInteger timeMinute = (Videotime < 3600) ? (NSInteger)Videotime / 60 : (NSInteger)Videotime % 3600 / 60;
    NSInteger timeSecond = (Videotime < 60) ? (NSInteger)Videotime % 60 : (NSInteger)Videotime % 60 % 60;
    
    //设置时间label的值
    self.dlnaProgress.value = Videotime / self.totalTime;
    self.reltime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",timeHour,timeMinute,timeSecond];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.curIndex = _currentVideoIndex;
    
    //dlna播放视频
    if ([self.renderer setAVTransportURI:[app.videoUrl objectAtIndex:self.curIndex]]) {
        [self.renderer play];
        self.isPlay = [self.renderer isPlayingDlna];
    }
    
    //跳到播放器播放的视频的时间
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.renderer seek:Videotime];
        
    });
    
    //设置titleLabel显示文字
    NSString *str = [[[app.videoUrl objectAtIndex:self.curIndex] componentsSeparatedByString:@"//"] lastObject];
    NSString *titleStr = [[str componentsSeparatedByString:@"."] firstObject];
    self.titleLabel.text = [NSString stringWithString:titleStr];
    
    
    //对定时器的操作
    [self removeProgressTimer];
    [self addProgressTimer];
    
    
}


//获得当前播放的视频索引
- (void)setCurrentVideoIndex:(NSUInteger)index {
    
    _currentVideoIndex = index;
}

#pragma mark - dlna页面监听方法

//暂停、开始播放
- (IBAction)playOrPause:(UIButton *)sender {
    
    NSLog(@"接收到了点击");
    if (self.isPlay) {
        [self.renderer pause];
        self.playOrPause.selected = YES;
 
        // 移除定时器
        [self removeProgressTimer];
        
    }else {
        [self.renderer play];
        self.playOrPause.selected = NO;

        // 添加定时器
        [self addProgressTimer];
    }
    self.isPlay = [self.renderer isPlayingDlna];
}

- (IBAction)pre:(UIButton *)sender {
    
    //移除上一个定时器
    [self removeProgressTimer];
    self.playOrPause.selected = YES;
    self.dlnaProgress.value = 0.0;
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    //播放上一个视频
    NSInteger currentIndex = self.curIndex;
    NSInteger preIndex = --currentIndex;
    if (preIndex < 0) {
        preIndex = app.videoUrl.count - 1;
    }
    
    if ([self.renderer setAVTransportURI:[app.videoUrl objectAtIndex:preIndex]]) {
        [self.renderer play];
    }
    self.playOrPause.selected = NO;
    
    //显示播放视频的title
    NSString *str = [[[app.videoUrl objectAtIndex:preIndex] componentsSeparatedByString:@"//"] lastObject];
    NSString *titleStr = [[str componentsSeparatedByString:@"."] firstObject];
    self.titleLabel.text = [NSString stringWithString:titleStr];
    
    //添加定时器
    [self addProgressTimer];
    self.curIndex = preIndex;
}
- (IBAction)next:(UIButton *)sender {
    
    //移除定时器
    [self removeProgressTimer];
    self.playOrPause.selected = YES;
    self.dlnaProgress.value = 0.0;
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    //播放下一个视频
    NSInteger currentIndex = self.curIndex;
    NSInteger nextIndex = ++currentIndex;
    if (nextIndex >= app.videoUrl.count) {
        
        nextIndex = 0;
    }
    
    if ([self.renderer setAVTransportURI:[app.videoUrl objectAtIndex:nextIndex]]) {
        [self.renderer play];
    }
    self.playOrPause.selected = NO;
    
    //显示下一个视频的title
    NSString *str = [[[app.videoUrl objectAtIndex:nextIndex] componentsSeparatedByString:@"//"] lastObject];
    NSString *titleStr = [[str componentsSeparatedByString:@"."] firstObject];
    self.titleLabel.text = [NSString stringWithString:titleStr];
    
    //移除定时器
    [self addProgressTimer];
    self.curIndex = nextIndex;
}

//改变音量
- (IBAction)volumnChange:(UISlider *)sender {
    
    //最大音量
    CGFloat maxVol = 100;

    //改变音量
    CGFloat vol = self.volumnSlider.value * maxVol ;
    [self.renderer setVolume:vol];
    self.volumn.text = [NSString stringWithFormat:@"%.1f",vol];
    NSLog(@"%f",vol);
}




//开始拖拽进度条
- (IBAction)slideTouchDown:(UISlider *)sender {
    //移除定时器
    [self removeProgressTimer];
}

- (IBAction)slideValueChange:(UISlider *)sender {
    
    CGFloat value = self.dlnaProgress.value * self.totalTime;
    
    //显示播放时间
    NSInteger relHour = value / 3600;
    NSInteger relMinute = (value < 3600) ? (NSInteger)value / 60 : (NSInteger)value % 3600 / 60;
    NSInteger relSecond = (value < 60) ? (NSInteger)value % 60 : (NSInteger)value % 60 % 60;
    self.reltime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",relHour,relMinute,relSecond];

    
}

//拖拽进度条结束
- (IBAction)slideTouchUpInside:(UISlider *)sender {
    
    
    // 更新播放的时间
    self.relTime = self.dlnaProgress.value * self.totalTime;
    
    //视频跳转到更新后的时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.renderer seek:self.relTime];
    });
    
    // 添加定时器
    [self addProgressTimer];
    
}
//单击进度条
- (void)singleTap:(UITapGestureRecognizer*)tap {
    
    CGPoint p = [tap locationInView:tap.view];
    CGFloat value = p.x / self.dlnaProgress.frame.size.width;
    CGFloat iTime = value * self.totalTime;
    [self.dlnaProgress setValue:value animated:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.renderer seek:iTime];
        
    });
    [self updateProgressInfo];
}
//返回私有云
- (IBAction)backCloub:(id)sender
{

    self.relTime = 0.0;
    self.totalTime = 0.0;
    [self.dlnaProgress setValue:0.0 animated:NO];
    [self removeProgressTimer];
    self.navigationController.navigationBarHidden = NO;
    [self.view removeFromSuperview];
    [self.dlnaView removeFromSuperview];
    [self removeFromParentViewController];
    
}

#pragma mark - 对定时器的操作
- (void)addProgressTimer
{
    [self updateProgressInfo];
    self.dlnaProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.dlnaProgressTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer
{
    [self.dlnaProgressTimer invalidate];
    self.dlnaProgressTimer = nil;
}
//更新进度
- (void)updateProgressInfo
{

    //获得视频播放的时间信息
    CGUpnpAVPositionInfo *position = [self.renderer positionInfo];
    CGFloat relTime = [position relTime];//视频的当前播放时间
    CGFloat trackDuration = [position trackDuration];//视频的整体时间
    self.relTime = relTime;
    self.totalTime = trackDuration;
    
    //更新滑块的位置
    NSLog(@"self.dlnaProgress.value:%f",self.dlnaProgress.value);
    self.dlnaProgress.value = self.relTime / self.totalTime;
    NSLog(@"self.dlnaProgress.value:%f",self.dlnaProgress.value);
    
    //显示播放时间
    NSInteger totalHour = trackDuration / 3600;
    NSInteger totalMinute = (trackDuration < 3600) ? (NSInteger)trackDuration / 60 : (NSInteger)trackDuration % 3600 / 60;
    NSInteger totalSecond = (trackDuration < 60) ? (NSInteger)trackDuration % 60 : (NSInteger)trackDuration % 60 % 60;
        
    NSInteger relHour = relTime / 3600;
    NSInteger relMinute = (relTime < 3600) ? (NSInteger)relTime / 60 : (NSInteger)relTime % 3600 / 60;
    NSInteger relSecond = (relTime < 60) ? (NSInteger)relTime % 60 : (NSInteger)relTime % 60 % 60;
    self.reltime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",relHour,relMinute,relSecond];
    self.totaltime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",totalHour,totalMinute,totalSecond];
    
}



//显示device的tableView
- (void)showTableView{
    
    //暂停播放的视频
    [self pause];
    self.tableView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    //重新搜索设备
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.avCtrl search];
    self.dataSource = appDelegate.dataSource;
    
    [self setUpTableView];
    [self.tableView reloadData];
    
    //显示搜索结果
    if (self.dataSource.count != 0) {//能够搜索到device
        //恢复tableView的显示
        self.tableView.transform = CGAffineTransformMakeScale(1, 1);
        self.reTryView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        [self.tableView reloadData];
    } else {//没有搜索到device
        //恢复reTryView的显示
        self.tableView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        self.reTryView.transform = CGAffineTransformMakeScale(1, 1);
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //隐藏tableView
    self.tableView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    self.reTryView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    
    //切换视频的播放和暂停
    if (self.playing) {
        [self pause];
    }else {
        [self play];
    }
    
}




#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CELLID = @"upnprootobj";
    UPnPDeviceTableViewCell *cell = (UPnPDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELLID];
    if (cell == nil) {
        cell = [[UPnPDeviceTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CELLID];
        
    }
    
    NSInteger row = [indexPath indexAtPosition:1];
    if (row < [self.dataSource count]) {
        CGUpnpDevice *device = [self.dataSource objectAtIndex:row];
        cell.textLabel.text = [device friendlyName];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        //cell的分隔线
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 38.5, 216,0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
        [cell addSubview:separatorView];
    }
    
    return cell;
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.renderer = (CGUpnpAvRenderer *)[self.dataSource objectAtIndex:indexPath.row];
    
    //点击cell时直接跳转到播放控制页面
    [self setUpDlna];
    
    
}



- (void) viewWillDisappear:(BOOL)animated
{

    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
    [_activityIndicatorView stopAnimating];
    
    if (_decoder) {
        
        [self pause];
        
        if (_moviePosition == 0 || _decoder.isEOF)
            [gHistory removeObjectForKey:_decoder.path];
        else if (!_decoder.isNetwork)
            [gHistory setValue:[NSNumber numberWithFloat:_moviePosition]
                        forKey:_decoder.path];
    }
    
    if (_fullscreen)
        [self fullscreenMode:nil];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    
    [_activityIndicatorView stopAnimating];
    _buffered = NO;
    _interrupted = YES;
    
    LoggerStream(1, @"viewWillDisappear %@", self);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) applicationWillResignActive: (NSNotification *)notification
{
    [self showHUD:YES];
    [self pause];
    
    LoggerStream(1, @"applicationWillResignActive");
}

#pragma mark - gesture recognizer

- (void) handleTap: (UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (sender == _tapGestureRecognizer) {
            
            [self showHUD: _hiddenHUD];
            
        } else if (sender == _doubleTapGestureRecognizer) {
            
            UIView *frameView = [self frameView];
            
            if (frameView.contentMode == UIViewContentModeScaleAspectFit)
                frameView.contentMode = UIViewContentModeScaleAspectFill;
            else
                frameView.contentMode = UIViewContentModeScaleAspectFit;
            
        }
    }
}

- (void) handlePan: (UIPanGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        const CGPoint vt = [sender velocityInView:self.view];
        const CGPoint pt = [sender translationInView:self.view];
        const CGFloat sp = MAX(0.1, log10(fabsf(vt.x)) - 1.0);
        const CGFloat sc = fabsf(pt.x) * 0.33 * sp;
        if (sc > 10) {
            
            const CGFloat ff = pt.x > 0 ? 1.0 : -1.0;
            [self setMoviePosition: _moviePosition + ff * MIN(sc, 600.0)];
        }
        //LoggerStream(2, @"pan %.2f %.2f %.2f sec", pt.x, vt.x, sc);
    }
}

#pragma mark - public

-(void) play
{
    if (self.playing)
        return;
    
    if (!_decoder.validVideo &&
        !_decoder.validAudio) {
        
        return;
    }
    
    if (_interrupted)
        return;
    
    self.playing = YES;
    _interrupted = NO;
    _disableUpdateHUD = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
#ifdef DEBUG
    _debugStartTime = -1;
#endif
    
    [self asyncDecodeFrames];
    [self updatePlayButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
    
    if (_decoder.validAudio)
        [self enableAudio:YES];
    // merged by hgc 2015 12 17 start
    NSLog(@"duration==%f",_decoder.duration);
//    if((_decoder.duration -_moviePosition)<1.8){
//        self.playing = NO;
//        _moviePosition = 0;
//        [_decoder setPosition:0];
//        [self enableAudio:NO];
//        [self updatePlayButton];
//    }
    // merged by hgc 2015 12 17 end
    //hgc added 2015 11 05 start
    if (_decoder.isEOF) {
        NSLog(@"_decoder in play");
        NSLog(@"self.hgcPath==%@",self.hgcPath);
        NSLog(@"self.hgcParam==%@",self.hgcParam);
        _moviePosition = 0;
        _parameters = self.hgcParam;
        //        [self initWithContentPath:self.hgcPath parameters:self.hgcParam];
        //        NSError *error = nil;
        //        [_decoder closeFile];
        //        [_decoder openFile:self.hgcPath error:&error];
    }
    //hgc added 2015 11 05 end
    
    LoggerStream(1, @"play movie");
}

- (void) pause
{
    if (!self.playing)
        return;
    
    self.playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    [self updatePlayButton];
    LoggerStream(1, @"pause movie");
}

- (void) setMoviePosition: (CGFloat) position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    _disableUpdateHUD = YES;
    [self enableAudio:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self updatePosition:position playMode:playMode];
    });
}

#pragma mark - actions

- (void) infoDidTouch: (id) sender
{
    [self showInfoView: !_infoMode animated:YES];
}

- (void) playDidTouch: (id) sender
{
    //2015 11 06 hgc add
    if ([self isEndOfFile]) {
        _moviePosition = 0.0f;
        [_decoder setPosition:0.0f];
        _parameters = self.hgcParam;
        NSError *error = nil;
        [_decoder closeFile];
        [_decoder openFile:self.hgcPath error:&error];
    }
    //2015 11 06 hgc add
    if (self.playing){
        [self pause];
    }
    else
    {
        [self play];
    }
    //        }
}

- (void) forwardDidTouch: (id) sender
{
    [self setMoviePosition: _moviePosition + 10];
}

- (void) rewindDidTouch: (id) sender
{
    [self setMoviePosition: _moviePosition - 10];
}

- (void) progressDidChange: (id) sender
{
    NSAssert(_decoder.duration != MAXFLOAT, @"bugcheck");
    UISlider *slider = sender;
    [self setMoviePosition:slider.value * _decoder.duration];
}

#pragma mark - private

- (void) setMovieDecoder: (KxMovieDecoder *) decoder
               withError: (NSError *) error
{
    LoggerStream(2, @"setMovieDecoder");
    
    if (!error && decoder) {
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
        
        if (_decoder.subtitleStreamsCount) {
            _subtitles = [NSMutableArray array];
        }
        
        if (_decoder.isNetwork) {
            
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
        
        // allow to tweak some parameters at runtime
        if (_parameters.count) {
            
            id val;
            
            val = [_parameters valueForKey: KxMovieParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        LoggerStream(2, @"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        if (self.isViewLoaded) {
            
            [self setupPresentView];
            
            _progressLabel.hidden   = NO;
            _progressSlider.hidden  = NO;
            _leftLabel.hidden       = NO;
            _infoButton.hidden      = NO;
            
            if (_activityIndicatorView.isAnimating) {
                
                [_activityIndicatorView stopAnimating];
                // if (self.view.window)
                [self restorePlay];
            }
        }
        
    } else {
        
        if (self.isViewLoaded && self.view.window) {
            
            [_activityIndicatorView stopAnimating];
            if (!_interrupted)
                [self handleDecoderMovieError: error];
        }
    }
}

- (void) restorePlay
{
    NSNumber *n = [gHistory valueForKey:_decoder.path];
    if (n)
        [self updatePosition:n.floatValue playMode:YES];
    else
        [self play];
}

- (void) setupPresentView
{
    CGRect bounds = self.view.bounds;
    
    if (_decoder.validVideo) {
        _glView = [[KxMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
    }
    
    if (!_glView) {
        
        LoggerVideo(0, @"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:bounds];
        _imageView.backgroundColor = [UIColor blackColor];
    }
    
    UIView *frameView = [self frameView];
    frameView.contentMode = UIViewContentModeScaleAspectFit;
    frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view insertSubview:frameView atIndex:0];
    
    if (_decoder.validVideo) {
        
        [self setupUserInteraction];
        
    } else {
        
        _imageView.image = [UIImage imageNamed:@"kxmovie.bundle/music_icon.png"];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (_decoder.duration == MAXFLOAT) {
        
        _leftLabel.text = @"\u221E"; // infinity
        _leftLabel.font = [UIFont systemFontOfSize:14];
        
        CGRect frame;
        
        frame = _leftLabel.frame;
        frame.origin.x += 40;
        frame.size.width -= 40;
        _leftLabel.frame = frame;
        
        frame =_progressSlider.frame;
        frame.size.width += 40;
        _progressSlider.frame = frame;
        
    } else {
        
        [_progressSlider addTarget:self
                            action:@selector(progressDidChange:)
                  forControlEvents:UIControlEventValueChanged];
    }
    
    if (_decoder.subtitleStreamsCount) {
        
        CGSize size = self.view.bounds.size;
        
        _subtitlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height, size.width, 0)];
        _subtitlesLabel.numberOfLines = 0;
        _subtitlesLabel.backgroundColor = [UIColor clearColor];
        _subtitlesLabel.opaque = NO;
        _subtitlesLabel.adjustsFontSizeToFitWidth = NO;
        _subtitlesLabel.textAlignment = NSTextAlignmentCenter;
        _subtitlesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _subtitlesLabel.textColor = [UIColor whiteColor];
        _subtitlesLabel.font = [UIFont systemFontOfSize:16];
        _subtitlesLabel.hidden = YES;
        
        [self.view addSubview:_subtitlesLabel];
    }
}

- (void) setupUserInteraction
{
    UIView * view = [self frameView];
    view.userInteractionEnabled = YES;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    [_tapGestureRecognizer requireGestureRecognizerToFail: _doubleTapGestureRecognizer];
    
    [view addGestureRecognizer:_doubleTapGestureRecognizer];
    [view addGestureRecognizer:_tapGestureRecognizer];
    
    //    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    //    _panGestureRecognizer.enabled = NO;
    //
    //    [view addGestureRecognizer:_panGestureRecognizer];
}

- (UIView *) frameView
{
    return _glView ? _glView : _imageView;
}

- (void) audioCallbackFillData: (float *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels
{
    //fillSignalF(outData,numFrames,numChannels);
    //return;
    
    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        
                        KxAudioFrameVer2 *frame = _audioFrames[0];
                        
#ifdef DUMP_AUDIO_DATA
                        LoggerAudio(2, @"Audio frame position: %f", frame.position);
#endif
                        if (_decoder.validVideo) {
                            //delete by lcw 20151230
//                            const CGFloat delta = _moviePosition - frame.position;
                           
//                            if (delta < -0.1) {
//                                
//                                memset(outData, 0, numFrames * numChannels * sizeof(float));
//#ifdef DEBUG
//                                LoggerStream(0, @"desync audio (outrun) wait %.4f %.4f", _moviePosition, frame.position);
//                                _debugAudioStatus = 1;
//                                _debugAudioStatusTS = [NSDate date];
//#endif
//                                
//                                break; // silence and exit
//                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                             //delete by lcw 20151230
//                            if (delta > 0.1 && count > 1) {
//                                
//#ifdef DEBUG
//                                LoggerStream(0, @"desync audio (lags) skip %.4f %.4f", _moviePosition, frame.position);
//                                _debugAudioStatus = 2;
//                                _debugAudioStatusTS = [NSDate date];
//#endif
//                                continue;
//                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //LoggerStream(1, @"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void) enableAudio: (BOOL) on
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    
    if (on && _decoder.validAudio) {
        
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
            
            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        
        LoggerAudio(2, @"audio device smr: %d fmt: %d chn: %d",
                    (int)audioManager.samplingRate,
                    (int)audioManager.numBytesPerSample,
                    (int)audioManager.numOutputChannels);
        
    } else {
        
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (BOOL) addFrames: (NSArray *)frames
{
    if (_decoder.validVideo) {
        
        @synchronized(_videoFrames) {
            
            for (KxMovieFrameVer2 *frame in frames)
                if (frame.type == KxMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio) {
        
        @synchronized(_audioFrames) {
            
            for (KxMovieFrameVer2 *frame in frames)
                if (frame.type == KxMovieFrameTypeAudio) {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo) {
            
            for (KxMovieFrameVer2 *frame in frames)
                if (frame.type == KxMovieFrameTypeArtwork)
                    self.artworkFrame = (KxArtworkFrameVer2 *)frame;
        }
    }
    
    if (_decoder.validSubtitles) {
        
        @synchronized(_subtitles) {
            
            for (KxMovieFrameVer2 *frame in frames)
                if (frame.type == KxMovieFrameTypeSubtitle) {
                    [_subtitles addObject:frame];
                }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL) decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo ||
        _decoder.validAudio) {
        
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count) {
        return [self addFrames: frames];
    }
    return NO;
}

- (void) asyncDecodeFrames
{
    if (self.decoding)
        return;
    
    __weak KxMovieView *weakSelf = self;
    __weak KxMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
//    if((_decoder.duration -_moviePosition)<0.18){
//
//        _playBtn.hidden =NO;
//        _pauseBtn.hidden = YES;
//        
//    }
    
    dispatch_async(_dispatchQueue, ^{
        
        {
            __strong KxMovieView *strongSelf = weakSelf;
            if (!strongSelf.playing)
                return;
        }
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool {
                
                __strong KxMovieDecoderVer2 *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)) {
                    
                    NSArray *frames = [decoder decodeFrames:duration];
                    if (frames.count) {
                        
                        __strong KxMovieView *strongSelf = weakSelf;
                        if (strongSelf)
                            good = [strongSelf addFrames:frames];
                    }

                }
            }
        }
        
        {
            __strong KxMovieView *strongSelf = weakSelf;
            if (strongSelf) strongSelf.decoding = NO;
        }
    });
}

- (void) tick
{
    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF)) {
        
        _tickCorrectionTime = 0;
        _buffered = NO;
        [_activityIndicatorView stopAnimating];
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing) {
        
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count : 0) +
        (_decoder.validAudio ? _audioFrames.count : 0);
        
        // 2015 11 10 hgc start
        //        NSLog(@"leftFrames1212==%lu",(unsigned long)leftFrames);
        //        NSLog(@"_videoFrames.count = %lu",(unsigned long)_videoFrames.count);
        // 2015 11 10 hgc end
        if (0 == leftFrames) {
            
            if (_decoder.isEOF) {
                
                [self pause];
//                // hgc start
//                NSLog(@"leftFrames==%lu",(unsigned long)leftFrames);
//                _moviePosition = 0;
//                // hgc end
                [self updateHUD];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered) {
                
                _buffered = YES;
                [_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)) {
            
//            BOOL conditionMkv = [[_decoder.info[@"format"]lowercaseString] isEqualToString:@"mkv"] ;
            
            
            
//            if((_decoder.duration -_moviePosition)<2.0){
//                _moviePosition = 0;
//                _progressSlider.value= 0;
//                [_decoder setPosition:0];
//                
//                self.playing =NO;
//                _playBtn.hidden =NO;
//                _pauseBtn.hidden = YES;
//                [self updatePosition:0 playMode:NO];
//                [self pause];
//                //[_decoder closeFile];
//                
//            }else{
                [self asyncDecodeFrames];
//            }
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
    
    if ((_tickCounter++ % 3) == 0) {
        [self updateHUD];
    }
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200) == 0)
    //    LoggerStream(1, @"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f) {
        
        LoggerStream(1, @"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat) presentFrame
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo) {
        
        KxVideoFrameVer2 *frame;
        
        @synchronized(_videoFrames) {
            
            if (_videoFrames.count > 0) {
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio) {
        
        //interval = _bufferedDuration * 0.5;
        
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
    if (_decoder.validSubtitles)
        [self presentSubtitles];
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif
    
    return interval;
    
}

- (CGFloat) presentVideoFrame: (KxVideoFrameVer2 *) frame
{
    if (_glView) {
        
        [_glView render:frame];
        
    } else {
        
        KxVideoFrameRGBVer2 *rgbFrame = (KxVideoFrameRGBVer2 *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    
    return frame.duration;
}

- (void) presentSubtitles
{
    NSArray *actual, *outdated;
    
    if ([self subtitleForPosition:_moviePosition
                           actual:&actual
                         outdated:&outdated]){
        
        if (outdated.count) {
            @synchronized(_subtitles) {
                [_subtitles removeObjectsInArray:outdated];
            }
        }
        
        if (actual.count) {
            
            NSMutableString *ms = [NSMutableString string];
            for (KxSubtitleFrameVer2 *subtitle in actual.reverseObjectEnumerator) {
                if (ms.length) [ms appendString:@"\n"];
                [ms appendString:subtitle.text];
            }
            
            if (![_subtitlesLabel.text isEqualToString:ms]) {
                
                CGSize viewSize = self.view.bounds.size;
                CGSize size = [ms sizeWithFont:_subtitlesLabel.font
                             constrainedToSize:CGSizeMake(viewSize.width, viewSize.height * 0.5)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
                _subtitlesLabel.text = ms;
                _subtitlesLabel.frame = CGRectMake(0, viewSize.height - size.height - 10,
                                                   viewSize.width, size.height);
                _subtitlesLabel.hidden = NO;
            }
            
        } else {
            
            _subtitlesLabel.text = nil;
            _subtitlesLabel.hidden = YES;
        }
    }
}

- (BOOL) subtitleForPosition: (CGFloat) position
                      actual: (NSArray **) pActual
                    outdated: (NSArray **) pOutdated
{
    if (!_subtitles.count)
        return NO;
    
    NSMutableArray *actual = nil;
    NSMutableArray *outdated = nil;
    
    for (KxSubtitleFrameVer2 *subtitle in _subtitles) {
        
        if (position < subtitle.position) {
            
            break; // assume what subtitles sorted by position
            
        } else if (position >= (subtitle.position + subtitle.duration)) {
            
            if (pOutdated) {
                if (!outdated)
                    outdated = [NSMutableArray array];
                [outdated addObject:subtitle];
            }
            
        } else {
            
            if (pActual) {
                if (!actual)
                    actual = [NSMutableArray array];
                [actual addObject:subtitle];
            }
        }
    }
    
    if (pActual) *pActual = actual;
    if (pOutdated) *pOutdated = outdated;
    
    return actual.count || outdated.count;
}

- (void) updateBottomBar
{
    if(self.playing){
        _pauseBtn.hidden = NO;
        _playBtn.hidden  = YES;
    }else{
        _playBtn.hidden  = NO;
        _pauseBtn.hidden = YES;
    }
}

- (void) updatePlayButton
{
    [self updateBottomBar];
}

- (void) updateHUD
{
    if (_disableUpdateHUD)
        return;
    
    const CGFloat duration = _decoder.duration;
    
    CGFloat startPosition =_decoder.startTime;
    if(startPosition<0){
        startPosition = 0;
    }
    const CGFloat position = _moviePosition -startPosition;
//    KxAudioFrameVer2 *frame;
//    CGFloat position;
//    if(_audioFrames.count != 0 ){
//     frame = _audioFrames[0];
//        position =  frame.position;
//    }else{
//        position=0;
//    }

    //hgc 2015 11 26
//        NSLog(@"duration==%f",duration);
//        NSLog(@"_moviePosition===%f",_moviePosition);
//        NSLog(@"_decoder.startTime===%f",_decoder.startTime);
    //hgc 2015 11 26
    
    if (_progressSlider.state == UIControlStateNormal)
        _progressSlider.value = position / duration;
        if(_audioFrames.count == 0 ){
            if(_videoFrames.count == 0){
                _progressSlider.value = 1;
            }
        }
    
    _progressLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTime:position],[self convertTime:duration]];
    
#ifdef DEBUG
    const NSTimeInterval timeSinceStart = [NSDate timeIntervalSinceReferenceDate] - _debugStartTime;
    NSString *subinfo = _decoder.validSubtitles ? [NSString stringWithFormat: @" %d",_subtitles.count] : @"";
    
    NSString *audioStatus;
    
    if (_debugAudioStatus) {
        
        if (NSOrderedAscending == [_debugAudioStatusTS compare: [NSDate dateWithTimeIntervalSinceNow:-0.5]]) {
            _debugAudioStatus = 0;
        }
    }
    
    if      (_debugAudioStatus == 1) audioStatus = @"\n(audio outrun)";
    else if (_debugAudioStatus == 2) audioStatus = @"\n(audio lags)";
    else if (_debugAudioStatus == 3) audioStatus = @"\n(audio silence)";
    else audioStatus = @"";
    
    _messageLabel.text = [NSString stringWithFormat:@"%d %d%@ %c - %@ %@ %@\n%@",
                          _videoFrames.count,
                          _audioFrames.count,
                          subinfo,
                          self.decoding ? 'D' : ' ',
                          formatTimeInterval(timeSinceStart, NO),
                          //timeSinceStart > _moviePosition + 0.5 ? @" (lags)" : @"",
                          _decoder.isEOF ? @"- END" : @"",
                          audioStatus,
                          _buffered ? [NSString stringWithFormat:@"buffering %.1f%%", _bufferedDuration / _minBufferedDuration * 100] : @""];
#endif
}

- (void) showHUD: (BOOL) show
{
    _hiddenHUD = !show;
    _panGestureRecognizer.enabled = _hiddenHUD;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_hiddenHUD];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         CGFloat alpha = _hiddenHUD ? 0 : 1;
                         _topBar.alpha = alpha/2;
                         barView.alpha = alpha;
                         _doneButton.alpha = alpha;
                         _titleLable.alpha = alpha;
                         _infoButton.alpha = alpha;
                         _bottomView.alpha = alpha/2;
                         _playBtn.alpha = alpha;
                         _pauseBtn.alpha = alpha;
                         _progressSlider.alpha = alpha;
                         _progressLabel.alpha = alpha;
                         m_volumeView.alpha = alpha;
                         _topHUD.alpha = alpha/2;
                         rectView.alpha = alpha/2;
                     }
                     completion:nil];
    
}

- (void) fullscreenMode: (id) sender
{
    //_fullscreen = on;
    CGFloat topH = 50;
    CGFloat botH = 50;
    CGFloat SCREEN_HEIGHT =  [UIScreen mainScreen].bounds.size.height;
    CGFloat SCREEN_WIDTH =  [UIScreen mainScreen].bounds.size.width;
    
    
    if(_fullscreen){
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _titleLable.frame = CGRectMake(120, 1, SCREEN_HEIGHT-150, topH);
        _progressSlider.frame = CGRectMake(0, SCREEN_WIDTH-botH-topH/4, SCREEN_HEIGHT, topH/2);
        _playBtn.frame = CGRectMake(20, SCREEN_WIDTH-50+1, botH, topH);
        _pauseBtn.frame = CGRectMake(20, SCREEN_WIDTH-50+1, botH, topH);
        _progressLabel.frame = CGRectMake( SCREEN_HEIGHT -200, SCREEN_WIDTH-botH, 150, topH);
        rectView.frame = CGRectMake(0, SCREEN_WIDTH*1/4, 80,SCREEN_WIDTH*1/2);
        m_volumeView.frame= CGRectMake(SCREEN_WIDTH*1/8, SCREEN_WIDTH*5/16, 20, SCREEN_WIDTH*3/8);
        
    }else{
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        self.view.transform = CGAffineTransformMakeRotation(M_PI*2);
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bottomView.frame= CGRectMake(0, SCREEN_HEIGHT-botH, SCREEN_WIDTH, botH);
        _titleLable.frame = CGRectMake(120, 1, SCREEN_WIDTH-150, topH);
        _progressSlider.frame =CGRectMake(0, SCREEN_HEIGHT-50-topH/4, SCREEN_WIDTH, topH/2);
        _playBtn.frame =CGRectMake( 20, SCREEN_HEIGHT-botH+1, botH, topH);
        _pauseBtn.frame =CGRectMake(20, SCREEN_HEIGHT-botH+1, botH, topH);
        _progressLabel.frame = CGRectMake(0+SCREEN_WIDTH-200, SCREEN_HEIGHT-botH+1, 150, topH);
        rectView.frame =CGRectMake(0, SCREEN_HEIGHT*1/4, 60,SCREEN_HEIGHT*1/2);
        m_volumeView.frame= CGRectMake(SCREEN_WIDTH*1/8, SCREEN_WIDTH*5/16, 20, SCREEN_WIDTH*3/8);
        
    }
    _fullscreen = !_fullscreen;
    
}

- (void) setMoviePositionFromDecoder
{
    _moviePosition = _decoder.position;
}

- (void) setDecoderPosition: (CGFloat) position
{
    _decoder.position = position;
}

- (void) enableUpdateHUD
{
    _disableUpdateHUD = NO;
}

- (void) updatePosition: (CGFloat) position
               playMode: (BOOL) playMode
{
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    // merged by hgc 2015 12 17 start
//    if((_decoder.duration - position)<1.8 || position <1.8){
//        self.playing = NO;
//        _moviePosition = 0;
//        _progressSlider.value= 0;
//        [_decoder setPosition:0];
//        [self enableAudio:NO];
//        [self updatePlayButton];
//        [self playDidTouch:nil];
//        return;
//    }
    
    // merged by hgc 2015 12 17 end
    __weak KxMovieView *weakSelf = self;
    
    dispatch_async(_dispatchQueue, ^{
        
        if (playMode) {
            
            {
                __strong KxMovieView *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong KxMovieView *strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf play];
                }
            });
            
        } else {
            
            {
                __strong KxMovieView *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
                [strongSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong KxMovieView *strongSelf = weakSelf;
                if (strongSelf) {
                    
                    [strongSelf enableUpdateHUD];
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf presentFrame];
                    [strongSelf updateHUD];
                }
            });
        }
    });
}

- (void) freeBufferedFrames
{
    @synchronized(_videoFrames) {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames) {
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    if (_subtitles) {
        @synchronized(_subtitles) {
            [_subtitles removeAllObjects];
        }
    }
    
    _bufferedDuration = 0;
}

- (void) showInfoView: (BOOL) showInfo animated: (BOOL)animated
{
    if (!_tableView)
        [self createTableView];
    
    [self pause];
    
    CGSize size = self.view.bounds.size;
    CGFloat Y = _topHUD.bounds.size.height;
    
    if (showInfo) {
        
        _tableView.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 _tableView.frame = CGRectMake(0,Y,size.width,size.height - Y);
                             }
                             completion:nil];
        } else {
            
            _tableView.frame = CGRectMake(0,Y,size.width,size.height - Y);
        }
        
    } else {
        
        if (animated) {
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 _tableView.frame = CGRectMake(0,size.height,size.width,size.height - Y);
                                 
                             }
                             completion:^(BOOL f){
                                 
                                 if (f) {
                                     _tableView.hidden = YES;
                                 }
                             }];
        } else {
            
            _tableView.frame = CGRectMake(0,size.height,size.width,size.height - Y);
            _tableView.hidden = YES;
        }
    }
    
    _infoMode = showInfo;
}

- (void) createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.hidden = YES;
    
    CGSize size = self.view.bounds.size;
    CGFloat Y = _topHUD.bounds.size.height;
    _tableView.frame = CGRectMake(0,size.height,size.width,size.height - Y);
    
    [self.view addSubview:_tableView];
}

- (void) handleDecoderMovieError: (NSError *) error
{
    // merged by hgc 2015 12 03 start
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
    //                                                        message:[error localizedDescription]
    //                                                       delegate:nil
    //                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
    //                                              otherButtonTitles:nil];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"播放错误", nil)
                                                        message:NSLocalizedString(@"文件打开失败", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"关闭", nil)
                                              otherButtonTitles:nil];
    // merged by hgc 2015 12 03 end
    [alertView show];
}

- (BOOL) interruptDecoder
{
    //if (!_decoder)
    //    return NO;
    return _interrupted;
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return KxMovieInfoSectionCount;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section) {
//        case KxMovieInfoSectionGeneral:
//            return NSLocalizedString(@"General", nil);
//        case KxMovieInfoSectionMetadata:
//            return NSLocalizedString(@"Metadata", nil);
//        case KxMovieInfoSectionVideo: {
//            NSArray *a = _decoder.info[@"video"];
//            return a.count ? NSLocalizedString(@"Video", nil) : nil;
//        }
//        case KxMovieInfoSectionAudio: {
//            NSArray *a = _decoder.info[@"audio"];
//            return a.count ?  NSLocalizedString(@"Audio", nil) : nil;
//        }
//        case KxMovieInfoSectionSubtitles: {
//            NSArray *a = _decoder.info[@"subtitles"];
//            return a.count ? NSLocalizedString(@"Subtitles", nil) : nil;
//        }
//    }
//    return @"";
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    switch (section) {
//        case KxMovieInfoSectionGeneral:
//            return KxMovieInfoGeneralCount;
//            
//        case KxMovieInfoSectionMetadata: {
//            NSDictionary *d = [_decoder.info valueForKey:@"metadata"];
//            return d.count;
//        }
//            
//        case KxMovieInfoSectionVideo: {
//            NSArray *a = _decoder.info[@"video"];
//            return a.count;
//        }
//            
//        case KxMovieInfoSectionAudio: {
//            NSArray *a = _decoder.info[@"audio"];
//            return a.count;
//        }
//            
//        case KxMovieInfoSectionSubtitles: {
//            NSArray *a = _decoder.info[@"subtitles"];
//            return a.count ? a.count + 1 : 0;
//        }
//            
//        default:
//            return 0;
//    }
//}
//
//- (id) mkCell: (NSString *) cellIdentifier
//    withStyle: (UITableViewCellStyle) style
//{
//    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier];
//    }
//    return cell;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell;
//    
//    if (indexPath.section == KxMovieInfoSectionGeneral) {
//        
//        if (indexPath.row == KxMovieInfoGeneralBitrate) {
//            
//            int bitrate = [_decoder.info[@"bitrate"] intValue];
//            cell = [self mkCell:@"ValueCell" withStyle:UITableViewCellStyleValue1];
//            cell.textLabel.text = NSLocalizedString(@"Bitrate", nil);
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d kb/s",bitrate / 1000];
//            
//        } else if (indexPath.row == KxMovieInfoGeneralFormat) {
//            
//            NSString *format = _decoder.info[@"format"];
//            cell = [self mkCell:@"ValueCell" withStyle:UITableViewCellStyleValue1];
//            cell.textLabel.text = NSLocalizedString(@"Format", nil);
//            cell.detailTextLabel.text = format ? format : @"-";
//        }
//        
//    } else if (indexPath.section == KxMovieInfoSectionMetadata) {
//        
//        NSDictionary *d = _decoder.info[@"metadata"];
//        NSString *key = d.allKeys[indexPath.row];
//        cell = [self mkCell:@"ValueCell" withStyle:UITableViewCellStyleValue1];
//        cell.textLabel.text = key.capitalizedString;
//        cell.detailTextLabel.text = [d valueForKey:key];
//        
//    } else if (indexPath.section == KxMovieInfoSectionVideo) {
//        
//        NSArray *a = _decoder.info[@"video"];
//        cell = [self mkCell:@"VideoCell" withStyle:UITableViewCellStyleValue1];
//        cell.textLabel.text = a[indexPath.row];
//        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        cell.textLabel.numberOfLines = 2;
//        
//    } else if (indexPath.section == KxMovieInfoSectionAudio) {
//        
//        NSArray *a = _decoder.info[@"audio"];
//        cell = [self mkCell:@"AudioCell" withStyle:UITableViewCellStyleValue1];
//        cell.textLabel.text = a[indexPath.row];
//        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        cell.textLabel.numberOfLines = 2;
//        BOOL selected = _decoder.selectedAudioStream == indexPath.row;
//        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//        
//    } else if (indexPath.section == KxMovieInfoSectionSubtitles) {
//        
//        NSArray *a = _decoder.info[@"subtitles"];
//        
//        cell = [self mkCell:@"SubtitleCell" withStyle:UITableViewCellStyleValue1];
//        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        cell.textLabel.numberOfLines = 1;
//        
//        if (indexPath.row) {
//            cell.textLabel.text = a[indexPath.row - 1];
//        } else {
//            cell.textLabel.text = NSLocalizedString(@"Disable", nil);
//        }
//        
//        const BOOL selected = _decoder.selectedSubtitleStream == (indexPath.row - 1);
//        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    }
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
//}
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == KxMovieInfoSectionAudio) {
//        
//        NSInteger selected = _decoder.selectedAudioStream;
//        
//        if (selected != indexPath.row) {
//            
//            _decoder.selectedAudioStream = indexPath.row;
//            NSInteger now = _decoder.selectedAudioStream;
//            
//            if (now == indexPath.row) {
//                
//                UITableViewCell *cell;
//                
//                cell = [_tableView cellForRowAtIndexPath:indexPath];
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                
//                indexPath = [NSIndexPath indexPathForRow:selected inSection:KxMovieInfoSectionAudio];
//                cell = [_tableView cellForRowAtIndexPath:indexPath];
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//        }
//        
//    } else if (indexPath.section == KxMovieInfoSectionSubtitles) {
//        
//        NSInteger selected = _decoder.selectedSubtitleStream;
//        
//        if (selected != (indexPath.row - 1)) {
//            
//            _decoder.selectedSubtitleStream = indexPath.row - 1;
//            NSInteger now = _decoder.selectedSubtitleStream;
//            
//            if (now == (indexPath.row - 1)) {
//                
//                UITableViewCell *cell;
//                
//                cell = [_tableView cellForRowAtIndexPath:indexPath];
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                
//                indexPath = [NSIndexPath indexPathForRow:selected + 1 inSection:KxMovieInfoSectionSubtitles];
//                cell = [_tableView cellForRowAtIndexPath:indexPath];
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            
//            // clear subtitles
//            _subtitlesLabel.text = nil;
//            _subtitlesLabel.hidden = YES;
//            @synchronized(_subtitles) {
//                [_subtitles removeAllObjects];
//            }
//        }
//    }
//}

-(UIImage*)getVideoDuartionAndThumb:(NSString *)videoURL
{
    
    //decoder = [[KxMovieDecoder alloc] init];
    
    [_decoder openFile:videoURL error:nil];
    NSArray *ar =  [_decoder decodeFrames:1.0f];
    KxMovieFrameVer2 *frame;
    
    for (KxMovieFrameVer2 *frames in ar)
    {
        if (frames.type == KxMovieFrameTypeVideo) {
            frame =  ar.lastObject;
            break;
        }
    }
    
    KxVideoFrameRGBVer2 *rgbFrame = (KxVideoFrameRGBVer2 *)frame;
    UIImage *imageKX = [rgbFrame asImage];
//    float videoDuartion = _decoder.duration;
//    [_decoder closeFile];
//    
//    
//    NSData *imageData = UIImageJPEGRepresentation(imageKX, 0.2f);
//    NSString *dic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//    
//    //创建视频文件夹
//    NSString *str = [dic stringByAppendingPathComponent:@"thumbs"];
//    str = [str stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",[[videoURL lastPathComponent] stringByDeletingPathExtension]]];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:str];
//    if (!existed)
//    {
//        [imageData writeToFile:str atomically:NO];
//    }
//    
//    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:str,@"image",[NSNumber numberWithFloat:videoDuartion],@"duration",nil];
//    [dictArray addObject:dict];
    
    return imageKX;
}


@end
