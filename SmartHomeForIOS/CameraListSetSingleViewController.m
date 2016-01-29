//
//  CameraListSetSingleViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraListSetSingleViewController.h"
#import "CameraRenameViewController.h"
#import "DeviceNetworkInterface.h"
#import "CameraListViewController.h"

@interface CameraListSetSingleViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;
//btn
@property (strong, nonatomic) IBOutlet UIButton *nameSettingBTN;
@property (strong, nonatomic) IBOutlet UIButton *screenOverturnBTN;
@property (strong, nonatomic) IBOutlet UIButton *cameraRebootBTN;
//label
@property (strong, nonatomic) IBOutlet UILabel *labelCameraName;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraBrand;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraModel;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraWIFI;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraIPAdress;
@property (strong, nonatomic) IBOutlet UILabel *labelCameraVersion;
//segment
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentHomeMode;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentOutsideMode;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentSleepMode;
//switch
@property (strong, nonatomic) IBOutlet UISwitch *switchHomeMode;
@property (strong, nonatomic) IBOutlet UISwitch *switchOutMode;
@property (strong, nonatomic) IBOutlet UISwitch *switchSleepMode;
//slider
@property (strong, nonatomic) IBOutlet UISlider *sliderSensitivity;
//
@property UIActivityIndicatorView *activityIndicator;

@end

@implementation CameraListSetSingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"Welcome to 摄像头单独设置");
    NSLog(@"_deviceID=====%@",_deviceID);
    NSLog(@"onlining===%@",self.onlining);
    self.navigationItem.title = @"摄像头单独设置";

    //设置navigation右侧按钮
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveCameraSetting)];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //摄像头设置页 navigation右按钮
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"保存"
                                 //                                initWithImage:[UIImage imageNamed:@"history-bj"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(saveCameraSetting)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
//    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"history-bj"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    
//设置switch的样式 2015 11 04 hgc start
    
    self.switchHomeMode.onTintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:226/255.0 alpha:1];
    self.switchOutMode.onTintColor =[UIColor colorWithRed:0/255.0 green:160/255.0 blue:226/255.0 alpha:1];
    self.switchSleepMode.onTintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:226/255.0 alpha:1];
    
//设置switch的样式 2015 11 04 hgc end
    
