//
//  PicCollectionViewController.h
//  project1
//
//  Created by apple1 on 15/9/9.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FileDialogDelegate.h"
@interface PicCollectionViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,FileDialogDelegate,MWPhotoBrowserDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *gridPic;
@end
