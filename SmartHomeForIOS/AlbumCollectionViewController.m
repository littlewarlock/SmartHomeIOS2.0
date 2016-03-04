//
//  AlbumCollectionViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "PhotoTools.h"
#import "MWCommon.h"
#import "AlbumHeaderCell.h"
#import "NSUUIDTool.h"
#import "UIHelper.h"
#import "UploadFileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "DataManager.h"
#import "AlbumUploadByBlockTool.h"
static NSString* _cellId = @"album";
@interface AlbumCollectionViewController ()

@end

@implementation AlbumCollectionViewController{
    ALAsset* asset;
    ALAssetRepresentation *rap;
    CGImageRef ref;
    MWPhoto *photo;
    NSMutableArray* pics;
    NSUInteger sectionNo;//当前显示的是第section
    PhotoTools* photoTools;
    NSString *opType;    
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名
    FileDialogViewController *fileDialog;
    
    NSMutableArray* photosArray;
    NSMutableArray* albums; //保存所有相册的NSMutableArray对象
    NSMutableArray* albumNames; //保存所有相册名称的NSMutableArray
    NSDictionary* thumbnails; //保存所有相册图片的缩略图NSDictionary对象
    UIBarButtonItem *leftBtn;
    UIButton* rightBtn;
    NSOperationQueue *uploadQueue;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumGrid.backgroundColor = [UIColor whiteColor];
    [self.albumGrid registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:_cellId];
    [self.albumGrid registerClass:[AlbumHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HEADER"];
    
    self.navigationItem.title = @"My Photos";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:15.0/255 green:131.0/255 blue:255.0/255 alpha:1];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    leftBtn=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=leftBtn;
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pics =[[NSMutableArray alloc] init];
    rightBtn.frame =CGRectMake(200, 0, 32, 32);
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(switchCollectionViewModel:) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=rightItem;
    UICollectionViewFlowLayout* fl = [[UICollectionViewFlowLayout alloc]init];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat edgeLength = (width-10)/4; //每个cell的边长
    fl.itemSize=CGSizeMake(edgeLength, edgeLength);

    fl.scrollDirection = UICollectionViewScrollDirectionVertical;
    fl.sectionInset = UIEdgeInsetsMake(2,2,2,2);
    fl.minimumLineSpacing = 2;
    fl.minimumInteritemSpacing = 2;
    fl.headerReferenceSize = CGSizeMake(100,25);
    self.albumGrid.collectionViewLayout = fl;
    self.albumGrid.dataSource = self;
    self.albumGrid.delegate = self;
    
    self.albumGrid.allowsMultipleSelection = NO;
    self.albumGrid.allowsSelection = NO;
    //给图片列表添加手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.albumGrid addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
    
    photoTools = [[PhotoTools alloc]init];
    photosArray = [[NSMutableArray alloc]init];
    albums =[[NSMutableArray alloc]init];
    albumNames=[[NSMutableArray alloc]init];
    // [photoTools getAlbums];//获取所有相册
    [photoTools getALLAlbumAndPhotosByAlbums];
    //底部按钮的添加
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [uploadBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn addTarget: self action: @selector(uploadFilesAction) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *uploadBtnItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    delBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    [delBtn setTitle:@"移动" forState:UIControlStateNormal];
    
    [delBtn addTarget: self action: @selector(moveFilesAction) forControlEvents: UIControlEventTouchUpInside];
    
    
    [delBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    UIBarButtonItem *delBtnItem = [[UIBarButtonItem alloc] initWithCustomView:delBtn];
    UIBarButtonItem *space= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44.0, width, 44.0)];
    [toolBar setBarStyle:UIBarStyleDefault];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [toolBar setItems:@[uploadBtnItem,space,delBtnItem]];
    [self.view addSubview:toolBar];
    uploadQueue = [[NSOperationQueue alloc]init];
    [uploadQueue setMaxConcurrentOperationCount:1];
    selectedItemsDic   = [[NSMutableDictionary alloc] init];
}

- (void)uploadFilesAction{
    opType = @"2";
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
        fileDialog.isSelectFileMode =NO;
        fileDialog.fileDialogDelegate = self;
        fileDialog.onType = 2;
        [self.navigationController pushViewController:fileDialog animated:YES];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择图片" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
        
    }
}
- (void)moveFilesAction{
    opType = @"1";
    if (!self.albumGrid.allowsMultipleSelection){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择图片" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
   if (selectedItemsDic.count>0) {
       fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
       fileDialog.isShowFile =YES;
       fileDialog.isServerFile = NO;
       fileDialog.cpath =kDocument_Folder;
       fileDialog.rootUrl =kDocument_Folder;
       fileDialog.isSelectFileMode =NO;
       fileDialog.fileDialogDelegate = self;
       [self.navigationController pushViewController:fileDialog animated:YES];
   }else{
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择图片" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
       [alert show];
   }
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPhotosNotif:) name:@"PhotosFinishedNotify" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PhotosFinishedNotify" object:nil];//移除观察者
}

