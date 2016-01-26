//
//  CameraRecodHistoryCanlender.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/10/21.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface CameraRecodHistoryCanlender : UIViewController<JTCalendarDataSource>


@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;

@property (strong, nonatomic) JTCalendar *calendar;
//hgc added
@property (strong,nonatomic) NSDate *inputDate;
@property (strong,nonatomic) NSDate *outputDate;
@property (strong,nonatomic) NSString *deviceID;
//

@end
