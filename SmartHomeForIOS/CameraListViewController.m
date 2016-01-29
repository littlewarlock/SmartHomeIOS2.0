//
//  CameraListViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraListViewController.h"
#import "TestTableViewCell.h"
#import "CameraAddViewController.h"
#import "CameraListSetAllViewController.h"
#import "CameraDetailViewController.h"
#import "CameraListSetSingleViewController.h"
#import "DeviceNetworkInterface.h"
#import <AVOSCloud/AVOSCloud.h>

static NSString *CellTableIdentifier = @"CellTableIdentifier";

@interface CameraListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl *control;
@property UIActivityIndicatorView *activityIndicator;

@end

@implementation CameraListViewController
@synthesize control;
@synthesize tableView;


//2016 01 20
- (BOOL)isCurrentViewControllerVisible
{
    return (self.isViewLoaded && self.view.window);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //2016 01 05 hgc channels
//    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
//    [currentInstallation addUniqueObject:@"234" forKey:@"channels"];
//    [currentInstallation saveInBackground];

//    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
//    [currentInstallation removeObject:@"Giants" forKey:@"channels"];
//    [currentInstallation saveInBackground];
    //
    NSArray *subscribedChannels = [AVInstallation currentInstallation].channels;
    NSLog(@"subscribedChannels===%@",subscribedChannels);
    //2016 01 05 hgc channels
    
    //navigation
    self.navigationItem.title = @"监控管理";
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(cameraAllSetting:)];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //摄像头list页 navigation右按钮
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"设置"
                                 //                                initWithImage:[UIImage imageNamed:@"history-bj"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(cameraAllSetting:)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
    //2016 01 09 start
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.0/255 green:153.0/255 blue:255.0/255 alpha:1]];
    //2016 01 09 end
    
    
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
//    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    
    // hgc 2015 11 09 start
    
    CGRect rect = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,45);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //2015 11 04
    btn.frame = rect;
    [btn setTitle:@"添加摄像头" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [btn setImage:[UIImage imageNamed:@"add-icon"] forState:UIControlStateNormal];
    [btn setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    //2015 11 04
    
    CGRect rect1=CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 45);
    UIView *view = [[UIView alloc] initWithFrame:rect1];
    [view addSubview:btn];
    
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:view];
    UIBarButtonItem *left=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [self setToolbarItems:[NSArray arrayWithObjects:left,barButton,right,nil] animated:YES];
    
// hgc 2015 11 09 end
    
    
    //hgc 2016 01 11 start
//    [self webViewDidStartLoad];
    //hgc 2016 01 11 end
    
    [self setupRefresh:self];

    //构造tableView
    self.tableView = (id)[self.view viewWithTag:1];
    self.tableView.rowHeight = 208;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 10;
    [self.tableView setContentInset:contentInset];
    
    UINib *nib = [UINib nibWithNibName:@"TestTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellTableIdentifier];

    [self.tableView addSubview:self.control];
}

-(void)setupRefresh:(id)sender{

    //1.添加刷新控件
    self.control=[[UIRefreshControl alloc]init];
    self.control.tintColor = [UIColor grayColor];
    self.control.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [self.control addTarget:self action:@selector(loadData:) forControlEvents:UIControlEventValueChanged];
    
    //2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    [self.control beginRefreshing];
    
    // 3.加载数据
//    [self loadData:self.control];
}


-(void)loadData:(id)sender{

    [DeviceNetworkInterface getDeviceList:self withBlock:^(NSArray *deviceList, NSError *error) {
        //
        if (self.isCurrentViewControllerVisible) {
            [self.navigationController setToolbarHidden:NO animated:YES];
            [self.navigationController.toolbar setUserInteractionEnabled:YES];
        }else{
            NSLog(@"cameralistVC is gone");
        }
        //
        if (!error) {
//            _devices = deviceList;
            self.devices = deviceList;
            NSLog(@"self.devices===%@",self.devices);
            
            //2015 12 24 hgc
            NSLog(@"====%d",self.navigationController.toolbar.userInteractionEnabled);
            if (self.devices.count >= 1000 ) {
                NSLog(@"self.devices.count");
                [self.navigationController setToolbarHidden:YES animated:YES];
                [self.navigationController.toolbar setUserInteractionEnabled:NO];
            }
            
            NSLog(@"====%d",self.navigationController.toolbar.userInteractionEnabled);
            //2015 12 24 hgc
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [sender endRefreshing];
        }
        else{
            NSLog(@"**************NetWork Request errrr************************");
            [sender endRefreshing];
        }
        [self webViewDidFinishLoad];
    }];
}

