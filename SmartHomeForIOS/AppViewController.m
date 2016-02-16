//
//  AppViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/25.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AppViewController.h"
#import "AppNameAndIconCell.h"
#import "AppInfoViewController.h"
#import "FunctionManageTools.h"
#import "thunderTools.h"

@interface AppViewController ()


@end

static NSString *CellTableIdentifier = @"CellTableIdentifier";
@implementation AppViewController
{
    AppDelegate *appDelegate;
    //隐藏私有云 消息管理 报警管理 本地文档
    NSMutableArray *_appList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"更多功能";
    [_tableView registerClass:[AppNameAndIconCell class] forCellReuseIdentifier:CellTableIdentifier];
    _tableView.rowHeight =80;
    UINib *nib = [UINib nibWithNibName:@"AppNameAndIconCell" bundle:nil];
    
    [_tableView registerNib:nib forCellReuseIdentifier:CellTableIdentifier];
    

    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;

    
    
    UIEdgeInsets contentInset = _tableView.contentInset;
    contentInset.top = 36;
    [_tableView setContentInset:contentInset];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    appDelegate = [[UIApplication sharedApplication] delegate];
//    //_appList = appDelegate.appArray;
    _appList = [[NSMutableArray alloc] init];
    for(AppInfo *appInfo in (AppInfo *)(appDelegate.appArray)){
        if((appInfo.appKey != 1) && (appInfo.appKey != 2) && (appInfo.appKey != 6) && (appInfo.appKey != 8)){
            [_appList addObject:appInfo];
        }
    }
    
    
    
}

#pragma mark returnAction 返回父页面的方法
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _appList = [[NSMutableArray alloc] init];
    for(AppInfo *appInfo in (AppInfo *)(appDelegate.appArray)){
        if((appInfo.appKey != 1) && (appInfo.appKey != 2) && (appInfo.appKey != 6) && (appInfo.appKey != 8)){
            [_appList addObject:appInfo];
        }
    }
    [self.tableView reloadData];
    NSLog(@"初始化完成！！！！！！！！");
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    appDelegate = [[UIApplication sharedApplication] delegate];
    return _appList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppNameAndIconCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier forIndexPath:indexPath];
    AppInfo * appInfo = _appList[indexPath.row];
    cell.nameLabel.text = appInfo.appName;
    
    UIImage *appImage = [UIImage imageNamed:appInfo.appIconName];

    [cell.iconButton setBackgroundImage:appImage forState:UIControlStateNormal];
        cell.iconButton.frame =  CGRectMake(cell.iconButton.frame.origin.x, cell.iconButton.frame.origin.y, 30, 30);
    [cell.iconButton setTag:(int)appInfo.appKey];
    [cell.enableDisableSwitch setTag:(int)appInfo.appKey];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    cell.enableDisableSwitch.on = NO;
    for (int i=0;i<appDelegate.selectedAppArray.count;i++ ){
        if( ((AppInfo *) appDelegate.selectedAppArray[i]).appKey  == appInfo.appKey)
        {
            cell.enableDisableSwitch.on = YES;
            
        }
    }
    //暂时禁用百度云
    if(appInfo.appKey == 4){
        cell.enableDisableSwitch.enabled = NO;
    }
    
    //隐藏私有云 消息管理 报警管理 本地文档
    if(appInfo.appKey == 1 || appInfo.appKey == 2 || appInfo.appKey == 6 || appInfo.appKey == 8){
        cell.hidden = YES;
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
    
    
    cell.delegate=self;
    return cell;
}

