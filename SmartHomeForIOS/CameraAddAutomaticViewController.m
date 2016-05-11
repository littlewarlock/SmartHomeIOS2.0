//
//  CameraAddAutomaticViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraAddAutomaticViewController.h"
#import "DeviceNetworkInterface.h"

@interface CameraAddAutomaticViewController ()
//button
@property (strong, nonatomic) IBOutlet UIButton *buttonTest;
//scroll
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//textField
@property (strong, nonatomic) IBOutlet UITextField *textFieldDeviceName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldIPadress;
@property (strong, nonatomic) IBOutlet UITextField *textFieldIPadressPort;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUserName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUserPassword;
//label
@property (strong, nonatomic) IBOutlet UILabel *labelBrand;
@property (strong, nonatomic) IBOutlet UILabel *labelModel;
@property (strong, nonatomic) IBOutlet UILabel *labelWIFI;
@property (strong, nonatomic) IBOutlet UILabel *labelVersion;
//segment
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentHomeMode;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentOutsideMode;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentSleepMode;
//switch
@property (strong, nonatomic) IBOutlet UISwitch *switchHomeMode;
@property (strong, nonatomic) IBOutlet UISwitch *switchOutSideMode;
@property (strong, nonatomic) IBOutlet UISwitch *swtichSleepMode;
//slider
@property (strong, nonatomic) IBOutlet UISlider *sliderSensitivity;

@property BOOL testFlg;
//2016 03 05
@property (strong,nonatomic,nullable) NSString *backupUserName;
@property (strong,nonatomic,nullable) NSString *backupUserPassword;

//
@property UIActivityIndicatorView *activityIndicator;
@end

@implementation CameraAddAutomaticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //2016 02 24 category
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServerSessionOutOfTime) name:@"letuserlogout" object:nil];
    
    NSLog(@"%@",self.deviceInfo);
    
    if (
        ([DeviceNetworkInterface isObjectNULLwith:self.brand])
        || ([DeviceNetworkInterface isObjectNULLwith:self.model])
        || ([DeviceNetworkInterface isObjectNULLwith:self.deviceInfo.addition])
        || ([DeviceNetworkInterface isObjectNULLwith:self.deviceInfo.brand])
        || ([DeviceNetworkInterface isObjectNULLwith:self.deviceInfo.version])
        || ([DeviceNetworkInterface isObjectNULLwith:self.deviceInfo.model])
        || ([DeviceNetworkInterface isObjectNULLwith:self.deviceInfo.wifi])
        || ([DeviceNetworkInterface isObjectNULLwith:self.deviceInfo.sensitivity])
        )
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else
    {
        NSLog(@"check ok.");
    }
    
    
    self.navigationItem.title = @"自动添加";
    //testflg
    self.testFlg = NO;

    
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveCameraAddAutomatic:)];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //摄像头addman页 navigation右按钮 2015 11 04 hgc start
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"保存"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(saveCameraAddAutomatic:)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
//    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"history-bj"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    //摄像头addman页 navigation右按钮 2015 11 04 hgc end
    
    
    //取得摄像头数据 gedata
    [self getCameraSetting:self];
    
    //设置scrollview的范围
    [self.scrollView setScrollEnabled:YES];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    //为界面控件传值
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.userid);
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.passwd);
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.addition);
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.brand);
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.code);
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.model);
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.type);
    NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.version);
    
    //2015 12 22 hgc added
    NSArray *array = [self.deviceInfo.addition componentsSeparatedByString:@":"];
    self.textFieldIPadress.text = array[0];
    //2016 01 29
    self.textFieldIPadressPort.text = array[1];
