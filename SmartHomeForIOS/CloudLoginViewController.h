//
//  CloudLoginViewController.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CloudLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *remindView;
@property (weak, nonatomic) IBOutlet UIView *sendPasswordView;

@property (strong, nonatomic) IBOutlet UILabel *emailText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;
@property (strong, nonatomic) IBOutlet UIButton *toRegister;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) IBOutlet UITextView *information;
@property (strong, nonatomic) NSString* cid;
@property (strong, nonatomic) NSString* emailflg;
@property (strong, nonatomic) NSString* logFlag;
@property (strong, nonatomic) NSString* mac;

- (IBAction)Login:(id)sender;
- (IBAction)finish:(id)sender;
- (IBAction)check:(id)sender;
- (IBAction)registerAgain:(id)sender;
- (IBAction)touch:(id)sender;

@end
