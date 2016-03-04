//
//  CameraAddManualViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraAddManualViewController.h"
#import "DeviceNetworkInterface.h"
#import "DeviceInfo.h"

static NSString *brand = @"brand";
static NSString *style = @"style";
NSString *pickerFlg;
//testflg
BOOL testFlg;

@interface CameraAddManualViewController ()
//old
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerBrand;
@property (strong, nonatomic) IBOutlet UITextField *labelBrand;
@property (strong, nonatomic) IBOutlet UITextField *labelStyle;
@property (strong, nonatomic) IBOutlet UIView *firstContentView;
//new
//textField
@property (strong, nonatomic) IBOutlet UITextField *textFieldDeviceName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldIPadress;
@property (strong, nonatomic) IBOutlet UITextField *textFieldIPadressPort;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUserName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUserPassword;
//label
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
//button
@property (strong, nonatomic) IBOutlet UIButton *buttonTest;
//
@property UIActivityIndicatorView *activityIndicator;

//nsarray
@property (strong,nonatomic) NSArray *arrayFromServer;
@property (strong,nonatomic) NSMutableArray *mutableArrayBrand;
@property (strong,nonatomic) NSMutableArray *mutableArrayModel;
//nsdictionary
@property (strong,nonatomic) NSMutableDictionary *dicForBrandModel;

//2016 03 05 check
@property (strong,nonatomic,nullable) NSString *backupModel;
@property (strong,nonatomic,nullable) NSString *backupBrand;
@property (strong,nonatomic,nullable) NSString *backupIPaddress;
@property (strong,nonatomic,nullable) NSString *backupIPaddressPort;
@property (strong,nonatomic,nullable) NSString *backupUserName;
@property (strong,nonatomic,nullable) NSString *backupUserPassword;


@end

@implementation CameraAddManualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //2016 02 24 category
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServerSessionOutOfTime) name:@"letuserlogout" object:nil];
    
    self.deviceInfo = [[DeviceInfo alloc]init];
    self.labelVersion.text = @"";
    self.labelWIFI.text = @"";
    
    //navigationItem
    self.navigationItem.title = @"手动添加";
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveCameraAddManual:)];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //摄像头addman页 navigation右按钮 2015 11 04 hgc start
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"保存"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(saveCameraAddManual:)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
    //2015 12 24
//    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"history-bj"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    //2015 12 24
    //摄像头addman页 navigation右按钮 2015 11 04 hgc end
    
    //getdata
    pickerFlg = brand;
    testFlg = NO;
    [self getCameraSetting:self];
    
    //设置scrollview的范围
    [self.scroll setScrollEnabled:YES];
    self.scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);

    //hgc 10 24
//    [self.firstContentView setNeedsLayout];
//    [self.firstContentView setBounds:CGRectMake(self.firstContentView.bounds.origin.x, self.firstContentView.bounds.origin.y, self.view.bounds.size.width, self.firstContentView.bounds.size.height)];
//    
//    [self.view layoutIfNeeded];


//    _brands = @[@"122313213112321",@"asdasdasdasdsad",@"f4r4r4r4r4r4r4",@"888888888888"];
//    _styles = @[@"11111111111111",@"2222222222",@"33333",@"666666666"];

// hgc 2015 11 04 added start
    [self.sliderSensitivity setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
// hgc 2015 11 04 added end
    
    //2016 01 20
    [self.navigationController setToolbarHidden:YES];
}

