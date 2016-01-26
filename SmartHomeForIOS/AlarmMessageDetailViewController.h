//
//  AlarmMessageDetailViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmMessageDetailViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSString *messageID;
@property (strong,nonatomic) NSString *recordVideoUrl;
@property (strong,nonatomic) NSDictionary *rowData;

@end
