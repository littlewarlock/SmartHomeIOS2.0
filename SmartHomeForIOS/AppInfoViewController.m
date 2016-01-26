//
//  AppInfoViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/27.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AppInfoViewController.h"


@interface AppInfoViewController ()

@end

@implementation AppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    if(_appInfo!=nil)
    {
        UIImage *image = [UIImage imageNamed:_appInfo.appIconName];
    
        _iconImage.image = image;
    
        _appNameLabel.text =_appInfo.appName;
        _appInfoTextView.text = _appInfo.appInfo;
        if([myDelegate.selectedAppArray containsObject:_appInfo] )
        {
            _appSwitch.on = YES;
        }
        else{
            _appSwitch.on = NO;

        }
    }
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableDisableAppAction:(id)sender {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate){
        if(appDelegate.selectedAppArray.count>0)
        {
            BOOL appStatus = _appSwitch.on;
            NSInteger index =-1;
            for (NSInteger i =0;i<appDelegate.selectedAppArray.count;i++) {
                AppInfo *appInfo = ( AppInfo *)appDelegate.selectedAppArray[i];
                if(appInfo!=nil && appInfo.appKey == _appIndex )
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
                        if(appInfo.appKey==_appIndex)
                        {
                            [appDelegate.selectedAppArray addObject:appInfo];
                        }
                    }
                }
            }
            
        }

    }
}
@end