//    self.textFieldIPadress.text = self.deviceInfo.addition;
    //2015 12 22 hgc ended
    self.labelBrand.text = self.deviceInfo.brand;
    self.labelModel.text = self.deviceInfo.model;
    self.labelVersion.text = self.deviceInfo.version;
    self.labelWIFI.text = self.deviceInfo.wifi;
    self.sliderSensitivity.value = self.deviceInfo.sensitivity.floatValue;

    // hgc 2015 11 04 added start
    [self.sliderSensitivity setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    // hgc 2015 11 04 added end
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //2016 01 20
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveCameraAddAutomatic:(id)sender
{
    
    if (self.testFlg == NO) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:@"请通过连接测试后再试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
        return;
    }
    //测试链接与自动添加数据check 2016 03 05 start
    if ([self.backupUserName isEqualToString:self.textFieldUserName.text]&&[self.backupUserPassword isEqualToString:self.textFieldUserPassword.text]) {
        NSLog(@"check ok. go on!");
    }else{
//        self.testFlg = NO;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:@"您更改了摄像头信息，请重新测试连接" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
        return;
    }
    //end
    
    if ([DeviceNetworkInterface isNSStringSpacewith:self.textFieldDeviceName.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"设备名" message:@"设备名不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }else{
        NSLog(@"Saving... saveCameraAddAutomatic");
        
        self.deviceInfo.recSetInHome = [NSString stringWithFormat:@"%ld",(long)self.segmentHomeMode.selectedSegmentIndex];
        self.deviceInfo.recSetOutHome = [NSString stringWithFormat:@"%ld",(long)self.segmentOutsideMode.selectedSegmentIndex];
        self.deviceInfo.recSetInSleep = [NSString stringWithFormat:@"%ld",(long)self.segmentSleepMode.selectedSegmentIndex];
        //switchHomeMode
        if (self.switchHomeMode.on == TRUE) {
            self.deviceInfo.alarmSetInHome = @"1";
        }else{
            self.deviceInfo.alarmSetInHome = @"0";
        }
        //switchOutSideMode
        if (self.switchOutSideMode.on == TRUE) {
            self.deviceInfo.alarmSetOutHome = @"1";
        }else{
            self.deviceInfo.alarmSetOutHome = @"0";
        }
        //swtichSleepMode
        if (self.swtichSleepMode.on == TRUE) {
            self.deviceInfo.alarmSetInSleep = @"1";
        }else{
            self.deviceInfo.alarmSetInSleep = @"0";
        }
        self.deviceInfo.userid = self.textFieldUserName.text;
        self.deviceInfo.passwd = self.textFieldUserPassword.text;
        self.deviceInfo.port = self.textFieldIPadressPort.text;
        self.deviceInfo.name = self.textFieldDeviceName.text;
        self.deviceInfo.sensitivity = [NSString stringWithFormat:@"%d", (int)roundf(self.sliderSensitivity.value)];
        self.deviceInfo.wifi = self.labelWIFI.text;
        
//        NSLog(self.deviceInfo.recSetInSleep);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.userid);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.passwd);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.addition);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.port);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.brand);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.code);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.model);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.type);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.version);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.recSetInHome);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.recSetOutHome);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.recSetInSleep);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.alarmSetInHome);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.alarmSetOutHome);
        NSLog(@"self.deviceInfo.userid=%@",self.deviceInfo.alarmSetInSleep);
        NSLog(@"self.deviceInfo.alarmflg=%@",self.deviceInfo.alarmflg);
//        DeviceInfo *df = self.deviceInfo;
        //
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self webViewDidStartLoad];
//请求添加
        [DeviceNetworkInterface addDeviceAutomaticWithDeviceInfo:self.deviceInfo withBlock:^(NSString *result, NSString *message, NSError *error) {
            //
            [self webViewDidFinishLoad];
            if (!error) {
                NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
                NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
                //alert提示
                if ([result isEqualToString:@"success"]) {
                    if ([message isEqualToString:@""]) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:@"摄像头添加成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [self.view addSubview:alert];
                        [alert show];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [self.view addSubview:alert];
                        [alert show];
                    }
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加失败" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [self.view addSubview:alert];
                    [alert show];
                }
            }
            else{
                NSLog(@"getCameraSetting error");
                //alert提示
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:@"摄像头添加失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
            }
            //
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }];

    }
    
}

