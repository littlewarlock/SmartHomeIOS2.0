//
//  DocumentViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/26.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSUUIDTool.h"
#import "FileDialogViewController.h"

@interface DocumentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIDocumentInteractionControllerDelegate,FileDialogDelegate>

@property (weak, nonatomic) IBOutlet UITableView *docTableView;
@property (strong, nonatomic) NSMutableDictionary *docDataDict;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;


@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@end
