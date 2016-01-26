//
//  Cloudregister.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/10.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CloudRegisterViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *cocloudid;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) NSString* mac;

- (IBAction)finish:(id)sender;
- (IBAction)registers:(id)sender;
- (IBAction)change:(id)sender;
- (IBAction)touch:(id)sender;

@end
