//
//  regsuccess.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/18.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterSuccessViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString* texts;
@property (strong, nonatomic) NSString* cid;
@property (strong, nonatomic) NSString* mac;

@end