-(void)getCameraSetting:(id)sender
{
    self.mutableArrayModel = [[NSMutableArray alloc]init];
    self.mutableArrayBrand = [[NSMutableArray alloc]init];
    self.dicForBrandModel = [[NSMutableDictionary alloc]init];
    //
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self webViewDidStartLoad];
    //
    [DeviceNetworkInterface getDeviceSettingForManualAdd:self withBlock:^(NSString *result, NSString *message, NSArray *brands, NSError *error) {
        [self webViewDidFinishLoad];
        if (!error) {
            NSLog(@"camera getDeviceSettingForManualAdd result===%@",result);
            NSLog(@"camera getDeviceSettingForManualAdd mseeage===%@",message);
            NSLog(@"camera getDeviceSettingForManualAdd brands===%@",brands);
            //
            self.arrayFromServer = brands;
            //分别取得brand 和 model list
            for (NSDictionary *dic in brands) {
                NSLog(@"dic==%@",dic);
                [self.mutableArrayBrand addObject:dic[@"brand"]];
                [self.mutableArrayModel addObject:dic[@"model"]];
            }
            //2016 02 01
            NSLog(@"self.mutableArrayBrand====%@",self.mutableArrayBrand);
            NSSet *tempSet = [NSSet setWithArray:self.mutableArrayBrand];
            NSLog(@"tempSet==%@",[tempSet allObjects]);
            self.mutableArrayBrand = [NSMutableArray arrayWithArray:[tempSet allObjects]];
            NSLog(@"self.mutableArrayBrand====%@",self.mutableArrayBrand);
            //2016 02 01
            //对于不同的brand 建立model的响应
            for (NSString *brand in self.mutableArrayBrand) {
                NSMutableArray *tempArrayForModels = [[NSMutableArray alloc]init];
                for (NSDictionary *dicForBrand in brands) {
                    if ([dicForBrand[@"brand"] isEqualToString:brand]) {
                        [tempArrayForModels addObject:dicForBrand[@"model"]];
                    }
                }
                [self.dicForBrandModel setObject:tempArrayForModels forKey:brand];
            }
            NSLog(@"self.dicForBrandModel=%@",self.dicForBrandModel);
            NSLog(@"mutableArrayBrand=%@",self.mutableArrayBrand);
            NSLog(@"mutableArrayModel=%@",self.mutableArrayModel);
            
            //pickerView
//            self.pickerBrand.frame = CGRectMake(0, [UIScreen mainScreen].applicationFrame.size.height + 300, self.view.frame.size.width, 260);
            NSLog(@"[UIScreen mainScreen].bounds.size.height==%f",[UIScreen mainScreen].bounds.size.height);
            self.pickerBrand.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 300, self.view.frame.size.width, 260);
            self.pickerBrand.alpha = 0.8;
            self.pickerBrand.backgroundColor = [UIColor lightGrayColor];
            self.pickerBrand.hidden = YES;
            [self.pickerBrand reloadAllComponents];
        }
        else{
            NSLog(@"getCameraSetting error");
        }
        //
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ViewAnimation:(UIView*)view willHidden:(BOOL)hidden {
    
    [UIView animateWithDuration:0.3 animations:^{
        if (hidden) {
            NSLog(@"hiddenhidden");
            view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 300, self.view.frame.size.width, 260);
        } else {
            [view setHidden:hidden];
            view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 240, self.view.frame.size.width, 260);
//            view.frame = CGRectMake(0, [UIScreen mainScreen].applicationFrame.size.height - 250, self.view.frame.size.width, 260);
        }
    } completion:^(BOOL finished) {
        [view setHidden:hidden];
    }];
}

- (void)pickerViewDissmiss:(UIPickerView*)pickerView {
    [UIPickerView animateWithDuration:1 animations:^{
        [pickerView setAlpha:0.1];
    } completion:^(BOOL finished) {
        [pickerView setHidden:YES];
        [pickerView setAlpha:0.8];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// pickview datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerFlg isEqualToString:brand]) {
//        return _brands.count;
        return self.mutableArrayBrand.count;
    }else if([pickerFlg isEqualToString:style]) {
        NSArray *array = [[NSArray alloc]init];
        array = self.dicForBrandModel[self.labelBrand.text];
        NSLog(@"numberOfRowsInComponent of brand string==%@",self.labelBrand.text);
        NSLog(@"numberOfRowsInComponent of model array==%@",array);
        return array.count;
    }else
    {
        NSLog(@"big wrong happen");
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerFlg isEqualToString:brand]) {
        return self.mutableArrayBrand[row];
    }else{
        NSArray *array = [[NSArray alloc]init];
        array = self.dicForBrandModel[self.labelBrand.text];
        NSLog(@"array===%@",array);
        
        if (array.count == 1) {
//            self.labelStyle.text = array[0];
        }
        
        return array[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerFlg isEqualToString: brand]) {
        self.labelBrand.text = self.mutableArrayBrand[row];
    }else{
        NSArray *array = [[NSArray alloc]init];
        array = self.dicForBrandModel[self.labelBrand.text];
        NSLog(@"arrayselect[row]===%@",array[row]);
        self.labelStyle.text = array[row];
        [self performSelector:@selector(fillUserPwdIPPort) withObject:nil afterDelay:0.0f];
    }
//    [self ViewAnimation:self.pickerBrand willHidden:YES];
    [UIPickerView animateWithDuration:0.1 animations:^{
        [self.pickerBrand setAlpha:0.5];
    } completion:^(BOOL finished) {
        [self.pickerBrand setHidden:YES];
        [self.pickerBrand setAlpha:0.8];
    }];
    
    
}

