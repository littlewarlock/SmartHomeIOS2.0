//
//  RouterViewController.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/2.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "RouterViewController.h"
#import "NetworkAccessViewController.h"
#import "UpdateRouterViewController.h"
#import "ResetFactoryViewController.h"
#import "WifiListViewController.h"
#import "RouterPasswordViewController.h"
#import "RouterSystemViewController.h"
#import "RequestConstant.h"
#import "DataManager.h"
#import "UIHelper.h"

@interface RouterViewController ()

{
    UIView* loadingView;
    NSString *routerType;
    NSString *dns;
    NSString *dnsOne;
    NSString *gateway;
    NSString *ip;
    NSString *netmask;
    
}

@end

@implementation RouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"路由器管理";
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = itemLeft;
    
   
}


- (void)viewWillAppear:(BOOL)animated
{
    //获取路由器登录信息
    [self getRouterMessage];

}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/**
 *  获取路由器登录信息
 */
- (void)getRouterMessage
{
    
    loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在获取路由器信息" ];
    __block NSError *error = nil;
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_ROUTER_GEROUTER_URL params:nil httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        NSLog(@"responseJSON------:%@",responseJSON);
        routerType = [NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"type"]];
        if([routerType isEqualToString: @"dhcp"]){//自动方式
            
            
        }else if ([routerType isEqualToString: @"pppoe"]){//宽带拨号
            
            
        
        }else if ([routerType isEqualToString: @"static"]){//手动方式
            
            NSString *dnsString = [NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"dns"]];
            gateway = [NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"gateway"]];
            ip = [NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"ip"]];
            netmask = [NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"netmask"]];
            
            
            NSArray *strArr = [dnsString componentsSeparatedByString:@" "];// 以空格分割成数组，依次读取数组中的元素
            
            dns = strArr[0];
            dnsOne = strArr[1];
            
            
            
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

/**
 *  监听“恢复出厂设置”按钮点击
 */
- (IBAction)resetFactory:(id)sender {
    
    ResetFactoryViewController *rfVc = [[ResetFactoryViewController alloc] initWithNibName:@"ResetFactoryViewController" bundle:nil];
    [self.navigationController pushViewController:rfVc animated:YES];
   
}

/**
 *  监听“WiFi设置”按钮点击
 */
- (IBAction)wifiList:(id)sender {
    
    WifiListViewController *wlVc = [[WifiListViewController alloc] initWithNibName:@"WifiListViewController" bundle:nil];
    [self.navigationController pushViewController:wlVc animated:YES];
    
}


/**
 *  监听“修改路由器密码”按钮点击
 */
- (IBAction)routerPassword:(id)sender {
    
    RouterPasswordViewController *rpVc = [[RouterPasswordViewController alloc] initWithNibName:@"RouterPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:rpVc animated:YES];
}

/**
 *  监听“系统更新”按钮点击
 */
- (IBAction)updateSystem:(id)sender {
    
    UpdateRouterViewController *urVc = [[UpdateRouterViewController alloc] initWithNibName:@"UpdateRouterViewController" bundle:nil];
    
    //设置modal方式
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        urVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
    }else{
        
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        
    }
    
    [self presentViewController:urVc animated:NO completion:nil];
    
}

/**
 *  监听“设置上网方式”按钮点击
 */
- (IBAction)setupNetAccess:(id)sender {
    
    NetworkAccessViewController *naVc = [[NetworkAccessViewController alloc] initWithNibName:@"NetworkAccessViewController" bundle:nil];
    
    naVc.routerType = routerType;
    naVc.ipAddressString = ip;
    naVc.dnsAddressString = dns;
    naVc.dnsAddressStringOne = dnsOne;
    naVc.subnetMaskString = netmask;
    naVc.gateWayString = gateway;
    
    
    [self.navigationController pushViewController:naVc animated:YES];

}

/**
 *  监听“系统信息”按钮点击
 */
- (IBAction)systemMessage:(id)sender {
    
    RouterSystemViewController *rsVc = [[RouterSystemViewController alloc] initWithNibName:@"RouterSystemViewController" bundle:nil];
    [self.navigationController pushViewController:rsVc animated:YES];
    
}



@end
