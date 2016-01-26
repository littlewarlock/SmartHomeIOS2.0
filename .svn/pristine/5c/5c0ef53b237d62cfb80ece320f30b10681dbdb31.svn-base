
//
//  PhotoTools.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface PhotoTools : NSObject{

}
@property(strong,nonatomic) ALAssetsLibrary* assetsLibrary;
@property(strong,nonatomic) NSMutableArray* groupArray;
@property(strong,nonatomic) NSMutableArray* photosArray;
@property(strong,nonatomic) NSMutableArray* videosArray;
- (void)getAlbums ;
- (void)getAlbumAndPhotosByAlbums:(NSMutableArray *)albumsArray;
- (void)getALLAlbumAndVideosByAlbums;
- (void)getALLAlbumAndPhotosByAlbums;

- (NSMutableArray*) getAlbumsArray;
- (NSMutableArray*) getPhotosArray;
- (NSMutableArray*) getVideosArray;
#pragma mark -
#pragma mark getScaleImage 根据宽高比返回图片
+ (UIImage*) getScaleImage:(UIImage *)image scaleToSize:(CGSize)size;
@end