//for 刷新数据时加载动画 add by hgc 2015 10 19 start
//开始加载动画
- (void)webViewDidStartLoad{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view setTag:103];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view setAlpha:1];
    [self.view addSubview:view];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [self.activityIndicator setCenter:view.center];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setColor:[UIColor blackColor]];
    [view addSubview:self.activityIndicator];
    
    [self.activityIndicator startAnimating];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    label.text = @"数据加载中，请等待...";
    [label setCenter:CGPointMake(view.center.x, view.center.y + 40)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
}
//结束加载动画
- (void)webViewDidFinishLoad{
    [self.activityIndicator stopAnimating];
    UIView *view = (UIView *)[self.view viewWithTag:103];
    [view removeFromSuperview];
}
//for 刷新数据时加载动画 add by hgc 2015 10 19 end

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self webViewDidStartLoad];
    
//    [self.control beginRefreshing];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self.navigationController setToolbarHidden:NO animated:YES];
    NSLog(@"hellohellohello");
    self.navigationController.toolbar.userInteractionEnabled = NO;
    NSLog(@"====%d",self.navigationController.toolbar.userInteractionEnabled);
    NSLog(@"hellohellohello121212");
    //2016 01 12
    [self loadData:self.control];
// 2015 12 24 start
//    [UIView animateWithDuration:2.0f animations:^{
    NSLog(@"toolbartoolbar");
    
//    [self.navigationController.toolbar setTintColor:[UIColor grayColor]];
//    }];
// 2015 12 24 end

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController.toolbar setUserInteractionEnabled:NO];
    //2016 01 27
    if (self.activityIndicator) {
        [self webViewDidFinishLoad];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
//    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://admin:888888@172.16.9.28:81/snapshot.cgi"]];
    
    // hgc add debug
//    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *documentsDirectory=[paths objectAtIndex:0];
//    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:@"saveFore.jpg"];
//    NSLog(@"savedImagePath==%@",savedImagePath);
//    [data writeToFile:savedImagePath atomically:YES];
    // hgc add
    
    result = [UIImage imageWithData:data];
    
    UIImage *placeholder = [UIImage imageNamed:@"camera"];
    if ([DeviceNetworkInterface isObjectNULLwith:result]) {
        result =  placeholder;
    }
    
    return result;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"self.devices.+++++count===%d",self.devices.count);
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath


{
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier
                                                                forIndexPath:indexPath];
    
    NSDictionary *rowData = self.devices[indexPath.row];
    
    // hgc 2015 11 05 start
    if (
        ([DeviceNetworkInterface isObjectNULLwith:rowData[@"name"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"addition"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"onlining"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"monitoring"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"recording"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"mode"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"alarming"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"devid"]])
        || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"type"]])
        )
    {
        NSLog(@"系统错误happen");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        NSLog(@"check ok.");
    }
    //hgc 2015 11 05 end
    
    
    NSLog(@"addition==%@",[rowData objectForKey:@"addition"]);
    
    cell.label.text =rowData[@"name"];
    cell.labelr1.text=rowData[@"addition"];
    cell.deviceID=rowData[@"devid"];
