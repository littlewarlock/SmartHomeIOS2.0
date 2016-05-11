//
//  networkAccessViewController.h
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/3.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouterViewController.h"

@interface NetworkAccessViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *netAccessButton;
@property (weak, nonatomic) IBOutlet UIButton *broadbandButton;

@property (weak, nonatomic) IBOutlet UIView *netLink;
@property (weak, nonatomic) IBOutlet UIView *broadbandView;
@property (weak, nonatomic) IBOutlet UIView *netAccessView;
@property (weak, nonatomic) IBOutlet UIButton *autoWayButton;
@property (weak, nonatomic) IBOutlet UIButton *manualWayButton;
@property (weak, nonatomic) IBOutlet UIView *dnsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveToTop;


@property (weak, nonatomic) IBOutlet UIButton *showPasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *paswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *broadBandLabel;

@property (strong, nonatomic) NSString *routerType;//提交的ip 或 cid


@property (weak, nonatomic) IBOutlet UITextField *ipAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *subnetMaskLabel;
@property (weak, nonatomic) IBOutlet UITextField *gateWayLabel;
@property (weak, nonatomic) IBOutlet UITextField *dnsAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *dnsAddressLabelOne;


@property (weak, nonatomic) NSString *ipAddressString;
@property (weak, nonatomic) NSString *subnetMaskString;
@property (weak, nonatomic) NSString *gateWayString;
@property (weak, nonatomic) NSString *dnsAddressString;
@property (weak, nonatomic) NSString *dnsAddressStringOne;


@end
