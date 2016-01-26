//
//  PicViewController.m
//  project1
//
//  Created by apple1 on 15/9/8.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import "PicViewController.h"
#import "PicCollectionViewController.h"
#import "AlbumCollectionViewController.h"

@interface PicViewController ()

@end

@implementation PicViewController{
#define TV_Cell_Height 52;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame =CGRectMake(200, 0, 32, 32);
    [bt setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [bt addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn=[[UIBarButtonItem alloc]initWithCustomView:bt];
    self.navigationItem.leftBarButtonItem=leftBtn;
    
    
    
    self.picArray = [NSMutableArray arrayWithObjects:
                     @"相机胶卷",
                     @"本地照片流",nil];
    self.tvContent.dataSource = self;
    self.tvContent.delegate = self;
    //去掉tableView分割线左边短15像素
    if ([self.tvContent respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tvContent setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tvContent respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tvContent setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.tvContent setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
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
    cell.imageView.image = [UIImage imageNamed:@"thumbnail"];
    //cell.imageView.image.frame = CGRectMake(0, 0, 29, 29);
    cell.textLabel.text = self.picArray[indexPath.row];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}
//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.picArray.count;
}
//UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TV_Cell_Height;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1) {
        PicCollectionViewController *picView = [[PicCollectionViewController alloc] initWithNibName:@"PicCollectionViewController" bundle:nil];
        [self.navigationController pushViewController:picView animated:YES];
    }
    else{
        AlbumCollectionViewController *albumView = [[AlbumCollectionViewController alloc] initWithNibName:@"AlbumCollectionViewController" bundle:nil];
        [self.navigationController pushViewController:albumView animated:YES];
    }
    
}

-(void)returnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
