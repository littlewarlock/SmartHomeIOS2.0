//
//  ViewController.h
//  AVPlayerDemo
//
//  Created by CaoJie on 14-5-5.
//  Copyright (c) 2014年 yiban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController
@property(strong,nonatomic) NSMutableString* filePath;
@property (strong,nonatomic) NSString       *netOrLocalFlag;//1 本地 0 网络
@property (strong, nonatomic) IBOutlet UIView *view;
@end
