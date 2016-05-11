//
//  WifiListViewController.m
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/3.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import "WifiListViewController.h"
#import "WifiLIistCell.h"
#import "ApSettingViewController.h"

@interface WifiListViewController ()

@end


static NSString *WifiLIistCellIdentifier = @"WifiLIistCell";
@implementation WifiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"AP一览";
    
    self.wifiListTableview.delegate = self;
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = itemLeft;
    
    
    //设置右侧按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(200, 0, 50, 30);
    [rightBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"统一设置" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(unification) forControlEvents: UIControlEventTouchUpInside];
    [rightBtn sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    UINib *nib = [UINib nibWithNibName:@"WifiLIistCell" bundle:nil];
    [self.wifiListTableview registerNib:nib forCellReuseIdentifier:WifiLIistCellIdentifier];
    self.wifiListTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    

}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


//统一设置
- (void)unification
{

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    WifiLIistCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             WifiLIistCellIdentifier];
    if (cell == nil) {
        cell = [[WifiLIistCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:WifiLIistCellIdentifier];
    }
    cell.delegate = self;
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;

}


- (void)setupAp
{
    ApSettingViewController *asVc = [[ApSettingViewController alloc] initWithNibName:@"ApSettingViewController" bundle:nil];
    [self.navigationController pushViewController:asVc animated:YES];

    

}
@end
