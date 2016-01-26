//
//  CameraRenameViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/24.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraRenameViewController : UIViewController

@property (strong,nonatomic)NSString* cameraName;

-(IBAction)cameraNameSaved:(id)sender;
-(IBAction)cancel:(id)sender;
@end
