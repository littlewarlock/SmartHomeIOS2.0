//
//  CollectionViewCell.h
//  project1
//
//  Created by apple1 on 15/9/11.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfo.h"
#import "CollectionViewCell.h"
@interface CollectionViewCell : UICollectionViewCell
    @property (strong,nonatomic) UIButton *checkButton;
    @property (nonatomic) BOOL select;
    @property (strong,nonatomic) FileInfo *fileinfo;
    @property (nonatomic,setter = setHasUpdate:) BOOL hasUpdate;
    @property (nonatomic,setter = setisSync:) BOOL isSync;
@end
