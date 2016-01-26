//
//  PhotoTools.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "PhotoTools.h"



@implementation PhotoTools

#pragma mark -
#pragma mark getAlbums 获取所有相册
- (void)getAlbums {
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.groupArray=[[NSMutableArray alloc] init];
    NSString *tipTextWhenNoPhotosAuthorization; // 提示语
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group!= nil) {
                [self.groupArray addObject:group];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumsFinishedNotify" object:nil];
                });
            }else{
                *stop =YES;
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Group not found!\n");
        }];
    });

}


#pragma mark -
#pragma mark getAlbumAndPhotosByAlbums 根据获取相册及其所有图片
- (void)getAlbumAndPhotosByAlbums:(NSMutableArray *)albumsArray{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.photosArray = [[NSMutableArray alloc]init];
    
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<albumsArray.count; i++) {
        if (self.photosArray !=nil) {
            self.photosArray[i] = [[NSMutableArray alloc]init];
            dispatch_group_async(group, queue, ^{
            [(ALAssetsGroup* )albumsArray[i] enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result!=nil && self.photosArray!=nil && self.photosArray[i]!=nil){
                  [self.photosArray[i] addObject: result];
                }
            }];
        });
      }
   }
    //等group里的task都执行完后执行notify方法里的内容
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotosFinishedNotify" object:nil];
    });
    
}


#pragma mark -
#pragma mark getAllAlbumAndPhotos 获取相册及其所有图片
- (void)getALLAlbumAndPhotosByAlbums{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.groupArray=[[NSMutableArray alloc] init];
    NSString *tipTextWhenNoPhotosAuthorization; // 提示语
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    }
    self.photosArray = [[NSMutableArray alloc]init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group!= nil) {
                [self.groupArray addObject:group];
                int i = (int)[self.groupArray count] -1;
                if (self.photosArray !=nil) {
                    self.photosArray[i] = [[NSMutableArray alloc]init];
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result!=nil && self.photosArray!=nil && self.photosArray[i]!=nil){
                            NSString * type = [result valueForProperty:ALAssetPropertyType];
                            
                            // 这个类型不只是图片，判断一下
                            if([type isEqualToString:ALAssetTypePhoto])
                            {NSLog(@"－－－－－－－有相册－－－－－－－－－");
                                [self.photosArray[i] addObject: result];
                            }
                        }
                    }];
                }
            }else{
                *stop =YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotosFinishedNotify" object:nil];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Group not found!\n");
        }];
    });
    
}


#pragma mark -
#pragma mark getAllAlbumAndPhotos 获取视频
- (void)getALLAlbumAndVideosByAlbums{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.groupArray=[[NSMutableArray alloc] init];
    NSString *tipTextWhenNoPhotosAuthorization; // 提示语
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    }
    self.videosArray = [[NSMutableArray alloc]init];
     dispatch_async(dispatch_get_main_queue(), ^{
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group!= nil) {
                [self.groupArray addObject:group];
                if (self.videosArray !=nil) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result!=nil && self.videosArray!=nil){
                            NSString * type = [result valueForProperty:ALAssetPropertyType];
    
                            // 这个类型不只是图片，判断一下
                            if([type isEqualToString:ALAssetTypeVideo])
                            {
                                NSLog(@"－－－－－－－有视频－－－－－－－－－");
                                [self.videosArray addObject: result];
                                
                            }
                        }
                    }];
                }
            }else{
                *stop =YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VideosFinishedNotify" object:nil];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Group not found!\n");
        }];
    });
    
}
-(NSMutableArray *) getAlbumsArray{
    return self.groupArray;
}
-(NSMutableArray *) getPhotosArray{
    return self.photosArray;
}
-(NSMutableArray *) getVideosArray{
    return self.videosArray;
}

#pragma mark -
#pragma mark getScaleImage 根据宽高比返回图片
+ (UIImage*) getScaleImage:(UIImage *)image scaleToSize:(CGSize)size
{
    CGSize newSize;
    if (image.size.height / image.size.width > 1){
        newSize.height = size.height;
        newSize.width = size.height / image.size.height * image.size.width;
    } else if (image.size.height / image.size.width < 1){
        newSize.height = size.width / image.size.width * image.size.height;
        newSize.width = size.width;
    } else {
        newSize = size;
    }
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end