-(void)receivedAlbumsNotif:(NSNotification *)notification {
    albums = photoTools.getAlbumsArray;
    for(int i=0;i<albums.count;i++)
    {
        albumNames[i]= [((ALAssetsGroup*)albums[i])  valueForProperty:ALAssetsGroupPropertyName];
    }
    [photoTools getAlbumAndPhotosByAlbums:albums];
}

-(void)receivedPhotosNotif:(NSNotification *)notification {
    albums = photoTools.getAlbumsArray;
    for(int i=0;i<albums.count;i++)
    {
        albumNames[i]= [((ALAssetsGroup*)albums[i])  valueForProperty:ALAssetsGroupPropertyName];
    }
    photosArray = [photoTools getPhotosArray];
    for (int i=0; i<photosArray.count; i++) {
        for (int j=0; j<[photosArray[i] count]; j++) {
            asset = [photosArray[i] objectAtIndex:j];
            NSURL *url = [[asset defaultRepresentation]url];
            [pics addObject:[url absoluteString]];
        }
    }
    [self.albumGrid reloadData];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellId forIndexPath:indexPath];

    //   cell.backgroundView = bgView;
    FileInfo *fileinfo = [[FileInfo alloc] init];
    if (cell == nil) {
        cell = [[CollectionViewCell alloc] init];
    }
    NSInteger rowNo = indexPath.row;
    NSInteger section = indexPath.section;
    ALAsset* thumbPhoto = [photosArray[section] objectAtIndex:rowNo];
    CGImageRef  thumbRef = [thumbPhoto thumbnail];
    UIImageView *thumbImage = [[UIImageView alloc] initWithImage:[[UIImage alloc]initWithCGImage:thumbRef]];

    ALAsset *cellAsset = [photosArray[section] objectAtIndex:indexPath.row];
    NSURL *url = [[cellAsset defaultRepresentation]url];
    NSString *strUrl=[url absoluteString];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    NSArray * expStr = [strUrl componentsSeparatedByString:@"&ext="];
    NSArray * uuidStr = [expStr[0] componentsSeparatedByString:@"id="];
    
    
    NSString* filePath = [NSString stringWithFormat:@"%@/%@.%@",cachesDirectory,[uuidStr objectAtIndex:1],[expStr objectAtIndex:1]];
    
    fileinfo.fileUrl = filePath;
    fileinfo.fileName = [[[thumbPhoto defaultRepresentation]url] absoluteString]; //存放照片的url，
    cell.fileinfo = fileinfo;
    cell.backgroundView = thumbImage;
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checbox"]];
    bgView.contentMode = UIViewContentModeBottomRight;
    cell.selectedBackgroundView = bgView;
    cell.selected = false;
    return cell;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (!photosArray) {
        return 0;
    }
    else{
        return [photosArray count];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (photosArray && photosArray[section]) {
        return [photosArray[section] count];
    }else{
        return 0;
    }
}


