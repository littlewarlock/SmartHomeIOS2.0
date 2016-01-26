//
//  PicCollectionViewController.m
//  
//
//  Created by apple1 on 15/9/9.
//  Copyright (c) 2015年 BJB. All rights reserved.
//

#import "PicCollectionViewController.h"
#import "FileTools.h"
#import "CollectionViewCell.h"
#import <Photos/Photos.h>
#import "SDImageCache.h"
#import "MWCommon.h"
#import "PhotoTools.h"
#import "FileDialogViewController.h"
#import "NSUUIDTool.h"
#import "UIHelper.h"
#import "UploadFileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"

#define IMAGE_FILE_EXTENSION "jpg,png"

static NSString* _cellId = @"cellId";
@interface PicCollectionViewController ()
{
    CGFloat edgeLength; //图片单元格的宽度
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名

    FileDialogViewController *fileDialog;
    NSString *opType;
    MWPhoto *photo;
    NSMutableArray* pics;
    UIBarButtonItem *leftBtn;
    UIButton* rightBtn;
}
@end

@implementation PicCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame =CGRectMake(200, 0, 32, 32);
    [bt setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [bt addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    leftBtn=[[UIBarButtonItem alloc]initWithCustomView:bt];
    self.navigationItem.leftBarButtonItem=leftBtn;
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 32, 32);
    [rightBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(switchCollectionViewModel:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=rightItem;
    pics = [NSMutableArray array];
    [self reloadFileData];//加载数据
    self.gridPic.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout* fl = [[UICollectionViewFlowLayout alloc]init];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    edgeLength = (width-10)/4; //每个cell的边长
    fl.itemSize=CGSizeMake(edgeLength, edgeLength);
    fl.scrollDirection = UICollectionViewScrollDirectionVertical;
    fl.sectionInset = UIEdgeInsetsMake(2,2,2,2);
    fl.minimumLineSpacing = 2;
    fl.minimumInteritemSpacing = 2;
    self.gridPic.collectionViewLayout = fl;
    [self.gridPic registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    self.gridPic.dataSource = self;
    self.gridPic.delegate = self;

    self.gridPic.allowsMultipleSelection = NO;
    self.gridPic.allowsSelection = NO;
    //给图片列表添加手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.gridPic addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
    //底部按钮的添加
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [uploadBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn addTarget: self action: @selector(uploadFilesAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *uploadBtnItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    delBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn addTarget: self action: @selector(deleteFilesAction:) forControlEvents: UIControlEventTouchUpInside];
    [delBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    UIBarButtonItem *delBtnItem = [[UIBarButtonItem alloc] initWithCustomView:delBtn];
    UIBarButtonItem *space= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44.0, width, 44.0)];
    [toolBar setBarStyle:UIBarStyleDefault];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [toolBar setItems:@[uploadBtnItem,space,delBtnItem]];
    [self.view addSubview:toolBar];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellId forIndexPath:indexPath];
    NSInteger rowNo = indexPath.row;
    UIImageView *bgView ;
    UIImage* image=[UIImage imageNamed:pics[rowNo]];
    //bgView.alpha = 0.5;
    CGSize scaleToSize = {edgeLength,edgeLength};
    image=[PhotoTools getScaleImage:image scaleToSize:scaleToSize];
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];
    
    bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"done"]];
    FileInfo *fileinfo = [[FileInfo alloc] init];
    fileinfo.fileName = pics[rowNo];
    fileinfo.fileUrl =pics[rowNo];
    cell.fileinfo = fileinfo;
    bgView.contentMode = UIViewContentModeBottomRight;
    cell.selectedBackgroundView = bgView;
    cell.selected = false;
    
    selectedItemsDic   = [[NSMutableDictionary alloc] init];
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return pics.count;
}
#pragma mark -
#pragma mark switchCollectionViewModel 设置collectionview的状态（可选、不可选）
- (void)switchCollectionViewModel:(UIBarButtonItem *)sender {
    self.gridPic.allowsMultipleSelection = !self.gridPic.allowsMultipleSelection;
    self.gridPic.allowsSelection=!self.gridPic.allowsSelection;
    if (self.gridPic.allowsMultipleSelection) {
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"全选"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllItems:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }else{
        [selectedItemsDic removeAllObjects];
        self.gridPic.allowsMultipleSelection=NO;
        [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(returnAction:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
        [selectedItemsDic removeAllObjects];
    }

}

#pragma mark -
#pragma mark uploadFilesAction 打开上传文件对话框
- (void)uploadFilesAction:(UIBarButtonItem *)sender
{
    opType = @"upload";
    if (selectedItemsDic.count==0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择要上传的文件！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString* userName = [g_sDataManager userName];
    if (!userName || [userName isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
        [alert show];
        return;
    }
    
    
    if (selectedItemsDic.count>0) {
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = YES;
        fileDialog.cpath =@"/";
        fileDialog.isSelectFileMode = NO;
        fileDialog.fileDialogDelegate = self;
        [self.navigationController pushViewController:fileDialog animated:YES];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择图片" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
}

#pragma mark -
#pragma mark deleteFilesAction 删除
- (void)deleteFilesAction:(UIBarButtonItem *)sender
{
    opType =@"delete";
    NSLog(@"------delete action-----");
    
    if (!self.gridPic.allowsMultipleSelection){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择图片" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (selectedItemsDic.count>0) {
        for (NSString *filePath in [selectedItemsDic allKeys]){
            int result = [FileTools deleteFileByUrl:filePath];
        }
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已删除" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    [self reloadFileData];
    [self.gridPic reloadData];
    self.gridPic.allowsMultipleSelection = !self.gridPic.allowsMultipleSelection;
    self.gridPic.allowsSelection=!self.gridPic.allowsSelection;
    
    
    if (self.gridPic.allowsMultipleSelection) {
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
        
    }
    [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
    leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(returnAction:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

-(void) reloadFileData
{
    NSString* documentsPath = kDocument_Folder;
    NSMutableDictionary* fileDictionary = [[NSMutableDictionary alloc] init];
    fileDictionary = [FileTools getAllFilesByType:documentsPath skipDescendents:true fileExtend:@[@"jpg",@"png"]];
    FileInfo *dirList = [[FileInfo alloc] init];
    if (pics) {
        [pics removeAllObjects];
    }
    for (int i=0;i<fileDictionary.count;i++){
        dirList = [fileDictionary valueForKey:[NSString stringWithFormat:@"%d", i]];
        [pics addObject:dirList.fileUrl];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  
    //CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellId forIndexPath:indexPath];
//    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"done"]];
//    cell.selectedBackgroundView = bgView;
//    cell.selectedBackgroundView.autoresizesSubviews = NO;
//    bgView.contentMode = UIViewContentModeBottomRight;
    CollectionViewCell * cell =  (CollectionViewCell*)[self.gridPic cellForItemAtIndexPath:indexPath];

    if(self.gridPic.allowsSelection ==YES){
        if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
            [selectedItemsDic setObject:cell.fileinfo.fileUrl forKey:cell.fileinfo.fileUrl];
        }
    }
   cell.selected = YES;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell * cell =  (CollectionViewCell*)[self.gridPic cellForItemAtIndexPath:indexPath];
    if(cell && [[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl]){
        [selectedItemsDic removeObjectForKey:cell.fileinfo.fileUrl];
    }
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return pics.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < pics.count)
    {
        UIImage *image = [[UIImage alloc]init]; //创建image
        image = [image initWithContentsOfFile:pics[index]]; //获取图片
        photo = [MWPhoto photoWithImage:image];
        return photo;
    }

    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
//    if (index < _thumbs.count)
//        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
  //  return [[_selections objectAtIndex:index] boolValue];
    return false;
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
//    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
//    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark handleTap 点击图片时触发的事件
- (void)handleTap:(UITapGestureRecognizer *)sender
{
    opType = @"click";
    // Browser
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    CGPoint initialPinchPoint = [sender locationInView:self.gridPic];
    NSIndexPath* tappedCellPath = [self.gridPic indexPathForItemAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.gridPic.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            CollectionViewCell* cell = (CollectionViewCell*)[self.gridPic cellForItemAtIndexPath:tappedCellPath];
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            
            browser.displayActionButton = displayActionButton;
            browser.displayNavArrows = displayNavArrows;
            browser.displaySelectionButtons = displaySelectionButtons;
            browser.alwaysShowControls = displaySelectionButtons;
            browser.zoomPhotosToFill = YES;
            browser.enableGrid = enableGrid;
            browser.startOnGrid = startOnGrid;
            browser.enableSwipeToDismiss = NO;
            browser.autoPlayOnAppear = autoPlayOnAppear;
            NSUInteger index= [pics indexOfObject:cell.fileinfo.fileName];
            [browser setCurrentPhotoIndex:index];
            [self.navigationController pushViewController:browser animated:YES];
        }
    }
}
#pragma mark -
#pragma mark UIGestureRecognizerDelegate的委托方法 决定是否相应手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (self.gridPic.allowsMultipleSelection)
    {
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark alertView的委托方法
-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0 && [opType isEqualToString: @"upload"]) {
        [UIHelper showLoginView:self];
    }
}

#pragma mark -
#pragma mark chooseFileDirAction的委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
    if([opType isEqualToString:@"upload"]){
        
        NSString* cpath = fileDialog.cpath;
        NSString* requestHost = [g_sDataManager requestHost];
        NSRange range  = [requestHost rangeOfString:@":"];
        if (range.location != NSNotFound) {
            requestHost = [requestHost substringToIndex:range.location];
        }
        NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"%@/root/%@", requestHost,[g_sDataManager userName]];
        
        if (![cpath isEqualToString:@"/"]) {
            [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",cpath]];
        }
        
        for (NSString *filePath in [selectedItemsDic allKeys]){
            UploadFileTools * ud = [[UploadFileTools alloc] initWithLocalPath:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  withServer:uploadUrl withName:FTP_USERNAME withPass:FTP_PASSWORD];
            
            TaskInfo* task = [[TaskInfo alloc] init];
            task.taskId = [NSUUIDTool gen_uuid];
            task.taskName =filePath;
            task.taskType = @"上传";
            ud.taskId =  task.taskId;
            [[ProgressBarViewController sharedInstance].taskDic setObject:task forKey:task.taskId];
            [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
            [ud start];
        }
        [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
  
    }
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark selectAllItems 设置collectionview的全选
- (void) selectAllItems:(id)sender{
    for (int row=0; row<pics.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.gridPic selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];

        CollectionViewCell * cell=(CollectionViewCell*)[self.gridPic cellForItemAtIndexPath:indexPath];
        if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl])){
            [selectedItemsDic setObject:cell.fileinfo.fileUrl forKey:cell.fileinfo.fileUrl];
        }
    }
}

@end