// 设置lable的状态 hgc 2015 10 26
//about onlining
    NSLog(@"rowData==%@//////",rowData[@"onlining"]);
    NSString *tempOnlining = [NSString stringWithFormat:@"%@",rowData[@"onlining"]];
    //1111 add
    cell.onlining = tempOnlining;
    //1111 end
    if ([tempOnlining isEqualToString:@"1"]) {
        cell.labelr2.text = @"在线";
        cell.buttonAlarm.enabled = YES;
    }else{
        cell.labelr2.text = @"掉线";
// 2015 11 11 hgc 注释 start
        //设置按钮可用
//        cell.button.enabled = NO;
        //报警按钮不可用
        cell.buttonAlarm.enabled = NO;
// 2015 11 11 hgc 注释 end
    }
//about monitoring
    NSString *tempMonitoring = [NSString stringWithFormat:@"%@",rowData[@"monitoring"]];
    if ([tempMonitoring isEqualToString:@"1"]) {
        cell.labelr3.text = @"录像中";
        [cell.imageRec setHidden:NO];
    }else{
        cell.labelr3.text = @"录像关闭";
        [cell.imageRec setHidden:YES];
    }
    
//about recording mode
    NSString *tempRecording = [NSString stringWithFormat:@"%@",rowData[@"recording"]];
    NSString *tempMode = [NSString stringWithFormat:@"%@",rowData[@"mode"]];
    
    //2016 01 06 start
//    if ([tempRecording isEqualToString:@"1"]) {
//        [cell.imageModeRec setHidden:NO];
//    }else{
//        [cell.imageModeRec setHidden:YES];
//    }
    
    if (![tempRecording isEqualToString:@"0"]) {
        //模式录像开启
        if ([tempMode isEqualToString:@"0"]) {
            //在家
            cell.imageModeRec.image = [UIImage imageNamed:@"at_home_camera"];
        }else if ([tempMode isEqualToString:@"1"]){
            //外出
            cell.imageModeRec.image = [UIImage imageNamed:@"go_out_camera"];
        }else if([tempMode isEqualToString:@"2"]){
            //睡眠
            cell.imageModeRec.image = [UIImage imageNamed:@"sleep_camera"];
        }
    }else{
        //模式录像关闭
        if ([tempMode isEqualToString:@"0"]) {
            //在家
            cell.imageModeRec.image = [UIImage imageNamed:@"at_home_prohibt"];
        }else if ([tempMode isEqualToString:@"1"]){
            //外出
            cell.imageModeRec.image = [UIImage imageNamed:@"go_out_prohibt"];
        }else if([tempMode isEqualToString:@"2"]){
            //睡眠
            cell.imageModeRec.image = [UIImage imageNamed:@"sleep_prohibt"];
        }
    }
    //2016 01 06 end
    
//about alarming
    NSString *tempAlarming = rowData[@"alarming"];
    cell.alarming = rowData[@"alarming"];
    //2016 01 21 tempAlarming==2 表示没有报警功能
    if ([tempAlarming isEqualToString:@"2"]) {
        [cell.buttonAlarm setHidden:YES];
    }else if ([tempAlarming isEqualToString:@"1"]) {
        cell.labelr4.text = @"报警检测中";
        [cell.buttonAlarm setImage:[UIImage imageNamed:@"alarm-open"] forState:UIControlStateNormal];
    }else{
        cell.labelr4.text = @"报警关闭";
        [cell.buttonAlarm setImage:[UIImage imageNamed:@"alarm-off"] forState:UIControlStateNormal];
    }
// about snapshot
//    UIImage *image = [UIImage imageNamed:@"devicetest.jpg"];
//    UIImage *testimage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://172.16.9.28:81/snapshot.cgi"]]];
//    UIImage *myImage2 =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.kutx.cn/xiaotupian/icons/png/200803/20080327095245737.png"]]];
    
