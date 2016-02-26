//
//  CameraDetailViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KxMovieViewController.h"

@interface CameraDetailViewController : UIViewController

@property(strong,nonatomic)NSString *deviceID;
@property(strong,nonatomic)NSString *deviceName;
@property(strong,nonatomic)MPMoviePlayerController *MPC;
@property(strong,nonatomic)NSString *realTimeUrl;

//hgc 2015 10 26
@property(strong,nonatomic)NSString *onlining;
//hgc 2016 01 21
@property(strong,nonatomic)NSString *isFromAlarmDetail;

- (IBAction)reloadData:(id)sender;

@end