-(NSInteger)collectionView:(UICollectionView *)colletionView numberOfItemsInsection:(NSInteger)section
{
    return [photosArray[section] count];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell * cell =  (CollectionViewCell*)[self.albumGrid cellForItemAtIndexPath:indexPath];
    if(cell && [[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl]){
        [selectedItemsDic removeObjectForKey:cell.fileinfo.fileUrl];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    CollectionViewCell * cell =  (CollectionViewCell*)[self.albumGrid cellForItemAtIndexPath:indexPath];
    NSInteger section = indexPath.section;
    ALAsset *cellAsset = [photosArray[section] objectAtIndex:indexPath.row];
    NSLog(@"indexPath.row=========%d",indexPath.row);
    if(self.albumGrid.allowsSelection ==YES){
        if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl])){
            [selectedItemsDic setObject:cellAsset forKey:cell.fileinfo.fileUrl];
        }
        
    }
    cell.selected = YES;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString* headerId =@"HEADER";
    NSInteger section = indexPath.section;
    if(section<[albumNames count])
    {
        NSString* albumName = albumNames[section];
        if (kind == UICollectionElementKindSectionHeader) {
            AlbumHeaderCell *header = [self.albumGrid dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
            header.text = [NSString stringWithFormat:@"%@",albumName];
            return header;
        }
    }
    return nil;
}
#pragma mark -
#pragma mark switchCollectionViewModel 设置collectionview的状态（可选、不可选）
- (void)switchCollectionViewModel:(UIBarButtonItem *)sender {
    self.albumGrid.allowsMultipleSelection = !self.albumGrid.allowsMultipleSelection;
    self.albumGrid.allowsSelection=!self.albumGrid.allowsSelection;
    if (self.albumGrid.allowsMultipleSelection) {
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
        left.frame =CGRectMake(0, 0, 50, 32);
        left.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [left setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [left setTitle:@"全选" forState:UIControlStateNormal];
        [left addTarget: self action: @selector(selectAllItems:) forControlEvents: UIControlEventTouchUpInside];
        leftBtn=[[UIBarButtonItem alloc]initWithCustomView:left];
        self.navigationItem.leftBarButtonItem=leftBtn;
    }else{
        [selectedItemsDic removeAllObjects];
        self.albumGrid.allowsMultipleSelection=NO;
        [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
        UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
        left.frame =CGRectMake(200, 0, 32, 32);
        [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
        leftBtn=[[UIBarButtonItem alloc]initWithCustomView:left];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }
    
}

#pragma mark -
#pragma mark handleTap 点击图片时触发的事件
- (void)handleTap:(UITapGestureRecognizer *)sender
{
    // Browser
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    CGPoint initialPinchPoint = [sender locationInView:self.albumGrid];
    NSIndexPath* tappedCellPath = [self.albumGrid indexPathForItemAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.albumGrid.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            CollectionViewCell* cell = (CollectionViewCell* )[self.albumGrid cellForItemAtIndexPath:tappedCellPath];
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
            //根据文件名获取当前图片的索引
            NSInteger index= [pics indexOfObject:cell.fileinfo.fileName];
            sectionNo = tappedCellPath.section;
            [self numberOfPhotosInPhotoBrowser:browser];
            [browser setCurrentPhotoIndex:index];
            [self.navigationController pushViewController:browser animated:YES];
        }
    }
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (sectionNo<photosArray.count) {
        return [photosArray[sectionNo] count];
    }else{
        return 0;
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < [photosArray[sectionNo] count])
    {
        if (photosArray && photosArray.count>0 ) {
            asset = [photosArray[sectionNo] objectAtIndex:index];
            rap = [asset  defaultRepresentation];
            ref= [rap fullResolutionImage];
            UIImage * image=[UIImage imageWithCGImage:ref];
            photo = [MWPhoto photoWithImage:image];
            ref = nil;
            rap = nil;
            return photo;
        }
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
    NSLog(@"ACTION!");
}

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
#pragma mark UIGestureRecognizerDelegate的委托方法 决定是否相应手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (self.albumGrid.allowsMultipleSelection)
    {
        return NO;
    }
    return YES;
}
-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PhotosFinishedNotify" object:nil];
}

#pragma mark -
#pragma mark chooseFileDirAction的委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
    
    switch ([opType intValue]) {
        case 1: //move
        {
            if (selectedItemsDic.count>0) {
                FileTools *fileTool = [[FileTools alloc]init];
                NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc]init];
                NSString *targetPath = fileDialog.cpath;
                [paramsDic setValue:targetPath forKey:@"targetPath"];
                [paramsDic setValue:selectedItemsDic forKey:@"selectedItemsDic"];
                [NSThread detachNewThreadSelector:@selector(moveAssets:) toTarget:fileTool withObject:paramsDic];
            }
            break;
        }
        case 2:{ //upload
            
            NSString* cpath = fileDialog.cpath;
            NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"/%@",[g_sDataManager userName]];
            
            if (![cpath isEqualToString:@"/"]) {
                [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",cpath]];
            }
            
            for (NSString *filePath in [selectedItemsDic allKeys]){
                NSString *fileName = [filePath lastPathComponent];
                BOOL operationIsExist = NO;
//                for (AlbumUploadByBlockTool *operation in [uploadQueue operations]) {
//                    if ([operation.fileName isEqualToString:fileName]) {
//                        operationIsExist = YES;
//                    }
//                }
                if (!operationIsExist) {
                    ALAsset* cellAsset =[selectedItemsDic valueForKey:filePath];
                    AlbumUploadByBlockTool *operation = [[AlbumUploadByBlockTool alloc] initWithLocalPath:filePath ip:[g_sDataManager requestHost]withServer:uploadUrl withName:[g_sDataManager userName] withPass:[g_sDataManager password] cellAsset:cellAsset];
                    TaskInfo *taskInfo = [[TaskInfo alloc] init];
                    taskInfo.taskId = [NSUUIDTool gen_uuid];
                    taskInfo.taskName =fileName;
                    taskInfo.taskType = @"上传";
                    operation.taskId =  taskInfo.taskId;
                    operation.fileName = fileName;
                    operation.taskId = taskInfo.taskId;
                    operation.taskInfo = taskInfo;
                    [uploadQueue addOperation:operation];
                    [[ProgressBarViewController sharedInstance].uploadTaskDic  setObject:taskInfo forKey:taskInfo.taskId];
                    [[ProgressBarViewController sharedInstance] addProgressBarRow:taskInfo];
                }
            }
            [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark alertView的委托方法
-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0 && [opType intValue]==2) {
        [UIHelper showLoginView:self];
    }
}

