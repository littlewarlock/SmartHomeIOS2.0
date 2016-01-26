//
//  CustomActionSheet.m
//  SmartHomeForIOS
//自定义view 实现ActionSheet
//  Created by riqiao on 15/10/30.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CustomActionSheet.h"
#import "UIButton+UIButtonExt.h"
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
@interface CustomActionSheet(){
    UIColor *textColorNormal;
    UIColor *textColorPressed;
    UIColor *contentViewColor;
    UIButton *moveBtn;
    UIButton *copyBtn;
    UIButton *delBtn;
    UIButton *renameBtn;
}
@end

@implementation CustomActionSheet

+(instancetype)styleDefault{
    CustomActionSheet* sheet = [[CustomActionSheet alloc]initWithFrame:CGRectMake(0,0,UIScreen.mainScreen.bounds.size.width,UIScreen.mainScreen.bounds.size.height)];
    [sheet setBackgroundColor:[UIColor clearColor]];
    sheet.contentView = [sheet getContentView];
    //  sheet.cancleBtn = [sheet getCancleBtn];
    [sheet addSubview:sheet.contentView];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:sheet action:@selector(handleSingleTap:)];
    [sheet addGestureRecognizer:singleTap];
    singleTap.delegate = sheet;
    singleTap.cancelsTouchesInView = NO;
    sheet.userInteractionEnabled = YES;
    return sheet;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        textColorNormal=RGBACOLOR(255, 255, 255,1);
        textColorPressed = RGBACOLOR(209.0, 213.0, 219.0, 0.9);
        contentViewColor = RGBACOLOR(68, 68, 68, 0.9);
    }
    return self;
}

-(UIButton *)getCancleBtn{
    self.cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancleBtn setTitleColor:textColorPressed forState:UIControlStateHighlighted];
    [self.cancleBtn setTitleColor:textColorNormal forState:UIControlStateNormal];
    [self.cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    [self.cancleBtn sizeToFit];
    self.cancleBtn.backgroundColor = RGBACOLOR(119.0, 136.0, 153.0,1);
    CALayer * downButtonLayer = [self.cancleBtn layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
    
    self.cancleBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *cancleConstrainX = [NSLayoutConstraint constraintWithItem:self.cancleBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:10];
    NSLayoutConstraint *cancleConstrainY = [NSLayoutConstraint constraintWithItem:self.contentView  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.cancleBtn attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:10];
    NSLayoutConstraint *cancleConstrainBottom = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.cancleBtn attribute:NSLayoutAttributeBottom multiplier:1.0f constant:30];
    [self.contentView addConstraint:cancleConstrainX];
    [self.contentView addConstraint:cancleConstrainY];
    [self.contentView addConstraint:cancleConstrainBottom];
    [self.contentView addSubview:self.cancleBtn];
    return self.cancleBtn;
}
-(UIView *)getContentView{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat height = size.height;
    CGFloat width = size.width;
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, height-130, 0, 0)];
    
    UIImage *moveImage = [UIImage imageNamed:@"move"];
    CGSize buttonSize = moveImage.size;
    CGFloat buttonWidth = 32;
    CGFloat buttonHeight = buttonSize.height +20;
    
    CGFloat marginLeft = (width-4*buttonWidth)/5;
    CGFloat marginTop = 65 - buttonHeight / 2;
    //初始化并加载四个分类按钮
    
    UIImage *copyImage = [UIImage imageNamed:@"copy"];
    copyBtn = [[UIButton alloc] initWithFrame:CGRectMake(marginLeft, marginTop, buttonWidth, buttonWidth)];
    copyBtn.titleLabel.font =[UIFont systemFontOfSize: 10];
    [copyBtn setTitle:@"复制" forState:UIControlStateNormal];
    [copyBtn setImage:copyImage forState:(UIControlStateNormal)];
    [copyBtn setTitleColor:textColorNormal forState:UIControlStateNormal];
    [copyBtn addTarget: self action: @selector(buttonEventHandleAction:) forControlEvents: UIControlEventTouchUpInside];
    [copyBtn centerImageAndTitle];
    [self.contentView addSubview:copyBtn];
    moveBtn = [[UIButton alloc] initWithFrame:CGRectMake(marginLeft*2+buttonWidth, marginTop, buttonWidth, buttonWidth)];
    moveBtn.titleLabel.font =[UIFont systemFontOfSize: 10];
    [moveBtn setTitleColor:textColorNormal forState:UIControlStateNormal];
    [moveBtn setTitle:@"移动" forState:UIControlStateNormal];
    [moveBtn setImage:moveImage forState:(UIControlStateNormal)];
    [moveBtn addTarget: self action: @selector(buttonEventHandleAction:) forControlEvents: UIControlEventTouchUpInside];
    [moveBtn centerImageAndTitle];
    
    [self.contentView addSubview:moveBtn];
    
    UIImage *rechristenImage = [UIImage imageNamed:@"rechristen"];
    renameBtn = [[UIButton alloc] initWithFrame:CGRectMake(marginLeft*3+2*buttonWidth, marginTop, buttonWidth, buttonWidth)];
    renameBtn.titleLabel.font =[UIFont systemFontOfSize: 10];
    [renameBtn setTitle:@"重命名" forState:UIControlStateNormal];
    [renameBtn setTitleColor:textColorNormal forState:UIControlStateNormal];
    [renameBtn setImage:rechristenImage forState:(UIControlStateNormal)];
    [renameBtn centerImageAndTitle];
    [renameBtn addTarget: self action: @selector(buttonEventHandleAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.contentView addSubview:renameBtn];
    UIImage *deleteImage = [UIImage imageNamed:@"delete"];
    delBtn = [[UIButton alloc] initWithFrame:CGRectMake(marginLeft*4+3*buttonWidth, marginTop, buttonWidth, buttonWidth)];
    delBtn.titleLabel.font =[UIFont systemFontOfSize: 10];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn setTitleColor:textColorNormal forState:UIControlStateNormal];
    [delBtn setImage:deleteImage forState:(UIControlStateNormal)];
    [delBtn addTarget: self action: @selector(buttonEventHandleAction:) forControlEvents: UIControlEventTouchUpInside];
    [delBtn centerImageAndTitle];
    [self.contentView addSubview:delBtn];
    
    self.contentView.backgroundColor = contentViewColor;
    return self.contentView;
}