- (IBAction)buttonBrandPressed:(id)sender {

    pickerFlg = brand;
    [self.pickerBrand reloadAllComponents];
    NSLog(@"brand is pressed!!");
    [self ViewAnimation:self.pickerBrand willHidden:NO];
    // style
    if (![self.labelStyle.text isEqualToString:@""]) {
        self.labelStyle.text = @"";
    }
    
}
- (IBAction)buttonStylePressed:(UIButton *)sender {
    
    if ([self.labelBrand.text isEqualToString: @""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请选择设备品牌" message:@"设备品牌不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }else{
        pickerFlg = style;
        [self.pickerBrand reloadAllComponents];
        [self ViewAnimation:self.pickerBrand willHidden:NO];
        NSLog(@"model is pressed!!");
    }
}
- (IBAction)textFieldDoneEditing:(UITextField *)sender {
//    [self ViewAnimation:self.pickerBrand willHidden:YES];
}

- (IBAction)textFieldEditing:(id)sender {
    [self.textFieldDeviceName resignFirstResponder];
    [self.textFieldIPadress resignFirstResponder];
    [self.textFieldIPadressPort resignFirstResponder];
    [self.textFieldUserName resignFirstResponder];
    [self.textFieldUserPassword resignFirstResponder];
    [self ViewAnimation:self.pickerBrand willHidden:YES];

}
- (void)saveCameraAddManual:(id)sender
{
    NSLog(@"Saving... saveCameraAddManual");
    //save之前test网络连接
    if (testFlg == NO) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:@"请通过连接测试后再试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
        return;
    }
    //测试链接与自动添加数据check 2016 03 05 start
    if ([self.backupUserName isEqualToString:self.textFieldUserName.text]&&
        [self.backupUserPassword isEqualToString:self.textFieldUserPassword.text]&&
        [self.backupIPaddress isEqualToString:self.textFieldIPadress.text]&&
        [self.backupIPaddressPort isEqualToString:self.textFieldIPadressPort.text]&&
        [self.backupBrand isEqualToString:self.labelBrand.text]&&
        [self.backupModel isEqualToString:self.labelStyle.text]
        ) {
        NSLog(@"check ok. go on!");
    }else{
        //        self.testFlg = NO;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"摄像头添加" message:@"相关信息已修改,请重新进行连接测试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
        return;
    }
    //end
    
    //save
    if ([DeviceNetworkInterface isNSStringSpacewith:self.textFieldDeviceName.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"设备名" message:@"设备名不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }else if ([DeviceNetworkInterface isNSStringSpacewith:self.textFieldIPadress.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"IP地址" message:@"IP不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }
    else if ([DeviceNetworkInterface isNSStringSpacewith:self.textFieldIPadress.text]&&[self.textFieldIPadressPort.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"IP端口" message:@"IPPort不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }
    else if ([DeviceNetworkInterface isNSStringSpacewith:self.textFieldUserName.text]&&[self.textFieldUserName.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名" message:@"用户名不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }
    else if ([DeviceNetworkInterface isNSStringSpacewith:self.textFieldUserPassword.text]&&[self.textFieldUserPassword.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"密码" message:@"密码不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }
    else if ([DeviceNetworkInterface isNSStringSpacewith:self.labelBrand.text]&&[self.labelBrand.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"品牌" message:@"品牌不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }
    else if ([DeviceNetworkInterface isNSStringSpacewith:self.deviceInfo.code]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"code" message:@"品牌不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
    }
    else if ([DeviceNetworkInterface isNSStringSpacewith:self.labelStyle.text]&&[self.labelStyle.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"型号" message:@"型号不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        self.deviceInfo.brand = self.labelBrand.text;
        self.deviceInfo.model = self.labelStyle.text;
        self.deviceInfo.addition = [NSString stringWithFormat:@"%@:%@",self.textFieldIPadress.text,self.textFieldIPadressPort.text];
        self.deviceInfo.type = @"0";
        self.deviceInfo.version = self.labelVersion.text;
        
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
        
        //
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self webViewDidStartLoad];
        //请求添加
        [DeviceNetworkInterface addDeviceAutomaticWithDeviceInfo:self.deviceInfo withBlock:^(NSString *result, NSString *message, NSError *error) {
            [self webViewDidFinishLoad];
            if (!error) {
                NSLog(@"camera addDeviceAutomaticWithDeviceInfo result===%@",result);
                NSLog(@"camera addDeviceAutomaticWithDeviceInfo mseeage===%@",message);
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
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }];
    }
}
- (IBAction)buttonTestPressed:(UIButton *)sender {
    NSLog(@"Network Testing......");

    //取得test参数
    NSString *addition = [NSString stringWithFormat:@"%@:%@",self.textFieldIPadress.text,self.textFieldIPadressPort.text];
    NSLog(@"addition=%@",addition);
    NSString *userid = self.textFieldUserName.text;
    NSString *passwd = self.textFieldUserPassword.text;
    NSString *brand = self.labelBrand.text;
    NSString *model = self.labelStyle.text;
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
    
    [self.buttonTest setEnabled:NO];
    //
    [DeviceNetworkInterface networkTestForDeviceAddWithAddition:addition andUserid:userid andPasswd:passwd andBrand:brand andModel:model withBlock:^(NSString *result, NSString *message, NSString *code, NSString *sensitivity, NSString *wifi, NSString *brand, NSString *model, NSString *version, NSString *alarmflg, NSError *error) {
        if (!error) {
            NSLog(@"camera getDeviceSettingWithBrand result===%@",result);
            NSLog(@"camera getDeviceSettingWithBrand mseeage===%@",message);
            if ([result isEqualToString:@"success"]) {
                //2016 03 05 数据check
                self.backupBrand = brand;
                self.backupModel = model;
                self.backupIPaddress = self.textFieldIPadress.text;
                self.backupIPaddressPort = self.textFieldIPadressPort.text;
                self.backupUserName = self.textFieldUserName.text;
                self.backupUserPassword = self.textFieldUserPassword.text;
                //
                self.labelBrand.text = brand;
                self.labelStyle.text = model;
                // end
                
                self.deviceInfo.code = code;
                NSLog(@"code==%@",code);
//                self.sliderSensitivity.value = sensitivity.floatValue;
                self.labelWIFI.text = wifi;
                self.labelVersion.text =version;
                
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
                
                testFlg = YES;
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:[NSString stringWithFormat:@"连接测试错误:%@",message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.view addSubview:alert];
                [alert show];
                
                testFlg = NO;
            }
        }
        else{
            NSLog(@"networkTestForDeviceAddWithAddition error");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"连接测试" message:@"连接测试失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.view addSubview:alert];
            [alert show];
            testFlg = NO;
        }
        //
        [self.buttonTest setEnabled:YES];
    }];
    
}

- (IBAction)finishEdit:(id)sender {
    [sender resignFirstResponder];
}


//for 刷新数据时加载动画 add by hgc 2015 10 19 start
//开始加载动画
- (void)webViewDidStartLoad{
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

- (void)fillUserPwdIPPort{
    NSLog(@"fillUserPwdIPPort");
    NSLog(@"self.labelBrand==%@",self.labelBrand.text);
    NSLog(@"labelStyle==%@",self.labelStyle.text);
    for (NSDictionary *dic in self.arrayFromServer) {
        NSLog(@"fillUserPwdIPPortdic==%@",dic);
        if ([self.labelBrand.text isEqualToString:dic[@"brand"]]) {
            if ([self.labelStyle.text isEqualToString:dic[@"model"]]) {
                NSLog(@"dic passwd==%@",dic[@"passwd"]);
                NSLog(@"dic port==%@",dic[@"port"]);
                NSLog(@"dic userid==%@",dic[@"userid"]);
                self.textFieldIPadressPort.text = dic[@"port"];
                self.textFieldUserName.text = dic[@"userid"];
                self.textFieldUserPassword.text = dic[@"passwd"];
                return;
            }
        }
    }
    NSLog(@"impossible is nothing");
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.buttonTest setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationController setToolbarHidden:YES];
    [self webViewDidFinishLoad];
}

@end
