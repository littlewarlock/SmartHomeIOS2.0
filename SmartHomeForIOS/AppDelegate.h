//
//  AppDelegate.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CyberLink/UPnPAV.h>
@class CGUpnpAvRenderer;
@class CGUpnpAvController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CGUpnpControlPointDelegate,CGUpnpDeviceDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *appArray;//存储所有的app相关信息
@property (strong, nonatomic) NSMutableArray *selectedAppArray;//存储所有的app相关信息

@property (nonatomic, retain)CGUpnpAvRenderer* avRenderer;
/** 存储所有图片的url */
@property (strong, nonatomic) NSMutableArray *picUrl;
/** 存储所有视频的url */
@property (strong, nonatomic) NSMutableArray *videoUrl;

@property (nonatomic, retain)CGUpnpAvController *avCtrl;
/** 存储所有render */
@property (nonatomic, retain)NSArray* dataSource;
@end

