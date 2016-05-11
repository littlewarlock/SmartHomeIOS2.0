//
//  ViewController.h
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>
#import "SDPieLoopProgressView.h"

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface KxMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
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
//2016 03 10
@property Boolean isAwakeFromLock;
//2016 03 14
@property NSString *deviceID;
//2016 03 17
- (void)reStartStream;
@property Boolean isBeRestartStreamByHanded;


@end
