//
//  H264ViewController.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/12/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import "swscale.h"

#include "avformat.h"


@interface H264ViewController : UIViewController
{
    AVCodecContext *codec;
    AVPacket packetBuf;
    AVFrame *pFrame;
    AVPicture picture;
    
    struct SwsContext *img_convert_ctx;

}

@property (nonatomic) int outputWidth, outputHeight;


@end