//hgc 2015 10 19 设置页面与添加页面分开，故注释
//    self.screenOverturnBTN.hidden = NO;
//    self.cameraRebootBTN.hidden = NO;
//    if ([self.flg isEqualToString:@"0"]) {
//        self.navigationItem.title = @"自动添加摄像头";
//        self.screenOverturnBTN.hidden = YES;
//        self.cameraRebootBTN.hidden = YES;
//    }
//hgc 2015 10 19 设置页面与添加页面分开，故注释
    
    //
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self webViewDidStartLoad];
    //get data
    [DeviceNetworkInterface getCameraSettingWithDeviceId:_deviceID withBlock:^(NSString *result, NSString *message, NSArray *devices, NSError *error) {
        if (!error) {
            NSLog(@"camera getCameraSettingWithDeviceId result===%@",result);
            NSLog(@"camera getCameraSettingWithDeviceId mseeage===%@",message);
            NSLog(@"camera getCameraSettingWithDeviceId devices===%@",devices);
            //label set
            self.labelCameraName.text = devices[0][@"name"];
            self.labelCameraIPAdress.text = devices[0][@"addition"];
            self.labelCameraBrand.text = devices[0][@"brand"];
            self.labelCameraModel.text = devices[0][@"model"];
            self.labelCameraVersion.text = devices[0][@"version"];
            self.labelCameraWIFI.text = devices[0][@"wifi"];
            //segment value
            self.segmentHomeMode.selectedSegmentIndex = [devices[0][@"recSetInHome"] integerValue] ;
            self.segmentOutsideMode.selectedSegmentIndex = [devices[0][@"recSetOutHome"] integerValue];
            self.segmentSleepMode.selectedSegmentIndex = [devices[0][@"recSetInSleep"] integerValue];
            //swtich value
            //switchHomeMode
            if ([devices[0][@"alarmSetInHome"] isEqualToString:@"0"]) {
                self.switchHomeMode.on = FALSE;
            }else{
                self.switchHomeMode.on = TRUE;
            }
            //switchOutMode
            if ([devices[0][@"alarmSetOutHome"] isEqualToString:@"0"]) {
                self.switchOutMode.on = FALSE;
            }else{
                self.switchOutMode.on = TRUE;
            }
            //switchSleepMode
            if ([devices[0][@"alarmSetInSleep"] isEqualToString:@"0"]) {
                self.switchSleepMode.on = FALSE;
            }else{
                self.switchSleepMode.on = TRUE;
            }
            //slider
            self.sliderSensitivity.value =[devices[0][@"sensitivity"] integerValue];
        }
        else{
            NSLog(@"getDeviceAllSetting error");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头设置" message:@"设置数据取得失败，请重新登录再试" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self webViewDidFinishLoad];
    }];
    
    //设置修改Name按钮图片
    UIImage *imageGO = [UIImage imageNamed:@"iconfont-more-2"];
    [self.nameSettingBTN setImage:imageGO forState:UIControlStateNormal];

    //设置scrollview的范围
    [self.scroll setScrollEnabled:YES];
//    self.scroll.contentSize = CGSizeMake(320, 700);
    self.scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    // hgc 2015 11 04 added start
//    [self.sliderSensitivity setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    // hgc 2015 11 04 added end
    
//hgc 2015 11 11 add 离线摄像头设置页 start
    if ([self.onlining isEqualToString:@"0"]) {
        //btn
        [self.nameSettingBTN setEnabled:NO];
        [self.screenOverturnBTN setEnabled:NO];
        [self.cameraRebootBTN setEnabled:NO];
        //
        [self.segmentHomeMode setEnabled:NO];
        [self.segmentOutsideMode setEnabled:NO];
        [self.segmentSleepMode setEnabled:NO];
        //
        [self.switchHomeMode setEnabled:NO];
        [self.switchOutMode setEnabled:NO];
        [self.switchSleepMode setEnabled:NO];
        //
        [self.sliderSensitivity setEnabled:NO];
        //
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
//hgc 2015 11 11 add 离线摄像头设置页 end
}

- (void)saveCameraSetting{
    if ([self.labelCameraName.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"名称为空" message:@"名称不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }else{
        NSLog(@"Saving... saveCameraSetting");
        
        DeviceInfo *deviceInfo = [[DeviceInfo alloc]init];
        deviceInfo.devid = _deviceID;
        deviceInfo.name = self.labelCameraName.text;
        
        
        deviceInfo.recSetInHome = [NSString stringWithFormat:@"%ld",(long)self.segmentHomeMode.selectedSegmentIndex];
        deviceInfo.recSetOutHome = [NSString stringWithFormat:@"%ld",(long)self.segmentOutsideMode.selectedSegmentIndex];
        deviceInfo.recSetInSleep = [NSString stringWithFormat:@"%ld",(long)self.segmentSleepMode.selectedSegmentIndex];
        
        //switchHomeMode
        if (self.switchHomeMode.on == TRUE) {
            deviceInfo.alarmSetInHome = @"1";
        }else{
            deviceInfo.alarmSetInHome = @"0";
        }
        //switchOutSideMode
        if (self.switchOutMode.on == TRUE) {
            deviceInfo.alarmSetOutHome = @"1";
        }else{
            deviceInfo.alarmSetOutHome = @"0";
        }
        //swtichSleepMode
        if (self.switchSleepMode.on == TRUE) {
            deviceInfo.alarmSetInSleep = @"1";
        }else{
            deviceInfo.alarmSetInSleep = @"0";
        }
        
        deviceInfo.sensitivity = [NSString stringWithFormat:@"%d", (int)roundf(self.sliderSensitivity.value)];
        deviceInfo.wifi = self.labelCameraWIFI.text;
        //hgc
        //2016 01 29
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self webViewDidStartLoad];
        //请求添加
        [DeviceNetworkInterface updateCameraSettingWithDeviceInfo:deviceInfo withBlock:^(NSString *result, NSString *message, NSError *error) {
            //
            [self webViewDidFinishLoad];
            if (!error) {
                NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
                NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
                //alert提示
                if ([result isEqualToString:@"success"]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头设置" message:@"设置保存成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"设置保存失败" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                }
            }
            else{
                NSLog(@"getCameraSetting error");
                //alert提示
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头设置" message:@"设置保存失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
            }
            //2016 01 29
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nameSettingPressed:(UIButton *)sender {
    
//    CameraRenameViewController *cameraRenameVC = [[CameraRenameViewController alloc]initWithNibName:@"CameraRenameViewController" bundle:nil];
//    [self.navigationController pushViewController:cameraRenameVC animated:YES];
//    cameraRenameVC.cameraName = self.labelCameraName.text;

    //UIAlertView
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = self.labelCameraName.text;
    
    [alert setTag:2201];
    [alert show];
    NSLog(@"=============Camera Name Change start--------------");
}
//alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
// tag 2201
    if (alertView.tag == 2201) {
        if (buttonIndex == 1) {
            if ([[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"名称为空" message:@"名称不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
            }else{
                self.labelCameraName.text = [alertView textFieldAtIndex:0].text;
            }
        }
        NSLog(@"=============Camera Name Changed--------------");
    }
// tag 2202
    else if (alertView.tag == 2202){
//        if (buttonIndex == 2){
//            NSLog(@"shishi");
//            [DeviceNetworkInterface deleteFromDeviceListAndFileWithDeviceId:self.deviceID withBlock:^(NSString *result, NSString *message, NSError *error) {
//                if (!error) {
//                    NSLog(@"camera deleteFromDeviceListAndFileWithDeviceId result===%@",result);
//                    NSLog(@"camera deleteFromDeviceListAndFileWithDeviceId mseeage===%@",message);
//                    
//                    // 2. 更新UI
//                    if ([result isEqualToString:@"success"]) {
//                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除摄像头" message:@"删除摄像头成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [self.view addSubview:alert];
//                        [alert show];
//                        
//                        //superVC
//                        NSArray *ctrlArray = self.navigationController.viewControllers;
//                        for (UIViewController *ctrl in ctrlArray){
//                            if ([ctrl isKindOfClass:[CameraListViewController class]])
//                            {
//                                CameraListViewController *superVC = ctrl;
//                                //            superVC.deviceID = self.deviceID;
//                                [self.navigationController popToViewController:superVC animated:YES];
//                                break;
//                            }
//                            NSLog(@"ctrl ---- %@", ctrl);
//                        }
//                    }else{
//                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除摄像头失败" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [self.view addSubview:alert];
//                        [alert show];
//                    }
//                }
//                else{
//                    NSLog(@"deleleFromDeviceListWithDeviceId error");
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除摄像头" message:@"网络错误，删除摄像头失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [self.view addSubview:alert];
//                    [alert show];
//                }
//            }];
//        }else
        if (buttonIndex == 1){
            NSLog(@"foufou");
            NSLog(@"queding");
            [DeviceNetworkInterface deleleFromDeviceListWithDeviceId:self.deviceID withBlock:^(NSString *result, NSString *message, NSError *error) {
                if (!error) {
                    NSLog(@"camera deleleFromDeviceListWithDeviceId result===%@",result);
                    NSLog(@"camera deleleFromDeviceListWithDeviceId mseeage===%@",message);
                    
                    // 2. 更新UI
                    if ([result isEqualToString:@"success"]) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除摄像头" message:@"删除摄像头成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [self.view addSubview:alert];
                        [alert show];
                        
                        //superVC
                        NSArray *ctrlArray = self.navigationController.viewControllers;
                        for (UIViewController *ctrl in ctrlArray){
                            if ([ctrl isKindOfClass:[CameraListViewController class]])
                            {
                                CameraListViewController *superVC = ctrl;
                                //            superVC.deviceID = self.deviceID;
                                [self.navigationController popToViewController:superVC animated:YES];
                                break;
                            }
                            NSLog(@"ctrl ---- %@", ctrl);
                        }
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除摄像头失败" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [self.view addSubview:alert];
                        [alert show];
                    }
                }
                else{
                    NSLog(@"deleleFromDeviceListWithDeviceId error");
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除摄像头" message:@"网络错误，删除摄像头失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                }
            }];
        }else{
            NSLog(@"cancel");
            //cancel
        }
    }
    
    
    
}
//alertView delegate
- (void)willPresentAlertView:(UIAlertView *)alertView
{
}

- (IBAction)pictureTurnOver:(UIButton *)sender {
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"画面翻转" message:@"功能开发中，敬请期待……^_^" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [self.view addSubview:alert];
//    [alert show];
    
    //2016 01 12 start hgc
    NSString *title = NSLocalizedString(@"画面翻转", nil);
    NSString *message = NSLocalizedString(@"确定要翻转画面么", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        //old code
        [DeviceNetworkInterface setCameraPictureRolloverWithDeviceId:_deviceID withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
                NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
                //alert提示
                if ([result isEqualToString:@"success"]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"画面翻转" message:@"画面翻转成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                    //                [self.navigationController popViewControllerAnimated:YES];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"画面翻转失败" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                }
            }
            else{
                NSLog(@"getCameraSetting error");
                //alert提示
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"画面翻转" message:@"网络错误，画面翻转失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
            }
        }];
        //old code
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    //2016 01 12 end hgc
    
    
    
}

- (IBAction)deviceReBoot:(UIButton *)sender {
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"重启摄像头" message:@"功能开发中，敬请期待……^_^" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [self.view addSubview:alert];
//    [alert show];
    
    //2016 01 12 start hgc
    NSString *title = NSLocalizedString(@"重启摄像头", nil);
    NSString *message = NSLocalizedString(@"确定要重启么", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        
        [DeviceNetworkInterface setCameraRebootWithDeviceId:_deviceID withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
                NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
                //alert提示
                if ([result isEqualToString:@"success"]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"重启摄像头" message:@"重启摄像头成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                    //                [self.navigationController popViewControllerAnimated:YES];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"重启摄像头失败" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                }
            }
            else{
                NSLog(@"getCameraSetting error");
                //alert提示
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"重启摄像头" message:@"网络错误，重启摄像头失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
            }
        }];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    //2016 01 12 end hgc
    
    
}

// 2015 11 10 hgc add
- (IBAction)buttonCameraDeletePressed:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除摄像头"
                                                   message:@"确定要删除摄像头吗?"
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定",nil];
//                                             otherButtonTitles:@"是",@"否",nil];
    [alert show];
    [alert setTag:2202];
    
}


//for 刷新数据时加载动画 add by hgc 2015 10 19 start
//开始加载动画
- (void)webViewDidStartLoad{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setTag:2205];
    [view setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8f]];
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
    UIView *view = (UIView *)[self.view viewWithTag:2205];
    [view removeFromSuperview];
}
//for 刷新数据时加载动画 add by hgc 2015 10 19 end

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self webViewDidFinishLoad];

}

@end