//    UIImage *imageOnline = [self getImageFromURL:rowData[@"snapshot"]];
    NSLog(@"rowData===%@",rowData[@"snapshot"]);
    
    if ([rowData[@"snapshot"] isEqual:[NSNull null]] || [rowData[@"snapshot"] isEqualToString:@""] ) {
//        cell.imagetest.image = image;
//        cell.imagetest.image = [[UIImage alloc]init];
        [cell.imagetest setImage:[UIImage imageNamed:@"camera_disconnect"]];
    }else{
        //
// hgc 替换getimageFromURL start
//        cell.imagetest.image = [self getImageFromURL:rowData[@"snapshot"]];
//hgc test 2016 01 20
        MKNetworkEngine *engine = [[MKNetworkEngine alloc]init];
        MKNetworkOperation *operation = [engine operationWithURLString:rowData[@"snapshot"] params:nil httpMethod:@"GET"];
        //添加完成处理程序
        [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            //请求成功,为_imgView添加图片
            UIImage * testImageMK = [UIImage imageWithData:[completedOperation responseData]];
            //
            [cell.imagetest setImage:testImageMK];
            //
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            //请求出错
            NSLog(@"%@",completedOperation.error);
        }];
        //发起网络请求
        [engine enqueueOperation:operation];
//hgc test 2016 01 20
//hgc 替换getimageFromURL end

        // 2015 11 10 hgc add
        if ([tempOnlining isEqualToString:@"1"]) {
            //        UIImage* grayImage = [self grayscale:cell.imagetest.image type:1];
            //        cell.imagetest.image = grayImage;
            NSLog(@"nomal image");
        }else{
            if (cell.imagetest.image) {
                //            UIImage* grayImage = [[UIImage alloc]init];
                //            grayImage = cell.imagetest.image;
                //
                UIImage*  grayImage = [self grayscale:cell.imagetest.image type:1];
                cell.imagetest.image = grayImage;
                NSLog(@"gray image");

            }else{
//                UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.imagetest.frame.size.width, cell.imagetest.frame.size.height)];
//                [coverView setBackgroundColor:[UIColor colorWithRed:5/255.0 green:5/255.0 blue:5/255.0 alpha:0.3 ]];
//                [cell.imagetest addSubview:coverView];
                
                //2016 01 20
                NSLog(@"camera_disconnectcamera_disconnect");
                [cell.imagetest setImage:[UIImage imageNamed:@"camera_disconnect"]];
            }
            NSLog(@"what is this");
        }
        // 2015 11 10 hgc end
        
    }
    cell.delegate = self;
    
    NSLog(@"what the god !!! ");
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
/*2015 11 09 hgc 注释 button位置改变
    if(section==0){
//UIbutton
        CGRect rect = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,50);
// 2015 11 04 hgc start
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = rect;
        [btn setTitle:@"添加摄像头" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setImage:[UIImage imageNamed:@"add-icon"] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//        [btn setTitleColor:[UIColor colorWithRed:26/255.0 green:142/255.0 blue:219/255.0 alpha:1] forState:UIControlStateNormal];
// 2015 11 04 hgc end
        
//add subview
        CGRect rect1=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
        UIView *view = [[UIView alloc] initWithFrame:rect1];
        [view addSubview:btn];
//selector
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        return view;
    }
*/
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)buttonPressed:(id)sender
{
    CameraAddViewController *cameraAddVC = [[CameraAddViewController alloc]initWithNibName:@"CameraAddViewController" bundle:nil];
    [self.navigationController pushViewController:cameraAddVC animated:YES];
}

- (void)cameraAllSetting:(id)sender
{
    CameraListSetAllViewController *cameraListSetAllVC = [[CameraListSetAllViewController alloc]initWithNibName:@"CameraListSetAllViewController" bundle:nil];
// 1109
    [self.navigationController setToolbarHidden:YES animated:YES];
// 1109
    [self.navigationController pushViewController:cameraListSetAllVC animated:YES];
}

- (void)backToHomeVC:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)chooseAppAction:(UIButton *)sender
{
    //HGC to camera setting VC
    CameraListSetSingleViewController *cameraListSetSingleVC = [[CameraListSetSingleViewController alloc]initWithNibName:@"CameraListSetSingleViewController" bundle:nil];
// 1109
    [UIView animateWithDuration:0.3f animations:^{
        [self.navigationController setToolbarHidden:YES animated:YES];
    } completion:^(BOOL finished) {
         [self.navigationController pushViewController:cameraListSetSingleVC animated:YES];
    }];

// 1109
   
    
    UIView* pview = sender.superview.superview;
    TestTableViewCell *pcell = pview;
    
    cameraListSetSingleVC.deviceID = pcell.deviceID;
    //1111 add
    cameraListSetSingleVC.onlining = pcell.onlining;
    //1111 end
    NSLog(@"what the god!");
    NSLog(@"去往camera独立设置页 from CameraList");
}

