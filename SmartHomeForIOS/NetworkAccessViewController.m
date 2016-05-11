//
//  networkAccessViewController.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/3.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "NetworkAccessViewController.h"
#import "RequestConstant.h"
#import "DataManager.h"
#import "FileTools.h"
#import "RouterViewController.h"
#import "UIHelper.h"

@interface NetworkAccessViewController ()
{
    UIView *loadingView;
    

}

@end

@implementation NetworkAccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.netLink.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.netLink.layer.borderWidth = 1;
    
    self.title = @"设置上网方式";
    //左侧返回按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = itemLeft;
    
    
    if ([self.routerType  isEqual:@"static"]) {//手动方式连接
        
        //设置静态IP的相关view
        [self setupStaticView];
        
        //设置静态IP的值
        [self setupStaticIp];
      
    }else if ([self.routerType  isEqual:@"dhcp"]){//自动方式连接
        
        //修改按钮颜色
        self.netAccessButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
        [self.netAccessButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.broadbandButton.backgroundColor = [UIColor whiteColor];
        [self.broadbandButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
        //相关View的隐藏、显示
        self.broadbandView.hidden = YES;
        self.netAccessView.hidden = NO;
        self.dnsView.hidden = YES;
        
        //设置手动方式、自动方式的图片
        [self.autoWayButton setImage:[UIImage imageNamed:@"router_check_down"] forState:UIControlStateNormal];
        [self.manualWayButton setImage:[UIImage imageNamed:@"router_check"] forState:UIControlStateNormal];
        
        //设置保存按钮的约束值
        self.saveToTop.constant = 375;
    
    }else {//宽带拨号
        
        //修改按钮颜色
        self.netAccessButton.backgroundColor = [UIColor whiteColor];
        [self.netAccessButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.broadbandButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
        [self.broadbandButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //相关View的隐藏、显示
        self.broadbandView.hidden = NO;
        self.netAccessView.hidden = YES;
        
        //设置保存按钮的约束值
        self.saveToTop.constant = 188;
    }

}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  设置静态IP的值
 */
- (void)setupStaticIp
{
    self.ipAddressLabel.text = self.ipAddressString;
    self.dnsAddressLabel.text = self.dnsAddressString;
    self.dnsAddressLabelOne.text = self.dnsAddressStringOne;
    self.subnetMaskLabel.text = self.subnetMaskString;
    self.gateWayLabel.text = self.gateWayString;

}

/**
 *  设置静态IP的相关view
 */
- (void)setupStaticView
{
    //设置背景颜色和title的颜色
    self.netAccessButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
    [self.netAccessButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.broadbandButton.backgroundColor = [UIColor whiteColor];
    [self.broadbandButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    //相关View的隐藏、显示
    self.broadbandView.hidden = YES;
    self.netAccessView.hidden = NO;
    self.dnsView.hidden = NO;
    
    //设置手动方式、自动方式的图片
    [self.autoWayButton setImage:[UIImage imageNamed:@"router_check"] forState:UIControlStateNormal];
    [self.manualWayButton setImage:[UIImage imageNamed:@"router_check_down"] forState:UIControlStateNormal];
    
    //设置保存按钮的约束值
    self.saveToTop.constant = 375;

}

/**
 *  监听网线连接按钮的点击
 */
- (IBAction)netLineAccess:(id)sender {
    
    //设置静态IP的相关view
    [self setupStaticView];
    
    
}

//监听“自动方式”按钮
- (IBAction)autoWay:(id)sender {
    
    self.dnsView.hidden = YES;
    [self.autoWayButton setImage:[UIImage imageNamed:@"router_check_down"] forState:UIControlStateNormal];
    [self.manualWayButton setImage:[UIImage imageNamed:@"router_check"] forState:UIControlStateNormal];
}

//监听“手动方式”按钮
- (IBAction)manualWay:(id)sender {
    
    self.dnsView.hidden = NO;
    [self.autoWayButton setImage:[UIImage imageNamed:@"router_check"] forState:UIControlStateNormal];
    [self.manualWayButton setImage:[UIImage imageNamed:@"router_check_down"] forState:UIControlStateNormal];
 
}

//监听“显示密码”按钮
- (IBAction)showPassword:(id)sender {
    
    [self.showPasswordButton setImage:[UIImage imageNamed:@"router_checkbox_down"] forState:UIControlStateSelected];
    self.showPasswordButton.selected = !self.showPasswordButton.selected;
    
    self.paswordLabel.secureTextEntry = !self.paswordLabel.secureTextEntry;
    
}

//监听“宽带拨号按钮”的点击
- (IBAction)broadBand:(id)sender {
    
    //修改按钮颜色
    self.netAccessButton.backgroundColor = [UIColor whiteColor];
    [self.netAccessButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.broadbandButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
    [self.broadbandButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.broadbandView.hidden = NO;
    self.netAccessView.hidden = YES;
    self.saveToTop.constant = 188;
   
}

//监听“保存按钮”的点击
- (IBAction)Save:(id)sender {
    
    
    if (self.broadbandView.hidden == NO) {//宽带拨号
        
        [self.paswordLabel resignFirstResponder];
        self.routerType = @"PPPOE";
        if ([self.broadBandLabel.text  isEqualToString:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入宽带账号" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            
            [alertView show];
        }else if ([self.paswordLabel.text isEqualToString:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入密码" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            
            [alertView show];

        }else {
            
            loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在保存宽带账号和密码信息" ];
            [self pppoe];
  
        }
    
    }else {//网线连接
        
        if (self.dnsView.hidden == YES) {//自动方式
            
             loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在保存自动登录信息" ];
            self.routerType = @"DHCP";
            [self dhcp];
        } else {
            self.routerType = @"STATIC";
            
            if ([self.ipAddressLabel.text  isEqualToString:@""]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入IP地址" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                
                [alertView show];
            }else if ([self.subnetMaskLabel.text isEqualToString:@""]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入子网掩码" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                
                [alertView show];
                
            }else if ([self.gateWayLabel.text isEqualToString:@""]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入网关" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                
                [alertView show];
                
            }else if ([self.dnsAddressLabel.text isEqualToString:@""]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入DNS地址" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                
                [alertView show];
                
            }else {
                
                loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在保存静态IP信息" ];
                [self staticIp];//静态IP
                
            }
            
        }
 
    }
   
}

//自动方式
- (void)dhcp{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.routerType forKey:@"type"];
    
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_ROUTER_SETROUTER_URL params:dic httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([[operation responseString] isEqualToString: @"0"])//保存成功
        {
            if (loadingView)
            {
                [loadingView removeFromSuperview];
                loadingView = nil;
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {//保存失败
            if (loadingView)
            {
                [loadingView removeFromSuperview];
                loadingView = nil;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"自动方式保存失败!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            
            return;
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"服务器无响应,请尝试4G网络或核实地址是否正确" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        
        [alertView show];
        
    }];
    
    [engine enqueueOperation:op];
    
}

//静态IP
- (void)staticIp{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.ipAddressLabel.text forKey:@"ipaddr"];
    [dic setValue:self.subnetMaskLabel.text forKey:@"netmask"];
    [dic setValue:self.gateWayLabel.text forKey:@"gateway"];
    NSString *dnsText = [NSString stringWithFormat:@"%@ %@",self.dnsAddressLabel.text,self.dnsAddressLabelOne.text];
    [dic setValue:dnsText forKey:@"dns"];
    [dic setValue:self.routerType forKey:@"type"];
  
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_ROUTER_SETROUTER_URL params:dic httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        if([[operation responseString] isEqualToString: @"0"])//保存成功
        {
            if (loadingView)
            {
                [loadingView removeFromSuperview];
                loadingView = nil;
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {//保存失败
            if (loadingView)
            {
                [loadingView removeFromSuperview];
                loadingView = nil;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"静态IP信息错误!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            
            return;
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"服务器无响应,请尝试4G网络或核实地址是否正确" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        
        [alertView show];
        
    }];
    
    [engine enqueueOperation:op];

}


//宽带拨号
- (void)pppoe {
    
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:self.broadBandLabel.text forKey:@"username"];
        [dic setValue:self.paswordLabel.text forKey:@"password"];
        [dic setValue:self.routerType forKey:@"type"];
    
    
        NSString* requestHost = [g_sDataManager requestHost];
        NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];

        MKNetworkOperation *op = [engine operationWithPath:REQUEST_ROUTER_SETROUTER_URL params:dic httpMethod:@"GET" ssl:NO];
    
        [op addCompletionHandler:^(MKNetworkOperation *operation) {

            if([[operation responseString] isEqualToString: @"0"])//保存成功
            {
                if (loadingView)
                {
                    [loadingView removeFromSuperview];
                    loadingView = nil;
                }

                [self.navigationController popViewControllerAnimated:YES];
                
            }else  if([[operation responseString] isEqualToString: @"1"]){//保存失败
                if (loadingView)
                {
                    [loadingView removeFromSuperview];
                    loadingView = nil;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"宽带账号或密码错误!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alertView show];

                return;
            }
            
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            
            if (loadingView)
            {
                [loadingView removeFromSuperview];
                loadingView = nil;
            }
       
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"服务器无响应,请尝试4G网络或核实地址是否正确" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;

            [alertView show];
   
        }];
        
        [engine enqueueOperation:op];

}



@end
