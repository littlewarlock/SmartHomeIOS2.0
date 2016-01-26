//
//  CameraRecordHistoryViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraRecordHistoryViewController : UIViewController
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong,nonatomic)NSString *deviceID;
@property (strong,nonatomic)NSDate *titleDate;
@end