// 2015 11 09 hgc
- (void) buttonAlarmPressed:(UIButton *)sender
{
    UIView* pview = sender.superview.superview;
    TestTableViewCell *pcell = pview;
    NSLog(@"pcell.alarming==%@",pcell.alarming);
    self.devidForAlarming = pcell.deviceID;
    if ([pcell.alarming isEqualToString:@"1"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"报警控制"
                                                       message:@"确定要取消报警么"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认", nil];
        [alert show];
        [alert setTag:1212];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"报警控制"
                                                       message:@"确定要开启报警么"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确认", nil];
        [alert show];
        [alert setTag:1213];
    }
    NSLog(@"buttonAlarmPressed");
}
//alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *alarmSet;
    NSString *alarmMessage;
    if (alertView.tag == 1212) {
        alarmSet = @"0";
        alarmMessage = @"报警关闭";
    }else{
        alarmSet = @"1";
        alarmMessage = @"报警开启";
    }
    
    if (buttonIndex == 1) {
        // 1. 更新数据
        [DeviceNetworkInterface cameraAlarmingwithDeviceId:self.devidForAlarming withAlarmParam:alarmSet withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                if ([result isEqualToString:@"success"]) {
                    
                    NSLog(@"camera alarming result===%@",result);
                    NSLog(@"camera alarming mseeage===%@",message);
//                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报警设置" message:[NSString stringWithFormat:@"%@设置成功",alarmMessage] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                    [alertView show];
                }else{
                    NSLog(@"cameraAlarmingwithDeviceId error");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报警设置" message:[NSString stringWithFormat:@"%@设置失败",alarmMessage]  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
            else{
                NSLog(@"cameraAlarmingwithDeviceId error");
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报警设置" message:[NSString stringWithFormat:@"%@设置失败,网络错误",alarmMessage]  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            //重新请求数据
            [self loadData:self.control];
        }];
        }else{
//            self.labelCameraName.text = [alertView textFieldAtIndex:0].text;
        }
    NSLog(@"=============Camera alarming Changed--------------");
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CameraDetailViewController *cameraDetailVC = [[CameraDetailViewController alloc]initWithNibName:@"CameraDetailViewController" bundle:nil];
// 1109
    [self.navigationController setToolbarHidden:YES animated:YES];
// 1109
    [self.navigationController pushViewController:cameraDetailVC animated:YES];
    
    NSDictionary *rowData = self.devices[indexPath.row];
    
    cameraDetailVC.deviceID = rowData[@"devid"];
    cameraDetailVC.deviceName = rowData[@"name"];
    cameraDetailVC.onlining = [NSString stringWithFormat:@"%@",rowData[@"onlining"]];
    NSLog(@"去往camera详情页");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return YES;  1109 hgc
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. 更新数据
    [DeviceNetworkInterface deleleFromDeviceListWithDeviceId:_devices withBlock:^(NSString *result, NSString *message, NSError *error) {
        if (!error) {
            NSLog(@"camera deleleFromDeviceListWithDeviceId result===%@",result);
            NSLog(@"camera deleleFromDeviceListWithDeviceId mseeage===%@",message);
     // 2. 更新UI
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            NSLog(@"deleleFromDeviceListWithDeviceId error");
        }
    }];
}


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *rowData = self.devices[indexPath.row];
    NSString *alarming = rowData[@"alarming"];
    NSString *devid = rowData[@"devid"];
    NSArray *alarmTitle = @[@"报警",@"取消报警"];
    
    NSLog(@"alarmTitle=%@",alarmTitle[0]);
    NSLog(@"alarming====%@",alarming);
    NSLog(@"devid====%@",devid);
    NSString *alarmSet;
    if ([alarming isEqualToString:@"1"]) {
        alarmSet = @"0";
    }else{
        alarmSet = @"1";
    }
    
    //1button
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"点击了删除");
        
    // 1. 更新数据
        [self.control beginRefreshing];
        [DeviceNetworkInterface deleleFromDeviceListWithDeviceId:devid withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                NSLog(@"camera deleleFromDeviceListWithDeviceId result===%@",result);
                NSLog(@"camera deleleFromDeviceListWithDeviceId mseeage===%@",message);

                // 2. 更新UI
                if ([result isEqualToString:@"success"]) {
                    //重新请求数据
                    [self loadData:self.control];
//                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            else{
                NSLog(@"deleleFromDeviceListWithDeviceId error");
            }
        }];
    }];
    
    //2button
