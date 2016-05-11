//
//  WifiLIistCell.h
//  SmartHomeForIOS
//
//  Created by 北京算云联科科技有限公司 on 16/3/4.
//  Copyright © 2016年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WifiLIistCellDelegate <NSObject>

- (void)setupAp;

@end
@interface WifiLIistCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btn;


@property (weak, nonatomic) id <WifiLIistCellDelegate> delegate;

@end
