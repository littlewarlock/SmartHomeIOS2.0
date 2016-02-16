//
//  MasterViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/9/9.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//
#import "UserEditViewController.h"
#import "UserInfo.h"
#import "UserEditCell.h"
#import "PasswordViewController.h"
#import "DataManager.h"
#import "RequestConstant.h"

@interface UserEditViewController () <SwipeableCellDelegate> {
    NSMutableArray *_userList;
}
@end
static NSString * UserCell = @"UserCell";
@implementation UserEditViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cellsCurrentlyEditing = [[NSIndexPath alloc]init];
  
   // self.cellsCurrentlyEditing = [NSMutableArray array];
    
    self.title = @"用户管理";
    //self.nameTextField.layer.borderColor=[[UIColor redColor]CGColor];
    //关闭联想输入
    self.nameTextField.autocorrectionType=UITextAutocorrectionTypeNo;
//    self.nameTextField.layer.borderWidth= 1.0f;
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.borderWidth = 0;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线    self.tableView.allowsSelection = NO;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero]  ;
    [self.tableView registerClass:[UserEditCell class] forCellReuseIdentifier:UserCell];
    self.tableView.rowHeight =40;
    UINib *nib = [UINib nibWithNibName:@"UserEditCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:UserCell];
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 0;
    [self.tableView setContentInset:contentInset];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self loadData];
}

#pragma mark returnAction 返回父页面的方法
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserEditCell *cell = [tableView dequeueReusableCellWithIdentifier:UserCell
                          ];
    if(cell == nil){
        NSLog(@"cell ========= nil");
    }
    UserInfo *userInfo = _userList[indexPath.row];
    cell.itemText = userInfo.userName;
    cell.delegate = self;
    if ([self.cellsCurrentlyEditing isEqual:indexPath]) {
        [cell openCell];
    }
//    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
//        [cell openCell];
//    }
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_userList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %zi", editingStyle);
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
    }
}

- (void)updateButtonAction:(UIButton *)btn
{
    PasswordViewController *pwdView = [[PasswordViewController alloc] initWithNibName:@"PasswordViewController" bundle:nil];
    
    UITableViewCell *cell;
    if (![btn.superview.superview isKindOfClass:[UserEditCell class]]) {
        cell=(UserEditCell*) btn.superview.superview.superview;
    }else{
        cell=(UserEditCell*) btn.superview.superview;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    UserInfo *selectedUser = _userList[indexPath.row];
    pwdView.userName = selectedUser.userName;
    [self.navigationController pushViewController:pwdView animated:YES];
}

- (void)deleteButtonAction:(UIButton *)btn{
    
    UITableViewCell *cell;
    if (![btn.superview.superview isKindOfClass:[UserEditCell class]]) {
        cell=(UserEditCell*) btn.superview.superview.superview;
    }else{
        cell=(UserEditCell*) btn.superview.superview;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UserInfo *selectedUser = _userList[indexPath.row];

    if([selectedUser.userName isEqualToString:@"admin"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"admin用户不能被删除" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
        return;
    }
    
    if([selectedUser.userName isEqualToString:[g_sDataManager userName]]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户不能删除自己" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
        return;
    }

    
    [_userList removeObjectAtIndex:indexPath.row];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection: 0]] withRowAnimation:UITableViewRowAnimationFade];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:selectedUser.userName forKey:@"uname"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_DELUSER_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        NSLog(@"[operation responseJSON]-->>%@",responseJSON);
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//删除成功
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"删除成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            
        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"无此用户" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}


- (IBAction)addUserAction:(id)sender
{

//     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        UserEditCell * cell = (UserEditCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//    [cell prepareForReuse];
    
    if(self.nameTextField.text.length==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"添加用户不能为空" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [self.nameTextField resignFirstResponder];
        [alert show];
        return ;
    }
    
    NSString *regexs = @"^[a-zA-Z0-9]*$";
    NSPredicate *predicates = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexs];
    if ([predicates evaluateWithObject:self.nameTextField.text] == NO) {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名称应该由字母或数字组成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }
    
    if([self.nameTextField.text length]>20){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名长度不能超过20位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }
    
    self.addUserBtn.enabled = NO;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:self.nameTextField.text forKey:@"uname"];
    [dic setValue:@"0000" forKey:@"upasswd"];
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_REGISTER_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        NSLog(@"[operation responseJSON]-->>%@",responseJSON);
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//添加成功
        {
            self.addUserBtn.enabled = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户添加成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            
            UserInfo *userInfo = [[UserInfo alloc] init];
            userInfo.userName= self.nameTextField.text;
            userInfo.userPassword = @"0000";
            [_userList addObject:userInfo ];            
            [self.tableView reloadData];
        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
            self.addUserBtn.enabled = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户已存在" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
        }
        
//        else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"2"]){
//            self.addUserBtn.enabled = YES;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户根目录创建失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
//            [alert show];
//        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"3"]){
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"数据通信失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
//            [alert show];
//        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"4"]){
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"共享文件夹创建失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
//            [alert show];
//        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"5"]){
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"摄像文件链接失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
//            [alert show];
//        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户添加失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            self.addUserBtn.enabled = YES;
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        self.addUserBtn.enabled = YES;
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }];
    [engine enqueueOperation:op];
    [self.nameTextField resignFirstResponder];
     
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}
-(IBAction) textFieldDoneEditing:(id) sender
{

    [sender resignFirstResponder];
}

- (void)closeModal
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - cellDidOpen cell的委托方法
- (void)cellDidOpen:(UITableViewCell *)cell
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    self.cellsCurrentlyEditing =currentEditingIndexPath;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UserEditCell * cell1 = (UserEditCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    //  [cell closeCell:NO notifyDelegateDidClose: NO ];
    [cell1 prepareForReuse];
}

- (void)cellDidClose:(UITableViewCell *)cell
{

    self.cellsCurrentlyEditing =nil;
}

- (IBAction)closeInput:(id)sender {
    
    [self.nameTextField resignFirstResponder];
}
-(void) loadData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_GETUSERS_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        NSLog(@"[operation responseJSON]-->>%@",responseJSON);
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"1"])//查询成功
        {
            if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"null"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"检索无结果" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
            }else{
                
                NSArray *responseJSONResult=responseJSON[@"result"];
                
                NSLog(@"[operation responseJSONResult]-->>%@",responseJSONResult);
                
                _userList = [NSMutableArray arrayWithCapacity:responseJSONResult.count];
                
                [responseJSONResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                    UserInfo *userInfo = [[UserInfo alloc] init];
                    userInfo.userName= dict[ @"user_name"];
                    
                    [_userList addObject:userInfo];
                }];
                [self.tableView reloadData];
            }
            
        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"0"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户名密码错误" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}
@end