//    //置顶按钮
//    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"置顶" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//            
//            NSLog(@"点击了置顶");
//            // 1. 更新数据
////            [_allDataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
//            // 2. 更新UI
//            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
//            [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
//    }];
//    topRowAction.backgroundColor = [UIColor blueColor];
    
    //3button
    // 添加一个报警按钮
    UITableViewRowAction *moreRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:alarmTitle[alarming.integerValue] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSLog(@"点击了报警");
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        // 1. 更新数据
        [DeviceNetworkInterface cameraAlarmingwithDeviceId:devid withAlarmParam:alarmSet withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                NSLog(@"camera alarming result===%@",result);
                NSLog(@"camera alarming mseeage===%@",message);
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报警设置" message:[NSString stringWithFormat:@"%@设置成功", alarmTitle[alarming.integerValue]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else{
                NSLog(@"cameraAlarmingwithDeviceId error");
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"报警设置" message:[NSString stringWithFormat:@"%@设置失败",alarmTitle[alarming.integerValue]]  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            //重新请求数据
            [self loadData:self.control];
        }];
    }];
    if ([alarming isEqualToString:@"1"]) {
        moreRowAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        moreRowAction.backgroundColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:150/255.0 alpha:1];
    }
//    moreRowAction.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    
    // 4.return将设置好的按钮放到数组中返回
//     return @[deleteRowAction, topRowAction, moreRowAction];
    return @[deleteRowAction,moreRowAction];
    
}



// 2015 11 10 hgc add
- (UIImage*)grayscale:(UIImage*)anImage type:(int)type {
    
    CGImageRef imageRef = anImage.CGImage;
    
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    
    bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    
    CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(data);
    
    NSUInteger  x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            UInt8 *tmp;
            tmp = buffer + y * bytesPerRow + x * 4;
            
            UInt8 red,green,blue;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            
            UInt8 brightness;
            switch (type) {
                case 1:
                    brightness = (77 * red + 28 * green + 151 * blue) / 256;
                    *(tmp + 0) = brightness;
                    *(tmp + 1) = brightness;
                    *(tmp + 2) = brightness;
                    break;
                case 2:
                    *(tmp + 0) = red;
                    *(tmp + 1) = green * 0.7;
                    *(tmp + 2) = blue * 0.4;
                    break;
                case 3:
                    *(tmp + 0) = 255 - red;
                    *(tmp + 1) = 255 - green;
                    *(tmp + 2) = 255 - blue;
                    break;
                default:
                    *(tmp + 0) = red;
                    *(tmp + 1) = green;
                    *(tmp + 2) = blue;
                    break;
            }
        }
    }
    
    
    CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    
    CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
    CGImageRef effectedCgImage = CGImageCreate(
                                               width, height,
                                               bitsPerComponent, bitsPerPixel, bytesPerRow,
                                               colorSpace, bitmapInfo, effectedDataProvider,
                                               NULL, shouldInterpolate, intent);
    
    UIImage *effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
    CGImageRelease(effectedCgImage);
    
    CFRelease(effectedDataProvider);
    
    CFRelease(effectedData);
    
    CFRelease(data);
    
    return effectedImage;
    
}
// 2015 11 10 hgc end

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end
