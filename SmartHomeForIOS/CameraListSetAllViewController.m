//
//  CameraListSetAllViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraListSetAllViewController.h"
#import "DeviceNetworkInterface.h"

static NSString *toggleON = @"1";
static NSString *toggleOFF = @"0";
NSString *stringRecordValue;
NSString *stringAlarmValue;

@interface CameraListSetAllViewController ()
@property (strong, nonatomic) IBOutlet UITextField *recondByte;
@property (strong, nonatomic) IBOutlet UITextField *alarmByte;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentRecordSet;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentAlarmSet;

@end

@implementation CameraListSetAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"全局设置";
    
    //取得摄像头全局设置数据
    [self getCameraAllSetting];
    
    
    //摄像头全局设置页 navigation右按钮
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"保存"
                                 //                                initWithImage:[UIImage imageNamed:@"history-bj"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(saveSetting:)];
    self.navigationItem.rightBarButtonItem = rightBTN;
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    
// 2015 11 04 hgc start
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSetting:)];
//    rightBtn.title = @"AllSetting";
//    self.navigationItem.rightBarButtonItem = rightBtn;
//    
//    [self.navigationItem.backBarButtonItem setTintColor:[UIColor redColor]];
// 2015 11 04 hgc end
    
    
//    self.navigationItem.leftBarButtonItem.style= UIBarButtonSystemItemCancel;
//    self.navigationItem.leftBarButtonItem.title = @"back";
    
    //[self.view setBackgroundColor:[UIColor redColor]];
}

- (void)getCameraAllSetting{
    [DeviceNetworkInterface getDeviceAllSetting:self
     withBlock:^(NSString *result, NSString *message, NSString *recVolume, NSString *recLoop, NSString *alarmVolume, NSString *alarmLoop, NSError *error) {
         if (!error) {
             NSLog(@"camera getDeviceAllSetting result===%@",result);
             NSLog(@"camera rgetDeviceAllSetting mseeage===%@",message);
             self.recondByte.text =recVolume;
             self.alarmByte.text = alarmVolume;
             self.segmentRecordSet.selectedSegmentIndex = recLoop.integerValue;
             self.segmentAlarmSet.selectedSegmentIndex = alarmLoop.integerValue;
             
//             [self.segmentAlarmSet setSelectedSegmentIndex:recLoop.integerValue];
             
             stringRecordValue = recLoop;
             stringAlarmValue = alarmLoop;
         }
         else{
             NSLog(@"getDeviceAllSetting error");
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//save
- (void)saveSetting:(id)sender
{
    NSLog(@"Saving...");
    
    _recordToggleValue = stringRecordValue;
    _alarmToggleValue = stringAlarmValue;
    _recordValue =  self.recondByte.text;
    _alarmValue = self.alarmByte.text;
    NSLog(@"1_recordValue==%@",_recordValue);
    NSLog(@"2_recordToggleValue==%@",_recordToggleValue);
    NSLog(@"3_alarmValue==%@",_alarmValue);
    NSLog(@"4_alarmToggleValue==%@",_alarmToggleValue);
    
    NSArray *setting = @[_recordValue,_recordToggleValue,_alarmValue,_alarmToggleValue];
    [DeviceNetworkInterface saveDeviceAllSettingWithSetArray:setting withBlock:^(NSString *result, NSString *message, NSError *error) {
        if (!error) {
            NSLog(@"camera getDeviceAllSetting result===%@",result);
            NSLog(@"camera rgetDeviceAllSetting mseeage===%@",message);
        }
        else{
            NSLog(@"getDeviceAllSetting error");
        }
    }];
    
}

- (IBAction)recordToggleControls:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        stringRecordValue = toggleOFF;
    }else{
        stringRecordValue = toggleON;
    }
}
- (IBAction)alarmToggleControls:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        stringAlarmValue = toggleOFF;
    }else{
        stringAlarmValue = toggleON;
    }
}

- (IBAction)textFieldEditing:(id)sender {
    [self.recondByte resignFirstResponder];
    [self.alarmByte resignFirstResponder];
}


@end
