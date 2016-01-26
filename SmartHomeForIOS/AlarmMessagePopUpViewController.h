//
//  AlarmMessagePopUpViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/11/20.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmMessagePopUpViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelFrom;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIButton *buttonGoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonClose;
@property (strong, nonatomic) IBOutlet UIButton *buttonGoto2;
@property (strong, nonatomic) IBOutlet UIControl *viewTopSide;
@property (strong, nonatomic) IBOutlet UIControl *viewBottomSide;

@end