#pragma mark -
#pragma mark showSheet 显示actionsheetView
-(void)showSheet:(UIViewController *)controller{
    [self setupInitPostion:controller];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    [UIView animateWithDuration:0.5f animations:^{
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.9];
        [controller.view setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
        [controller.navigationController.navigationBar setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
        [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,                         height-130,width,130)];
        
    }
                     completion:nil];
}

#pragma mark -
#pragma mark dismissSheet 隐藏actionsheetView
-(void)dismissSheet:(UIViewController *)controller{
    [UIView animateWithDuration:0.25f animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
        [controller.view setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
        [controller.navigationController.navigationBar setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
        [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView* v = (UIView*)obj;
            [v setFrame:CGRectMake(v.frame.origin.x,UIScreen.mainScreen.bounds.size.height,v.frame.size.width,v.frame.size.height)];
        }];
    }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark -
#pragma mark actionCancle 取消按钮的处理事件
-(void)cancleAction{
    if ([self.delegate respondsToSelector:@selector(cancleAction)]) {
        [self.delegate cancleAction];
    }
}

-(void)setupInitPostion:(UIViewController *)controller{
    [UIApplication.sharedApplication.keyWindow?UIApplication.sharedApplication.keyWindow:UIApplication.sharedApplication.windows[0] addSubview:self];
    [self.superview bringSubviewToFront:self];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat height = size.height;
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,height,self.frame.size.width,self.frame.size.height)];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView* touchedView = [touch view];
    if([touchedView isKindOfClass:[UIButton class]]) {
        return NO;
    }
    CGPoint point = [touch locationInView:self];
    BOOL contains = CGRectContainsPoint(self.contentView.frame,  point);
    if (contains) {
        return NO;
    }
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
    [self cancleAction];
}

-(void)setButtonState:(NSInteger)buttonIndex buttonState:(BOOL)enabled
{
    switch (buttonIndex) {
        case 1:
        {
            copyBtn.enabled = enabled;
            
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"copy"];
                [copyBtn setImage:image forState:(UIControlStateNormal)];
            }else{
                UIImage *image = [UIImage imageNamed:@"copy-prohibt"];
                [copyBtn setTitleColor:[UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1] forState:UIControlStateNormal];
                [copyBtn setImage:image forState:(UIControlStateNormal)];
            }
            
        }
            break;
        case 2:
        {
            moveBtn.enabled = enabled;
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"move"];
                [moveBtn setImage:image forState:(UIControlStateNormal)];
            }else{
                UIImage *image = [UIImage imageNamed:@"move-prohibt"];
                [moveBtn setTitleColor:[UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1] forState:UIControlStateNormal];
                [moveBtn setImage:image forState:(UIControlStateNormal)];
            }
            
        }
            break;
        case 3:
        {
            renameBtn.enabled = enabled;
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"rechristen"];
                [renameBtn setImage:image forState:(UIControlStateNormal)];
            }else{
                UIImage *image = [UIImage imageNamed:@"rechristen-prohibt"];
                [renameBtn setTitleColor:[UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1] forState:UIControlStateNormal];
                [renameBtn setImage:image forState:(UIControlStateNormal)];
            }
        }
            break;
        case 4:
        {
            delBtn.enabled = enabled;
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"delete"];
                [delBtn setImage:image forState:(UIControlStateNormal)];
            }else{
                UIImage *image = [UIImage imageNamed:@"delete-prohibt"];
                [delBtn setTitleColor:[UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1] forState:UIControlStateNormal];
                [delBtn setImage:image forState:(UIControlStateNormal)];
            }
        }
            break;
        default:
            break;
    }
}
- (void)buttonEventHandleAction:(id)sender{
    if(sender == copyBtn){
        [self.delegate customActionSheet:1];
    }else if(sender ==moveBtn ){
        [self.delegate customActionSheet:2];
    }else if(sender == renameBtn){
        [self.delegate customActionSheet:3];
    }else if(sender == delBtn){
        [self.delegate customActionSheet:4];
    }
}
@end
