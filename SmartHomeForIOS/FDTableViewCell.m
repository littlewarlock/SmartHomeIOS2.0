//
//  FDTableViewCell.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/8.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "FDTableViewCell.h"
#import "FileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "KeyWordConstant.h"
@implementation FDTableViewCell

@synthesize select;
@synthesize fileinfo;
@synthesize hasUpdate;
@synthesize isSync;

- (id)initWithFile:(FileInfo *)file{
    self.fileinfo = file;
    UIButton *button= [self getCellButton];
    //  根据ftype不同分别初始化cell
    //CGSize scaleToSize = {34.0,24.0};
    if ([file.fileType isEqualToString:@"folder"]) {
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:file.fileName];
        
        self.imageView.image = [UIImage imageNamed:@"documents-icon"];
        if([file.isShare isEqualToString:@"1"]){
            self.imageView.image =  [UIImage imageNamed:@"share-icon"];
        }
        
        if([[file.cpath stringByAppendingPathComponent: file.fileName] isEqualToString:[@"/" stringByAppendingPathComponent: USB_FOLDER]]){
            self.imageView.image =  [UIImage imageNamed:@"usb-icon"];
        }
        if([[file.cpath stringByAppendingPathComponent: file.fileName] isEqualToString:[@"/" stringByAppendingPathComponent: SHARE_FOLDER]]){
            self.imageView.image =  [UIImage imageNamed:@"share-icon"];
        }
        
        self.textLabel.text = file.fileName;
        [self.textLabel setTextColor:[UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1] ];
        [self setDetailText];
    }else{
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:file.fileName];
        [self.contentView addSubview:button];
        self.imageView.image = [UIImage imageNamed:@"text-icon"];
        BOOL bRet = [[NSFileManager defaultManager] fileExistsAtPath:file.fileUrl];
        if (bRet) {
            NSArray *audioArray=  [NSArray arrayWithObjects:@"mp3", nil];
            BOOL isAudio = [audioArray containsObject:[[file.fileUrl pathExtension] lowercaseString]];
            if(isAudio){
                self.imageView.image =  [UIImage imageNamed:@"music-icon"];
                NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:file.fileUrl]];
                UIImage *image =  [audioDataDic objectForKey:@"Artwork"];
                if(image){
                    self.imageView.image =  [PhotoTools getScaleImage:image scaleToSize:[UIImage imageNamed:@"music-icon"].size];
                }else{
                    self.imageView.image = [UIImage imageNamed:@"music-icon"];
                }
            }
            
            NSArray *picArray=  [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg", nil];
            BOOL isPic = [picArray containsObject:[[file.fileUrl pathExtension] lowercaseString]];
            if(isPic){
                self.imageView.image =  [UIImage imageNamed:@"personal_photo"];
                UIImage *image=[UIImage imageNamed:file.fileUrl];
                image=[PhotoTools getScaleImage:image scaleToSize:[UIImage imageNamed:@"personal_photo"].size];
                if(image){
                    self.imageView.image = image;
                }
            }
            
            //本地添加视频缩略图(只支持mp4)
            //                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:file.fileUrl] options:nil];
            //                    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            //                    gen.appliesPreferredTrackTransform = YES;
            //                    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
            //                    NSError *error = nil;
            //                    CMTime actualTime;
            //                    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
            //                    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
            //本地添加视频缩略图
            NSArray *videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                                   @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
            BOOL isVideo = [videoArray containsObject:[[file.fileUrl pathExtension] lowercaseString]];
            if(isVideo){
                self.imageView.image = [UIImage imageNamed:@"personal_video"];
                UIImage *image = [FileTools getVideoDuartionAndThumb:file.fileUrl];
                NSError *error = nil;
                if(image && !error){
                    //CGSize scaleToSize = {[UIImage imageNamed:@"video-icon"].size.width,[UIImage imageNamed:@"video-icon"].size.height};
                    
                    self.imageView.image = [PhotoTools getScaleImage:image scaleToSize:[UIImage imageNamed:@"personal_video"].size];
                }
            }
            
        }else{
            self.imageView.image = [UIImage imageNamed:@"text-icon"];
            NSArray *audioArray=  [NSArray arrayWithObjects:@"mp3", nil];
            BOOL isAudio = [audioArray containsObject:[[file.fileName pathExtension] lowercaseString]];
            //CGSize scaleToSize = [UIImage imageNamed:@"music-icon"].size;
            if(isAudio){
                
                self.imageView.image = [UIImage imageNamed:@"music-icon"];
                //                //显示云端音频缩略图
                //                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                //                __block NSError *error = nil;
                //                [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                //                [dic setValue:file.cpath forKey:@"filePath"];
                //                [dic setValue:self.fileinfo.fileName forKey:@"fileName"];
                //
                //                NSString* requestHost = [g_sDataManager requestHost];
                //                NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                //                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                //
                //                MKNetworkOperation *op = [engine operationWithPath:REQUEST_VIDEO_URL params:dic httpMethod:@"POST" ssl:NO];
                //                [op addCompletionHandler:^(MKNetworkOperation *operation) {
                //                    NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                //                    NSString *videoPath =  [responseJSON objectForKey:@"videopath"];
                //
                //                    NSRange range  = [videoPath rangeOfString:@"/smarty_storage"];
                //                    NSString *subVideoPath = [videoPath  substringFromIndex:range.location];
                //                    NSString *videoUrl = [NSString stringWithFormat:@"%@%@%@",@"http://",requestHost,subVideoPath];
                //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //
                //
                
                ////                        NSError *error = nil;
                ////                        NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:videoUrl]];
                ////                        UIImage *image = [audioDataDic objectForKey:@"Artwork"];
                ////
                ////                        if(image){
                ////                            dispatch_async(dispatch_get_main_queue(), ^{
                ////                                self.imageView.image = [PhotoTools getScaleImage:image scaleToSize:[UIImage imageNamed:@"music-icon"].size];
                ////                                self.detailTextLabel.text = @"";
                ////                                self.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", fileinfo.fileChangeTime,fileinfo.fileSize];
                ////                            });
                ////                        }
                //
                ////                        AVURLAsset *avURLAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoUrl] options:nil];
                ////
                ////                        for (NSString *format in [avURLAsset availableMetadataFormats]) {
                ////
                ////                            for (AVMetadataItem *metadataItem in [avURLAsset metadataForFormat:format]) {
                ////
                ////                                if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                ////
                ////                                    //取出封面artwork，从data转成image显示
                ////
                ////                                    UIImage *artImageInMp3 = [UIImage imageWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                ////                                    self.imageView.image = [PhotoTools getScaleImage:artImageInMp3 scaleToSize:[UIImage imageNamed:@"music-icon"].size];
                ////                                }
                ////                            }
                ////                        }
                //
                //                    });
                //
                //
                //                }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                //                    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                //                }];
                //                [engine enqueueOperation:op];
                
            }
            
            NSArray *picArray=  [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg", nil];
            BOOL isPic = [picArray containsObject:[[file.fileName pathExtension] lowercaseString]];
            if(isPic){
                self.imageView.image =  self.imageView.image = [UIImage imageNamed:@"personal_photo"];
                NSMutableString *picUrl = [NSMutableString stringWithFormat:@"http://%@/%@",[g_sDataManager requestHost],REQUEST_PIC_URL];
                picUrl =[NSMutableString stringWithFormat:@"%@?uname=%@&filePath=%@&fileName=%@",picUrl,[[g_sDataManager userName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[file.cpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[file.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
                    UIImage *image = [UIImage imageWithData:data];
                    NSError *error = nil;
                    if(image && !error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *imageSync = [PhotoTools getScaleImage:image scaleToSize:[UIImage imageNamed:@"personal_photo"].size];
                            if(image && !error){
                                self.imageView.image =  imageSync;
                            }
                            self.detailTextLabel.text = @"";
                            self.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", fileinfo.fileChangeTime,fileinfo.fileSize];
                        });
                    }
                });
            }
            
            NSArray *videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                                   @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
            BOOL isVideo = [videoArray containsObject:[[file.fileName pathExtension] lowercaseString]];
            if(isVideo){
                self.imageView.image = [UIImage imageNamed:@"personal_video"];
                //显示云端视频缩略图
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                __block NSError *error = nil;
                [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                [dic setValue:file.cpath forKey:@"filePath"];
                [dic setValue:self.fileinfo.fileName forKey:@"fileName"];
                
                NSString* requestHost = [g_sDataManager requestHost];
                NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                
                MKNetworkOperation *op = [engine operationWithPath:REQUEST_VIDEO_URL params:dic httpMethod:@"POST" ssl:NO];
                [op addCompletionHandler:^(MKNetworkOperation *operation) {
                    NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                    NSString *videoPath =  [responseJSON objectForKey:@"videopath"];
                    
                    NSRange range  = [videoPath rangeOfString:@"/smarty_storage"];
                    NSString *subVideoPath = [videoPath  substringFromIndex:range.location];
                    NSString *videoUrl = [NSString stringWithFormat:@"%@%@%@",@"http://",requestHost,subVideoPath];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        UIImage *imageMK = [FileTools getVideoDuartionAndThumb:videoUrl];
                        if(imageMK){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.imageView.image = [PhotoTools getScaleImage:imageMK scaleToSize:[UIImage imageNamed:@"personal_video"].size];
                                self.detailTextLabel.text = @"";
                                self.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", fileinfo.fileChangeTime,fileinfo.fileSize];
                            });
                        }
                    });
                    
                    
                }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                }];
                [engine enqueueOperation:op];
                
                
            }
            
            NSArray *documentArray=  [NSArray arrayWithObjects:@"doc",@"docx",@"xls",@"xlsx",@"txt", nil];
            BOOL isDocument = [documentArray containsObject:[[file.fileName pathExtension] lowercaseString]];
            if(isDocument){
                NSError *error = nil;
                if([UIImage imageNamed:@"text-icon"] && !error){
                    self.imageView.image =  [UIImage imageNamed:@"text-icon"];
                }
            }
            
            
            
        }
        self.textLabel.text = file.fileName;
        [self.textLabel setTextColor:[UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1] ];
        [self setDetailText];
        
    }
    select = NO;
    
    
    iconImage = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImage];
    
    return self;
}

