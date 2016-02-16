//
//  AlbumUploadByBlockTool.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/12/3.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FileUploadByBlockOperation.h"
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface AlbumUploadByBlockTool : FileUploadByBlockOperation
@property(strong,nonatomic)ALAsset *cellAsset;
- (id)initWithLocalPath:(NSString *)localStr ip:(NSString*)ip withServer:(NSString*)serverStr
               withName:(NSString*)theName withPass:(NSString*)thePass  cellAsset:(ALAsset*)cellAsset;
@end