- (void)returnAction:(UIBarButtonItem *)sender {
    if (self.isOpenFromAppList){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark -
#pragma mark selectAllItems 设置collectionview的全选
- (void) selectAllItems:(id)sender{
    for(int i=0;i<[photosArray count];i++)
    {
        for(int j=0;j<[photosArray[i] count];j++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            ALAsset *cellAsset = [photosArray[i] objectAtIndex:indexPath.row];
            [self.albumGrid selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            
           // CollectionViewCell * cell=(CollectionViewCell*)[self.albumGrid cellForItemAtIndexPath:indexPath];
            NSURL *url = [[cellAsset defaultRepresentation]url];
            NSString *strUrl=[url absoluteString];
            
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            
            NSArray * expStr = [strUrl componentsSeparatedByString:@"&ext="];
            NSArray * uuidStr = [expStr[0] componentsSeparatedByString:@"id="];
            
            
            NSString* filePath = [NSString stringWithFormat:@"%@/%@.%@",cachesDirectory,[uuidStr objectAtIndex:1],[expStr objectAtIndex:1]];
            
            NSString *fileUrl = filePath;
            if(self.albumGrid.allowsSelection ==YES){
                if(![[selectedItemsDic allKeys] containsObject:fileUrl] && fileUrl!=nil){
                    [selectedItemsDic setObject:cellAsset forKey:fileUrl];
                }
            }
        }
    }
}
@end
