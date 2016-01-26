//
//  H264ViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/12/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "H264ViewController.h"

@interface H264ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation H264ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSThread *threadDecode = [[NSThread alloc] initWithTarget:self selector:@selector(decodeVideo) object:nil];
    [threadDecode start];

}


-(void)decodeVideo
{
    avcodec_register_all();
    av_register_all();
    
    AVCodec *videoCodec = avcodec_find_decoder(CODEC_ID_H264);  //得到264的解码器
    AVCodecParserContext *avParserContext = av_parser_init(CODEC_ID_H264);//得到解析帧类，主要用于后面的帧头查找
    codec = avcodec_alloc_context3(videoCodec);//解码会话层
    pFrame = avcodec_alloc_frame();
    
    av_init_packet(&packetBuf);//初始化
    packetBuf.data = NULL;
    packetBuf.size = 0;
    
    //初始化一块内存来存储
    #define MAX_LEN  1024 * 50
    
    int readFileLen = 1;
    char readBuf[MAX_LEN];
    unsigned char *parseBuf;
    int parseBufLen = 0;
    int frameFinished = 10;
    
    
    FILE *myH264 = fopen("/Users/apple2/Desktop/VLC/H264/3-1video-H264-1", "r");

//    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"c4.h264" ofType:nil];
//    FILE *myH264 = fopen([path2 cStringUsingEncoding:NSMacOSRomanStringEncoding], "r");
    
    while(readFileLen >0){
        
        readFileLen = fread(readBuf, 1, sizeof(readBuf), myH264);//
        if(readFileLen <= 0){
            break;
        }else{
            int handleLen = 0;
            int handleFileLen = readFileLen;
            
            while(handleFileLen >0){
                av_parser_parse2(avParserContext,codec, &parseBuf, &parseBufLen, readBuf + handleLen, handleFileLen, 0, 0, 0);//查找264帧头
//                handleFileLen -= nLength;
//                handleLen += nLength;
                
                if(parseBufLen <= 0){
                    continue;//<span style="font-family: Arial, Helvetica, sans-serif;">查找不到帧头
                }
                
                packetBuf.size = parseBufLen;
                packetBuf.data = parseBuf;
                
                while (packetBuf.size > 0) {
                    int decodeLen = avcodec_decode_video2(codec, pFrame, &frameFinished, &packetBuf);
                    if(decodeLen <= 0){
                        break;//解码失败
                    }
                    packetBuf.size -= decodeLen;
                    packetBuf.data += decodeLen;
                    
                    if (frameFinished >0) {//解码成功
                        avpicture_get_size(PIX_FMT_RGB24, codec->width, codec->height);
                        
                        [self performSelectorOnMainThread:@selector(displayVideo) withObject:nil waitUntilDone:YES];//用主线程显示图片
                        
                        [NSThread sleepForTimeInterval:0.2];//设置图片显示间隔
                    }
                }
            }
        }
    }
    
    
    av_free(codec);
    av_free_packet(&packetBuf);
    av_frame_free(&pFrame);
    
}

-(void)displayVideo{

    self.outputWidth = 1980;
    self.outputHeight = 1200;
    self.imageView.image = self.currentImage;

}

-(void)setOutputWidth:(int)newValue {
    if (_outputWidth == newValue) return;
    _outputWidth = newValue;
}

-(void)setOutputHeight:(int)newValue {
    if (_outputHeight == newValue) return;
    _outputHeight = newValue;
    [self setupScaler];
}

-(void)setupScaler {
    
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, _outputWidth, _outputHeight);
    
    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(codec->width,
                                     codec->height,
                                     codec->pix_fmt,
                                     _outputWidth,
                                     _outputHeight,
                                     PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
}

-(UIImage *)currentImage {
    if (!pFrame->data[0]) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:_outputWidth height:_outputHeight];
}

-(void)convertFrameToRGB {
    sws_scale(img_convert_ctx, pFrame->data, pFrame->linesize,
               0, codec->height,
               picture.data, picture.linesize);
    
}

-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height {
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}



@end
