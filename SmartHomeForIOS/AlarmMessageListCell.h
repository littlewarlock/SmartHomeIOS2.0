//
//  AlarmMessageListCell.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/11/17.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmMessageListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelSubTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imagePoint;
@property (strong, nonatomic) IBOutlet UIImageView *imageSnapshot;

@end