-(void)getCameraSetting:(id)sender
{
    //2016 01 29
    [self webViewDidStartLoad];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    //
    [DeviceNetworkInterface getDeviceSettingWithBrand:_brand andModel:_model withBlock:^(NSString *result, NSString *message, NSArray *brands, NSError *error) {
        if (!error) {
            NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
            NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
            NSLog(@"camera getDeviceSettingWithBrand brands===%@",brands);

            
            // hgc 2015 11 05 start
            // hgc 2015 12 30 start
            if ([DeviceNetworkInterface isObjectNULLwith:brands]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请联系供应商" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            // hgc 2015 12 30 end
            // hgc 2015 12 31 start
            else if (brands.count <= 0) {
                NSLog(@"warning!!!!! brand.count ==0");
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//                if (self.navigationController) {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
            }
            // hgc 2015 12 31 end
            else if (
                 ([DeviceNetworkInterface isObjectNULLwith:brands[0][@"userid"]])
                || ([DeviceNetworkInterface isObjectNULLwith:brands[0][@"passwd"]])
//                || ([DeviceNetworkInterface isObjectNULLwith:brands[0][@"port"]])
                )
            {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//                if (self.navigationController) {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
            }else
            {
                NSLog(@"check ok.");
                self.textFieldUserName.text = brands[0][@"userid"];
                self.textFieldUserPassword.text = brands[0][@"passwd"];
//                self.textFieldIPadressPort.text =brands[0][@"port"];
            }
            //hgc 2015 11 05 end
            
            if ([DeviceNetworkInterface isObjectNULLwith:self.textFieldUserName.text]) {
                self.textFieldUserName.text = @"";
            }else{
                //
            }
            //
            if ([DeviceNetworkInterface isObjectNULLwith:self.textFieldUserPassword.text]) {
                self.textFieldUserPassword.text = @"";
            }else{
                //
            }
            //
//            if ([DeviceNetworkInterface isObjectNULLwith:self.textFieldIPadressPort.text]) {
//                self.textFieldIPadressPort.text = @"";
//            }else{
//                //
//            }
        }
        else{
            NSLog(@"getCameraSetting error");
            //alert提示
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:@"摄像头数据取得失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        //2016 01 29
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self webViewDidFinishLoad];
    }];
}
- (IBAction)buttonTestPressed:(UIButton *)sender {
    NSLog(@"Network Testing......");
//    NSString *addition = [NSString stringWithFormat:@"%@:%@",self.textFieldIPadress.text,self.textFieldIPadressPort.text];
    //2015 12 22 hgc started
    NSString *addition = self.deviceInfo.addition;
//    NSString *addition = self.textFieldIPadress.text;
    //2015 12 22 hgc ended
    NSLog(@"addition=%@",addition);
    NSString *userid = self.textFieldUserName.text;
    NSString *passwd = self.textFieldUserPassword.text;
    NSString *brand = self.labelBrand.text;
    NSString *model = self.labelModel.text;
    //
    //
    if ([DeviceNetworkInterface isNSStringSpacewith:addition]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"IP不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }else if([DeviceNetworkInterface isNSStringSpacewith:userid]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"用户名不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }else if([DeviceNetworkInterface isNSStringSpacewith:passwd]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"密码不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }else if([DeviceNetworkInterface isNSStringSpacewith:brand]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"品牌不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }else if([DeviceNetworkInterface isNSStringSpacewith:model]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"型号不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //
    [self.buttonTest setEnabled:NO];
    //
    [DeviceNetworkInterface newNetworkTestForDeviceAddWithAddition:addition andUserid:userid andPasswd:passwd withBlock:^(NSString *result, NSString *message, NSString *code, NSString *sensitivity, NSString *wifi, NSString *brand, NSString *model, NSString *version, NSString *alarmflg, NSError *error) {
        if (!error) {
            NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
            NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
            if ([result isEqualToString:@"success"]) {
                //2016 03 05 数据check
                self.backupUserName = self.textFieldUserName.text;
                self.backupUserPassword = self.textFieldUserPassword.text;
                // end
                //hgc 自动添加时不需要网络测试的code
                 self.deviceInfo.code = code;
                //hgc end
                //2015 11 18
                if (
                    ([DeviceNetworkInterface isObjectNULLwith:brand])
                    || ([DeviceNetworkInterface isObjectNULLwith:model])
                    || ([DeviceNetworkInterface isObjectNULLwith:version])
                    || ([DeviceNetworkInterface isObjectNULLwith:sensitivity])
//                    || ([DeviceNetworkInterface isObjectNULLwith:wifi])
                    )
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    if (self.navigationController) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }else
                {
                    NSLog(@"check ok.");
                }
                //2015 11 18
                self.labelBrand.text = brand;
                self.labelModel.text = model;
                self.labelVersion.text = version;
                self.labelWIFI.text = wifi;
//                self.sliderSensitivity.value = [sensitivity floatValue];
                self.deviceInfo.brand = brand;
                self.deviceInfo.model = model;
                //2015 11 18
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"连接测试成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
                
                //2016 03 03 start hgc
                if ([alarmflg isEqualToString:@"1"]) {
                    self.deviceInfo.alarmflg = alarmflg;
                }else{
                    self.deviceInfo.alarmflg = @"0";
                }
                
                if ([alarmflg isEqualToString:@"0"]) {
                    [self.switchHomeMode setOn:FALSE animated:YES];
                    [self.switchOutSideMode setOn:FALSE animated:YES];
                    [self.swtichSleepMode setOn:FALSE animated:YES];
                    //
                    [self.swtichSleepMode setUserInteractionEnabled:NO];
                    [self.switchOutSideMode setUserInteractionEnabled:NO];
                    [self.switchHomeMode setUserInteractionEnabled:NO];
                    //
                    [self.segmentHomeMode setEnabled:FALSE forSegmentAtIndex:2];
                    [self.segmentOutsideMode setEnabled:FALSE forSegmentAtIndex:2];
                    [self.segmentSleepMode setEnabled:FALSE forSegmentAtIndex:2];
                }
                //2016 03 03 end hgc
                
                self.testFlg = YES;
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:[NSString stringWithFormat:@"连接测试错误:%@",message]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
                self.testFlg = NO;
            }
        }
        else{
            NSLog(@"networkTestForDeviceAddWithAddition error");
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"网络错误，连接测试失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.view addSubview:alert];
            [alert show];
            
            self.testFlg = NO;
        }
        //
        [self.buttonTest setEnabled:YES];
    }];
// 2015 11 18
    /*
    [DeviceNetworkInterface networkTestForDeviceAddWithAddition:addition andUserid:userid andPasswd:passwd andBrand:brand andModel:model withBlock:^(NSString *result, NSString *message, NSString *code, NSString *sensitivity, NSString *wifi, NSString *version, NSError *error) {
        if (!error) {
            NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
            NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
            if ([result isEqualToString:@"success"]) {
                //hgc 自动添加时不需要网络测试的code
//                self.deviceInfo.code = code;
//hgc end
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"连接测试成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
                
                self.testFlg = YES;
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:[NSString stringWithFormat:@"连接测试错误:%@",message]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
                self.testFlg = NO;
            }
        }
        else{
            NSLog(@"networkTestForDeviceAddWithAddition error");

            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"网络错误，连接测试失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.view addSubview:alert];
            [alert show];
            
            self.testFlg = NO;
        }
    }];
2015 11 18  */
     
}

- (IBAction)textFieldEditing:(id)sender {
    [self.textFieldDeviceName resignFirstResponder];
    [self.textFieldIPadress resignFirstResponder];
    [self.textFieldIPadressPort resignFirstResponder];
    [self.textFieldUserName resignFirstResponder];
    [self.textFieldUserPassword resignFirstResponder];
}
- (IBAction)finishEdit:(id)sender {
    [sender resignFirstResponder];
}

//for 刷新数据时加载动画 add by hgc 2015 10 19 start
//开始加载动画
- (void)webViewDidStartLoad{
    //
    [self textFieldEditing:self];
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setTag:2206];
    [view setBackgroundColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.8]];
    
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
    UIView *view = (UIView *)[self.view viewWithTag:2206];
    [view removeFromSuperview];
}
//for 刷新数据时加载动画 add by hgc 2015 10 19 end

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.buttonTest setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self webViewDidFinishLoad];
}


@end
