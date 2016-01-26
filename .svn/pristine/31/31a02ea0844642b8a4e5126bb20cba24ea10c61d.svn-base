//
//  CameraSnapshotHistoryCollectionViewCell.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/12/2.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraSnapshotHistoryCollectionViewCell.h"
#import "UIView+PBExtend.h"

@interface CameraSnapshotHistoryCollectionViewCell ()<UIScrollViewDelegate>
{
    CGFloat _zoomScale;
}
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;

@end

@implementation CameraSnapshotHistoryCollectionViewCell

- (void)awakeFromNib {
    //
    self.layer.cornerRadius = 5.0f;
    
    
    UITapGestureRecognizer *tap_double_imageViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_double_imageViewTap:)];
    tap_double_imageViewGesture.numberOfTapsRequired = 2;
    
    [self.myScrollView addGestureRecognizer:tap_double_imageViewGesture];
    
    //设置UIScrollView的滚动范围和图片的真实尺寸一致
    self.myScrollView.contentSize=self.showImg.image.size;
    
    
    //设置实现缩放
    //设置代理scrollview的代理对象
    self.myScrollView.delegate=self;
    //设置最大伸缩比例
    self.myScrollView.maximumZoomScale=5.0;
    //设置最小伸缩比例
    self.myScrollView.minimumZoomScale=0.5;

}



-(void)tap_double_imageViewTap:(UITapGestureRecognizer *)tap{
    
    NSLog(@"tap_double_imageViewTap");
    
    if(!self.showImg) return;
    
    //标记
    
    CGFloat zoomScale = self.myScrollView.zoomScale;
    NSLog(@"zoomScale==%f",zoomScale);
    if(zoomScale<=1.0f){
        NSLog(@"zoomScale==%f",zoomScale);
        NSLog(@"if");
        CGPoint loc = [tap locationInView:tap.view];
        
        CGFloat wh =1;
        
        CGRect rect = [UIView frameWithW:wh h:wh center:loc];
        
//        [self.myScrollView setZoomScale:5.0f animated:YES];
        [self.myScrollView zoomToRect:rect animated:YES];
    }else{
        NSLog(@"zoomScale==%f",zoomScale);
        NSLog(@"else");
        [self.myScrollView setZoomScale:1.0f animated:YES];
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
         return self.showImg;
}


@end
