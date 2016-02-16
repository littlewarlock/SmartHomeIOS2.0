//
//  CameraRecordHistoryViewCell.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/10/20.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraRecordHistoryViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIImageView *imageForMulSelect;

@end