- (id)getCellButton
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(width-30, 18.0, 24.0, 24.0)];
    [button setImage:[ImageFactory getCheckImage:NO] forState:UIControlStateNormal];
    [button setImage:[ImageFactory getCheckImage:YES] forState:UIControlStateSelected];
    button.tag=_CHECK_BOX_BUTTON_;
    //  [button addTarget:self action:@selector(buttonTarget:)   forControlEvents:UIControlEventTouchUpInside];
    button.hidden=YES;
    return button;
}




- (void)setIsSync:(BOOL)flag{
    if (flag) {
        UIImageView *syncicon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"syncing.png"]];
        syncicon.frame = CGRectMake(10.0, 25.0, 30.0, 30.0);
        [self addSubview:syncicon];
    }
}

- (void)setIcon:(BOOL)flag {
    if (flag) {
        [iconImage setFrame:CGRectMake(10, 30, 27, 27)];
    }
    else {
        [iconImage setFrame:CGRectMake(10, 30, 27, 27)];
    }
    [iconImage setImage:[UIImage imageNamed:@"status_done_small"]];
}

- (void)setDetailText {
    
    if([self.fileinfo.fileType isEqualToString:@"folder"]){
        [self.detailTextLabel setTextColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:199.0/255 alpha:1] ];
        
        int i=0;
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:self.fileinfo.fileUrl];
        for (NSString *fileName in enumerator)
        {
            if(![[fileName pathExtension] isEqualToString:@""]){
                i++;
            }
        }
        
        BOOL bRet = [[NSFileManager defaultManager] fileExistsAtPath:self.fileinfo.fileUrl];
        
        if(bRet){
            self.detailTextLabel.text = [NSString stringWithFormat: @"%@ 共%zi个文件", fileinfo.fileChangeTime,i];
            
        }else{
            self.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", fileinfo.fileChangeTime,fileinfo.fileSize];
        }
        
    }else{
        [self.detailTextLabel setTextColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:199.0/255 alpha:1] ];
        self.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", fileinfo.fileChangeTime,fileinfo.fileSize];
    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

@end
