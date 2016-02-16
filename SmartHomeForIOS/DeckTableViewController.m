//
//  DeckTableViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/6.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "DeckTableViewController.h"
#import "PasswordViewController.h"
#import "DataManager.h"
#import "IIViewDeckController.h"
#import "UserEditViewController.h"
#import "AppViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "FileTools.h"
#import <AVOSCloud/AVOSCloud.h>

@interface DeckTableViewController () <IIViewDeckControllerDelegate>

- (IIViewDeckController*)topViewDeckController;
@end
@implementation DeckTableViewController{
    
    NSMutableArray* menuItemArray  ;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [g_sDataManager userName];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:15.0/255 green:131.0/255 blue:255.0/255 alpha:1];
    
    menuItemArray = [NSMutableArray new];
    [menuItemArray addObject:@"用户管理"];
    [menuItemArray addObject:@"修改密码"];
    [menuItemArray addObject:@"路由管理器"];
    [menuItemArray addObject:@"AP管理"];
    [menuItemArray addObject:@"更多功能"];
    [menuItemArray addObject:@"注销"];
    
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = menuItemArray[indexPath.row];
    [cell.textLabel setTextColor:[UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1]];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.showsReorderControl = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
            UserEditViewController *userList= [[UserEditViewController alloc] initWithNibName:@"UserEditViewController" bundle:nil];
            self.viewDeckController.toggleLeftView;
            [(UINavigationController*)self.viewDeckController.centerController pushViewController:userList animated:YES];
        }        
            break;
        case 1:{
            PasswordViewController *pwdView = [[PasswordViewController alloc] initWithNibName:@"PasswordViewController" bundle:nil];
            pwdView.userName = [g_sDataManager userName];
            self.viewDeckController.toggleLeftView;
            [(UINavigationController*)self.viewDeckController.centerController pushViewController:pwdView animated:YES];
            
            break;
        }
        case 2:
            NSLog(@"路由管理");
            break;
        case 3:{
            NSLog(@"ap管理");
            break;
        }
        case 4:{
            AppViewController *appView = [[AppViewController alloc] initWithNibName:@"AppViewController" bundle:nil];
            self.viewDeckController.toggleLeftView;
            [(UINavigationController*)self.viewDeckController.centerController pushViewController:appView animated:YES];
            break;
        }
        case 5:{
            //[FunctionManageTools saveSelectedApp];
            [g_sDataManager setUserName:@""];
            [g_sDataManager setPassword:@""];
            AVInstallation *currentInstallation = [AVInstallation currentInstallation];
            [currentInstallation removeObject:[g_sDataManager cId] forKey:@"channels"];
            [currentInstallation saveInBackground];
            LoginViewController *loginView= [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            loginView.isPushHomeView =YES;
            loginView.isShowLocalFileBtn =YES;
            self.viewDeckController.toggleLeftView;
            [self.viewDeckController presentViewController:loginView animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItemArray.count;
}


- (IIViewDeckController*)topViewDeckController {
    return self.viewDeckController.viewDeckController;
}



@end