- (void)chooseAppAction:(UIButton *)sender
{
    AppInfoViewController *appInfoView = [[AppInfoViewController alloc] initWithNibName:@"AppInfoViewController" bundle:nil];
    appInfoView.appIndex = (NSInteger*)sender.tag;
    NSInteger index =-1;
    for(NSInteger i =0;i< _appList.count;i++)
    {
        AppInfo *appInfo = (AppInfo *)_appList[i];
        if(appInfo.appKey == sender.tag)
        {
            index=i;
            break;
        }
    }
    if(index!=-1)
    {
        appInfoView.appInfo = _appList[index];
    }
    [self.navigationController pushViewController:appInfoView animated:YES];
}
- (void)enableDisableAppAction:(UISwitch *)sender
{
    
    if (sender.tag == 12 && !sender.on) {
        [thunderTools closeThunderwithBlock:^(NSString *result, NSError *error) {
            NSLog(@"result222%@111",result);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([result isEqualToString:@"0 "]) {
                    NSLog(@"----关闭迅雷成功");
                    sender.on = NO;
                }else {
                
                    NSLog(@"----关闭迅雷失败");
                    sender.on = YES;
                
                }
                
                if(appDelegate){
                    if(appDelegate.selectedAppArray)
                    {
                        BOOL appStatus = sender.on;
                        NSInteger index =-1;
                        for (NSInteger i =0;i<appDelegate.selectedAppArray.count;i++) {
                            AppInfo *appInfo = ( AppInfo *)appDelegate.selectedAppArray[i];
                            if(appInfo!=nil && (int)appInfo.appKey == sender.tag)
                            {
                                index = i;
                            }
                        }
                        if(appStatus!=YES){
                            if(index!=-1)
                            {
                                [appDelegate.selectedAppArray removeObjectAtIndex:index];
                            }
                        }
                        else{//如果用户启用该app
                            if(index==-1)
                            {
                                for (NSInteger i =0;i<appDelegate.appArray.count;i++) {
                                    AppInfo *appInfo = ( AppInfo *)appDelegate.appArray[i];
                                    if((int)appInfo.appKey==sender.tag)
                                    {
                                        [appDelegate.selectedAppArray addObject:appInfo];
                                    }
                                }
                            }
                        }
                        
                        [FunctionManageTools saveSelectedApp];
                    }
                }
                
            });
           
        }];
        

    }else if (sender.tag == 12 && sender.on){//手动启动盒子中的迅雷
    
        [thunderTools openThunderwithBlock:^(NSString *result, NSError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([result isEqualToString:@"0"] || [result isEqualToString:@"3"]) {
                     NSLog(@"----启动迅雷成功");
                     sender.on = YES;
                 }else if ([result isEqualToString:@"1"]) {
                     NSLog(@"----启动迅雷失败");
                     sender.on = NO;
                 
                 }
                 
                 if(appDelegate){
                     if(appDelegate.selectedAppArray)
                     {
                         BOOL appStatus = sender.on;
                         NSInteger index =-1;
                         for (NSInteger i =0;i<appDelegate.selectedAppArray.count;i++) {
                             AppInfo *appInfo = ( AppInfo *)appDelegate.selectedAppArray[i];
                             if(appInfo!=nil && (int)appInfo.appKey == sender.tag)
                             {
                                 index = i;
                             }
                         }
                         if(appStatus!=YES){
                             if(index!=-1)
                             {
                                 [appDelegate.selectedAppArray removeObjectAtIndex:index];
                             }
                         }
                         else{//如果用户启用该app
                             if(index==-1)
                             {
                                 for (NSInteger i =0;i<appDelegate.appArray.count;i++) {
                                     AppInfo *appInfo = ( AppInfo *)appDelegate.appArray[i];
                                     if((int)appInfo.appKey==sender.tag)
                                     {
                                         [appDelegate.selectedAppArray addObject:appInfo];
                                     }
                                 }
                             }
                         }
                         
                         [FunctionManageTools saveSelectedApp];
                     }
                 }
                 
            });
            
        }];
    }else {
    
        if(appDelegate){
            if(appDelegate.selectedAppArray)
            {
                BOOL appStatus = sender.on;
                NSInteger index =-1;
                for (NSInteger i =0;i<appDelegate.selectedAppArray.count;i++) {
                    AppInfo *appInfo = ( AppInfo *)appDelegate.selectedAppArray[i];
                    if(appInfo!=nil && (int)appInfo.appKey == sender.tag)
                    {
                        index = i;
                    }
                }
                if(appStatus!=YES){
                    if(index!=-1)
                    {
                        [appDelegate.selectedAppArray removeObjectAtIndex:index];
                    }
                }
                else{//如果用户启用该app
                    if(index==-1)
                    {
                        for (NSInteger i =0;i<appDelegate.appArray.count;i++) {
                            AppInfo *appInfo = ( AppInfo *)appDelegate.appArray[i];
                            if((int)appInfo.appKey==sender.tag)
                            {
                                [appDelegate.selectedAppArray addObject:appInfo];
                            }
                        }
                    }
                }
                
                [FunctionManageTools saveSelectedApp];
            }
        }
    }
    
}

@end
