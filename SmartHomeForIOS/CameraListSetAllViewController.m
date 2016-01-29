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
//
@property UIActivityIndicatorView *activityIndicator;

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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self webViewDidStartLoad];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self webViewDidFinishLoad];
}

- (void)getCameraAllSetting{
    [DeviceNetworkInterface getDeviceAllSetting:self
     withBlock:^(NSString *result, NSString *message, NSString *recVolume, NSString *recLoop, NSString *alarmVolume, NSString *alarmLoop, NSError *error) {
         if (!error) {
             NSLog(@"camera getDeviceAllSetting result===%@",result);
             NSLog(@"camera rgetDeviceAllSetting mseeage===%@",message);
             if ([DeviceNetworkInterface isObjectNULLwith:recVolume]) {
                 self.recondByte.text = @"0.1";
             }else{
                 self.recondByte.text =recVolume;
             }
             if ([DeviceNetworkInterface isObjectNULLwith:alarmVolume]) {
                 self.recondByte.text = @"0.1";
             }else{
                 self.alarmByte.text = alarmVolume;
             }
             
             self.segmentRecordSet.selectedSegmentIndex = recLoop.integerValue;
             self.segmentAlarmSet.selectedSegmentIndex = alarmLoop.integerValue;
             
//             [self.segmentAlarmSet setSelectedSegmentIndex:recLoop.integerValue];

             stringRecordValue = recLoop;
             stringAlarmValue = alarmLoop;
         }
         else{
             NSLog(@"getDeviceAllSetting error");
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"网络错误" message:@"数据取得失败，请检查网络设置" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
             [alert show];
         }
         [self webViewDidFinishLoad];
         [self.navigationItem.rightBarButtonItem setEnabled:YES];
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
    //self.recondByte.text
    if ([DeviceCurrentVariable isPureFloat:self.recondByte.text]) {
        NSLog(@"isPureFloat");
    }else if ([DeviceCurrentVariable isPureInt:self.recondByte.text]){
        NSLog(@"isPureInt");
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"录像存储空间" message:@"只能输入浮点数或者整数，请重新输入" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
        return;
    }
    //self.recondByte.text
    if ([DeviceCurrentVariable isPureFloat:self.alarmByte.text]) {
        NSLog(@"isPureFloat");
    }else if ([DeviceCurrentVariable isPureInt:self.alarmByte.text]){
        NSLog(@"isPureInt");
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"报警存储空间" message:@"只能输入浮点数或者整数，请重新输入" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
        return;
    }
    //
    _recordToggleValue = stringRecordValue;
    _alarmToggleValue = stringAlarmValue;
    _recordValue =  self.recondByte.text;
    _alarmValue = self.alarmByte.text;
    NSLog(@"1_recordValue==%@",_recordValue);
    NSLog(@"2_recordToggleValue==%@",_recordToggleValue);
    NSLog(@"3_alarmValue==%@",_alarmValue);
    NSLog(@"4_alarmToggleValue==%@",_alarmToggleValue);
    //
    //2016 01 29
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    NSArray *setting = @[_recordValue,_recordToggleValue,_alarmValue,_alarmToggleValue];
    [DeviceNetworkInterface saveDeviceAllSettingWithSetArray:setting withBlock:^(NSString *result, NSString *message, NSError *error) {
        if (!error) {
            NSLog(@"camera getDeviceAllSetting result===%@",result);
            NSLog(@"camera rgetDeviceAllSetting mseeage===%@",message);
            //2016 01 26
            if ([result isEqualToString:@"success"]) {
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                //2016 01 26
            }else if([result isEqualToString:@"fail"]){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"保存失败" message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [alert show];
            }else if ([result isEqualToString:@"warning"]){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"保存提醒" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                [alert show];
                [alert setTag:2203];
            }
        }

        else{
            NSLog(@"getDeviceAllSetting error");
        }
        //2016 01 29
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
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

//alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2203) {
        NSLog(@"buttonIndex==%d",buttonIndex);
        if (buttonIndex == 1) {
            NSLog(@"buttonIndex==%d",buttonIndex);
        }
    }
}

//for 刷新数据时加载动画 add by hgc 2015 10 19 start
//开始加载动画
- (void)webViewDidStartLoad{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setTag:2204];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setAlpha:1];
    [self.view addSubview:view];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [self.activityIndicator setCenter:view.center];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setColor:[UIColor blackColor]];
    [view addSubview:self.activityIndicator];
    
    [self.activityIndicator startAnimating];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    label.text = @"数据加载中，请稍后...";
    [label setCenter:CGPointMake(view.center.x, view.center.y + 40)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
}
//结束加载动画
- (void)webViewDidFinishLoad{
    [self.activityIndicator stopAnimating];
    UIView *view = (UIView *)[self.view viewWithTag:2204];
    [view removeFromSuperview];
}
//for 刷新数据时加载动画 add by hgc 2015 10 19 end

@end
