//
//  TestTableViewCell.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "TestTableViewCell.h"
#import "CameraListViewController.h"

@implementation TestTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    //2015 12 29 hgc
    
//    //禁止自动转换AutoresizingMask
//    self.buttonAlarm.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self addConstraint:[NSLayoutConstraint
//                        constraintWithItem:self.buttonAlarm
//                        attribute:NSLayoutAttributeRight
//                        relatedBy:NSLayoutRelationGreaterThanOrEqual
//                        toItem:self.imagetest
//                        attribute:NSLayoutAttributeRight
//                        multiplier:0.0
//                         constant:4.0]];
//    
//    //注册KVO方法
//    [self.buttonAlarm addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
    //2015 12 29 hgc ed
    
}

//2015 12 29 hgc
//KVO回调
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (object == self.buttonAlarm && [keyPath isEqualToString:@"bounds"])
//    {
//        [self.buttonAlarm setTitle:NSStringFromCGSize(self.buttonAlarm.bounds.size) forState:UIControlStateNormal];
//    }
//}
//2015 12 29 hgc ed

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)chooseAppAction:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(chooseAppAction:)]) {
//        NSString *ss=  [NSString stringWithFormat: @"hgc%d",(long)sender.tag];
//        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"HGCTitle" message:ss delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alter show];
        
        [_delegate chooseAppAction:sender];//调用委托方法，来实现页面的跳转
    }
    
}
- (IBAction)buttonAlarmPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(buttonAlarmPressed:)]) {
        [_delegate buttonAlarmPressed:sender];
    }
}



@end
