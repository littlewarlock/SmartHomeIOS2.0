//
//  CloudLoginSuccessViewController.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudLoginSuccessViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *backgroundView;//蒙板
@property (weak, nonatomic) IBOutlet UIView *logoffView;//提示是否注销View
@property (strong, nonatomic) IBOutlet UILabel *AccountText;
@property (strong, nonatomic) IBOutlet UILabel *cid;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* cocloudid;
@property (strong, nonatomic) NSString* mac;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewToTop;
@property (weak, nonatomic) IBOutlet UIView *topView;

- (IBAction)update:(id)sender;
- (IBAction)cancel:(id)sender;

@end
