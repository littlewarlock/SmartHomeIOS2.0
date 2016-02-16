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
    
    //默认不显示
    self.activeLabel.hidden = YES;
    self.boundingLabel.text = @"";
    self.replaceButton.hidden = YES;
    self.tipLabel1.hidden = YES;
    self.tipLabel2.hidden = YES;
    self.tipLabel3.hidden = YES;
    self.tipLabel4.hidden = YES;
    
    //返回激活码
    [self activeCode];

}


//返回激活码
- (void)activeCode
{
    [thunderTools activeCodewithBlock:^(NSString *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (![result isEqual:@""]) {//未绑定
                self.activeLabel.hidden = NO;
                self.boundingLabel.text = @"未绑定";
                self.replaceButton.hidden = NO;
                self.tipLabel1.hidden = NO;
                self.tipLabel2.hidden = NO;
                self.tipLabel3.hidden = NO;
                self.tipLabel4.hidden = NO;
                self.activeLabel.text = [NSString stringWithFormat:@"激活码:%@",result];
            } else {//已绑定
                self.activeLabel.hidden = YES;
                self.boundingLabel.text = @"已绑定";
                self.replaceButton.hidden = YES;
                self.tipLabel1.hidden = YES;
                self.tipLabel2.hidden = YES;
                self.tipLabel3.hidden = YES;
                self.tipLabel4.hidden = YES;
            }
        });
        
    }];
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
