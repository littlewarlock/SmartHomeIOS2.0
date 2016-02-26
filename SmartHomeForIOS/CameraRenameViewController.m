//
//  CameraRenameViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/24.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraRenameViewController.h"

@interface CameraRenameViewController ()
@property (strong, nonatomic) IBOutlet UITextField *cameraNameField;

@end

@implementation CameraRenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //2016 02 24 category
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServerSessionOutOfTime) name:@"letuserlogout" object:nil];
    
    self.cameraNameField.text = _cameraName;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(cameraNameSaved:)];
    

    
    UIBarButtonItem *leftBTN = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"iconfont-close-3.png"]
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = leftBTN;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)cameraNameSaved:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    _cameraName =  self.cameraNameField.text;
    
    
    //请求服务器重新保存cameraname，然后跳转到上一页
}

-(void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
