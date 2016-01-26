//
//  VideoViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/24.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoTableViewController.h"
#import "AlbumVideoTableViewController.h"
#define TV_Cell_Height 52;
@interface VideoViewController ()
{
    NSMutableArray* videoArray;
    UIBarButtonItem *leftBtn;
}

@end

#define AU_Cell_Height 52

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    leftBtn=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=leftBtn;
    videoArray = [NSMutableArray arrayWithObjects:
                  @"相机视频",
                  @"本机视频",nil];
    
    //去掉tableView分割线左边短15像素
    if ([self.videoTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.videoTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.videoTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.videoTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.videoTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//UITableViewDataSource协议中的方法
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellId = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellId];
    }
    //去掉tableView分割线左边短15像素
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"thumbnail"];
    //cell.imageView.image.frame = CGRectMake(0, 0, 29, 29);
    cell.textLabel.text = videoArray[indexPath.row];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}
//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return videoArray.count;
}
//UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TV_Cell_Height;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {

        AlbumVideoTableViewController *albumVideoTableView = [[AlbumVideoTableViewController alloc] initWithNibName:@"AlbumVideoTableViewController" bundle:nil];
        [self.navigationController pushViewController:albumVideoTableView animated:YES];
    }
    else{
        VideoTableViewController *videoTableView = [[VideoTableViewController alloc] initWithNibName:@"VideoTableViewController" bundle:nil];
        [self.navigationController pushViewController:videoTableView animated:YES];
    }
}
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
