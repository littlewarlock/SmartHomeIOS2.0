//
//  ThunderViewController.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/1/13.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "ThunderViewController.h"


@interface ThunderViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *ImagescrollView;/** 显示绑定步骤的ScrollView*/

@property (weak, nonatomic) IBOutlet UIButton *replaceButton;/** 复制按钮*/
@property (weak, nonatomic) IBOutlet UILabel *activeLabel;/** 激活label*/
@property (weak, nonatomic) IBOutlet UILabel *boundingLabel;/** 是否已经绑定label*/
/** 特别提示label*/
@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel2;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel3;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel4;

@end

@implementation ThunderViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"迅雷";
    //设置左边返回按钮
    UIImage* img=[UIImage imageNamed:@"back"];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(200, 0, 32, 32);
    [leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    [leftBtn addTarget: self action: @selector(back:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //设置ImagescrollView的滚动范围
    self.ImagescrollView.contentSize = CGSizeMake(0, 2100);
    
    //返回激活码
    [self activeCode];
    


}
//返回激活码
- (void)activeCode
{
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    __weak typeof(self) weakSelf = self;
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_THUNDER_KEY_URL params:nil httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        if (![[operation responseString]  isEqual:@""]) {//未绑定
            weakSelf.activeLabel.hidden = NO;
            weakSelf.boundingLabel.text = @"未绑定";
            weakSelf.replaceButton.hidden = NO;
            weakSelf.tipLabel1.hidden = NO;
            weakSelf.tipLabel2.hidden = NO;
            weakSelf.tipLabel3.hidden = NO;
            weakSelf.tipLabel4.hidden = NO;
            weakSelf.activeLabel.text = [NSString stringWithFormat:@"激活码:%@",[operation responseString]];
        } else {//已绑定
            weakSelf.activeLabel.hidden = YES;
            weakSelf.boundingLabel.text = @"已绑定";
            weakSelf.replaceButton.hidden = YES;
            weakSelf.tipLabel1.hidden = YES;
            weakSelf.tipLabel2.hidden = YES;
            weakSelf.tipLabel3.hidden = YES;
            weakSelf.tipLabel4.hidden = YES;
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        
    }];
    [engine enqueueOperation:op];
}

//将激活码的文本复制到剪贴板
- (IBAction)CopyActiveCode:(id)sender {
    //将激活码的文本复制到剪贴板
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.activeLabel.text;
    //弹出提示框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"激活码复制成功 " preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定 " style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                //点击确定后做的事情
                                            }]];
    [self presentViewController:alert animated:true completion: nil];
}

//返回Home
- (void)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
