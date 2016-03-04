//
//  KxMovieAlarmRecordViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 16/3/2.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDPieLoopProgressView.h"

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface KxMovieAlarmRecordViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (readonly) BOOL playing;
+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;
+ (id) openH264File: (NSString *) path
         parameters: (NSDictionary *) parameters;
- (void) play;
- (void) pause;
- (void) toolBarHidden;
- (void) toolBarHiddens;
- (void) setAllControlHidden;
- (void) fullscreenMode: (BOOL) on;
- (void)bottomBarAppears;
- (Boolean) isEndOfFile;
- (id) movieReplay;

//hgc
@property SDPieLoopProgressView *myPregressView;

- (UIView *) frameView;
- (void)testClose;

//2016 01 28
- (void) awakeFromLocking;

//2016 02 26
@property Boolean isRTSPMovie;
- (void)setfullScreenOn;
- (void)setfullScreenOff;

@end
