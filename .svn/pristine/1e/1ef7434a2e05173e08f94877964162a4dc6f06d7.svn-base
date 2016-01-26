//
//  MasterViewController.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/9/9.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UserEditViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
- (IBAction)closeInput:(id)sender;

//@property(weak,nonatomic) NSMutableArray * userList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)addUserAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *addUserBtn;
@property (nonatomic, strong) NSIndexPath *cellsCurrentlyEditing;

@property (strong, nonatomic) NSMutableArray *selectedUserArray;
@end
