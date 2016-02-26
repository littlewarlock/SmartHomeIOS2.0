//
//  LocalFileViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/6.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "UIButton+UIButtonExt.h"
#import "LocalFileViewController.h"
#import "LoginViewController.h"
#import "FileInfo.h"
#import "VideoViewController.h"
#import "AudioTableViewController.h"
#import "DocumentViewController.h"
#import "FileTools.h"
#import "FileCopyTools.h"
#import "FileDownloadTools.h"
#import "UIHelper.h"
#import "FileUploadByBlockOperation.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "CustomActionSheet.h"
#import "AudioViewController.h"

#import "DeckTableViewController.h"
#import "BackupHandler.h"
#import "FileUploadByBlockTool.h"
#import "AlbumCollectionViewController.h"
#import "TableViewDelegate.h"
#import "FileHandler.h"
#import "NSOperationUploadQueue.h"

#define AU_Cell_Height 52



@interface LocalFileViewController ()<UITabBarDelegate>
{
    UIBarButtonItem *leftBtn;
    UIButton* rightBtn;
    NSMutableDictionary* selectedTableDataDic; //存储所有选中的行的文件名
    FileDialogViewController *fileDialog;
    NSOperationQueue *copyAndMoveQueue;
    CustomActionSheet *sheet;
    LocalFileHandler *localFileHandler;
    BOOL isCheckedAll;
    NSInteger currentModel; //0,表示正常模式 1，表示编辑模式 区分底部不同按钮的处理事件
    NSMutableArray *pics;   //照片
    NSMutableArray *audiosUrl;  //音频
    NSMutableArray *videos;  //视频
    NSMutableArray *audioPlayerThumbsArray;//音频缩略图
    MWPhoto *photo;
    NSArray *audioArray;
    NSArray *videoArray;
    NSArray *picArray;
    
    NSMutableDictionary *selectedItemsDic;//文件下载选择的文件名
    UITableView *tableView;
    TableViewDelegate *tableViewDelegate;
    NSMutableArray *duplicateFileNamesArray;
    FileHandler *fileHandler;
    NSMutableArray *sourceDirsArray ;
    NSMutableArray *sourceFilesArray;
}
@end

@implementation LocalFileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:15.0/255 green:131.0/255 blue:255.0/255 alpha:1];
    self.navigationItem.title = @"本地文档";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [left setTintColor:[UIColor whiteColor]];
    left.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnBeforeWindowAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 50, 30);
    [rightBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(switchTableViewModel:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    [self.fileListTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.fileListTableView setSeparatorInset:UIEdgeInsetsZero]  ;
    selectedTableDataDic = [[NSMutableDictionary alloc] init];
    
    copyAndMoveQueue = [[NSOperationQueue alloc] init];
    [copyAndMoveQueue setMaxConcurrentOperationCount:1];
    
    localFileHandler = [[LocalFileHandler alloc] init];
    localFileHandler.localFileHandlerDelegate = self;
    localFileHandler.tableDataDic = self.tableDataDic;
    
    audioArray=  [NSArray arrayWithObjects:@"mp3", nil];
    videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                  @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
    picArray=  [NSArray arrayWithObjects:@"jpg",@"jpeg",@"png", nil];
    pics = [[NSMutableArray alloc] init];
    videos = [[NSMutableArray alloc] init];
    audiosUrl = [[NSMutableArray alloc] init];
    audioPlayerThumbsArray = [[NSMutableArray alloc] init];
    fileHandler = [[FileHandler alloc] init];
    duplicateFileNamesArray =[[NSMutableArray alloc] init];
    [self loadFileData];
    
    self.tabbar.delegate = self;
    self.moreBar.hidden = YES;
    self.moreBar.delegate = self;
    self.misButton.hidden = YES;
    [self setFooterButtonState];
}


-(void) viewDidAppear:(BOOL)animated
{
    [pics removeAllObjects];
    [audiosUrl removeAllObjects];
    [audioPlayerThumbsArray removeAllObjects];
    
    if(![self.opType isEqualToString:@"3"] && ![self.opType isEqualToString:@"4"]){//复制 移动
        [selectedTableDataDic removeAllObjects];
    }
    [self loadFileData];
}

#pragma mark -
#pragma mark footerButtonEventHandleAction 底部按钮点击处理事件
- (IBAction)moreBarMiss:(id)sender {
    
    self.moreBar.hidden = YES;
    self.tabbar.selectedItem = nil;
    [self setFooterButtonState];
    self.misButton.hidden = YES;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    
    if (tabBar == self.tabbar) {
        
        if (currentModel == 0) {
            
            if (item == self.item1) {//下载
                
                [self downloadAction];
                
            }else if (item == self.item2) {//刷新
                
                [self requestSuccessCallback];
                
            }else if (item == self.item3) {//新建文件夹
                
                localFileHandler.opType = 6;
                localFileHandler.cpath = self.cpath;
                localFileHandler.tableDataDic = self.tableDataDic;
                [localFileHandler createFolderAction];
                self.fileListTableView.allowsMultipleSelectionDuringEditing = NO;
                
            }
        }else if (currentModel == 1) {
            
            if (item == self.item1) {//全选
                
                isCheckedAll = !isCheckedAll;
                if (isCheckedAll) {
                    [self selectAllRows];
                    self.item1.selectedImage = [UIImage imageNamed:@"checbox"];
                }else{
                    [self deSelectAllRows];
                    self.tabbar.selectedItem = nil;
                    self.item1.image = [UIImage imageNamed:@"checkbox-down"];
                }
                
            }else if (item == self.item2) {//上传
                
                self.tabbar.selectedItem = nil;
                BOOL isContainFoler = NO;
                NSFileManager* fm = [NSFileManager defaultManager];
                for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                    [fm fileExistsAtPath:fileUrl isDirectory:&isContainFoler];
                    if (isContainFoler) {
                        break;
                    }
                }
                if (isContainFoler) {//如果包含文件夹则上传按钮禁用
                    self.opType = @"8";
                    NSString* userName = [g_sDataManager userName];
                    if (!userName || [userName isEqualToString:@""]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
                        [alert show];
                        return;
                    }
                    if (selectedTableDataDic.count == 0){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择要上传的文件或文件夹！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }else{
                        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
                        fileDialog.isShowFile = YES;
                        fileDialog.isServerFile = YES;
                        fileDialog.isSelectFileMode = NO;
                        fileDialog.cpath = @"/";
                        fileDialog.fileDialogDelegate = self;
                        [self.navigationController pushViewController:fileDialog  animated:YES];
                    }
                }else{
                    [self uploadAction];
                }
                
            }else if (item == self.item3) {//更多
                
                self.misButton.hidden = NO;
                self.moreBar.hidden = NO;
                self.tabbar.selectedItem = nil;
                if (selectedTableDataDic.count == 0) {
                    
                    [self setItemState:1 itemState:NO];
                    [self setItemState:2 itemState:NO];
                    [self setItemState:3 itemState:NO];
                    [self setItemState:4 itemState:NO];
                    
                }else if(selectedTableDataDic.count == 1) {
                    
                    [self setItemState:1 itemState:YES];
                    [self setItemState:2 itemState:YES];
                    [self setItemState:3 itemState:YES];
                    [self setItemState:4 itemState:YES];
                    
                }else if(selectedTableDataDic.count >= 2) {
                    
                    [self setItemState:1 itemState:YES];
                    [self setItemState:2 itemState:YES];
                    [self setItemState:3 itemState:NO];
                    [self setItemState:4 itemState:YES];
                }
                
            }
            
        }
        
    }else if (tabBar == self.moreBar) {
        self.moreBar.selectedItem = nil;
        self.moreBar.hidden = YES;
        self.misButton.hidden = YES;
        if (item == self.moreItem1) {
            
            [self customActionSheet:1];
        }else if (item == self.moreItem2) {
            [self customActionSheet:2];
        }else if (item == self.moreItem3) {
            [self customActionSheet:3];
        }else if (item == self.moreItem4) {
            [self customActionSheet:4];
        }
        
    }
    
}


- (void)setItemState:(NSInteger)itemIndex itemState:(BOOL)enabled
{
    switch (itemIndex) {
        case 1:
        {
            self.moreItem1.enabled = enabled;
            
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"copy"];
                self.moreItem1.image = image;
            }else{
                UIImage *image = [UIImage imageNamed:@"copy-prohibt"];
                self.moreItem1.image = image;
            }
            
        }
            break;
        case 2:
        {
            self.moreItem2.enabled = enabled;
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"move"];
                self.moreItem2.image = image;
            }else{
                UIImage *image = [UIImage imageNamed:@"move-prohibt"];
                
                self.moreItem2.image = image;
            }
            
        }
            break;
        case 3:
        {
            self.moreItem3.enabled = enabled;
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"rechristen"];
                self.moreItem3.image = image;
            }else{
                UIImage *image = [UIImage imageNamed:@"rechristen-prohibt"];
                
                self.moreItem3.image = image;
            }
        }
            break;
        case 4:
        {
            self.moreItem4.enabled = enabled;
            if (enabled) {
                UIImage *image = [UIImage imageNamed:@"delete"];
                self.moreItem4.image = image;
            }else{
                UIImage *image = [UIImage imageNamed:@"delete-prohibt"];
                
                self.moreItem4.image = image;
            }
        }
            break;
        default:
            break;
    }
}

-(void)uploadAction{
    self.opType=@"2";
    NSString* userName = [g_sDataManager userName];
    if (!userName || [userName isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
        [alert show];
        return;
    }
    if (selectedTableDataDic.count>0) {
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = YES;
        fileDialog.isSelectFileMode =NO;
        fileDialog.cpath =@"/";
        fileDialog.fileDialogDelegate = self;
        [self.navigationController pushViewController:fileDialog  animated:YES];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}
-(void)downloadAction{
    localFileHandler.opType=7;
    self.opType=@"7";
    //如果用户未登录提示用户登录
    NSString* userName = [g_sDataManager userName];
    if (!userName || [userName isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"下载文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
        [alert show];
    }else{
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = YES;
        fileDialog.isSelectFileMode = YES;
        fileDialog.fileDialogDelegate = self;
        fileDialog.cpath = @"/";
        [self.navigationController pushViewController: fileDialog animated:YES ];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableDataDic.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileInfo *fileinfo = (FileInfo *)[_tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    FDTableViewCell *cell = (FDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:fileinfo.fileName];
    if (cell == nil) {
        cell = [[FDTableViewCell alloc] initWithFile:fileinfo];
    }
    if ([cell.fileinfo.fileType isEqualToString:@"folder"]) {
        
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat btnW = 10.5;
        CGFloat btnH = 20;
        CGFloat btnX = [UIScreen mainScreen].bounds.size.width - 10 - btnW;
        CGFloat btnY = AU_Cell_Height * 0.5 - btnH * 0.5;
        
        
        accessoryButton.frame = CGRectMake(btnX,btnY,btnW,btnH);
        accessoryButton.contentMode = UIViewContentModeCenter;
        
        [accessoryButton setImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
        [accessoryButton addTarget:self action:@selector(accessoryButtonIsTapped:event:)forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:accessoryButton];
        
        cell.accessoryView = accessoryButton;
    }else{
        
        //从时间信息中截取出年、月、日
        NSString *timeStr = cell.fileinfo.fileChangeTime;
        NSMutableArray *timeArray = [NSMutableArray array];
        timeArray = (NSMutableArray *)[timeStr componentsSeparatedByString:@"-"];
        NSString *yearStr = (NSString *)timeArray[0];
        
        //创建label，设置相关参数，使label作为accessoryView
        UILabel *accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 100, 20)];
        accessoryLabel.adjustsFontSizeToFitWidth = YES;
        accessoryLabel.textAlignment = NSTextAlignmentRight;
        //截取截取出日期里面的year信息
        NSString *yearStr2 = [yearStr substringFromIndex:2];
        
        //截取截取出日期里面的month信息
        NSString *monthStr = (NSString *)timeArray[1];
        
        //截取出日期里面的day信息
        NSString *dayStr = (NSString *)timeArray[2];
        NSMutableArray *dayArray = (NSMutableArray *)[dayStr componentsSeparatedByString:@" "];
        
        
        accessoryLabel.text = [NSString stringWithFormat:@"%@/%@/%@",yearStr2,monthStr,dayArray[0]];
        accessoryLabel.textColor = [UIColor lightGrayColor];
        accessoryLabel.font = [UIFont systemFontOfSize:14];
        cell.accessoryView = accessoryLabel;
        
        BOOL isAudio = [audioArray containsObject:[[cell.fileinfo.fileUrl pathExtension] lowercaseString]];
        BOOL isVideo = [videoArray containsObject:[[cell.fileinfo.fileUrl pathExtension] lowercaseString]];
        BOOL isPic = [picArray containsObject:[[cell.fileinfo.fileUrl pathExtension] lowercaseString]];
        
        if(isAudio){
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAudio:)];
            [cell addGestureRecognizer:tapRecognizer];
            tapRecognizer.delegate = self;
        }else if(isVideo){
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo:)];
            [cell addGestureRecognizer:tapRecognizer];
            tapRecognizer.delegate = self;
        }else if(isPic){
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPic:)];
            [cell addGestureRecognizer:tapRecognizer];
            tapRecognizer.delegate = self;
        }else{
            if(![cell.fileinfo.fileType isEqualToString:@"folder"]){
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOther:)];
                [cell addGestureRecognizer:tapRecognizer];
                tapRecognizer.delegate = self;
            }
        }
    
    }
    cell.fileinfo = fileinfo;
    [cell setDetailText];
    
    return cell;
}
#pragma mark -
#pragma mark UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:self.fileListTableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 右侧箭头点击时的处理事件
- (void)accessoryButtonIsTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.fileListTableView];
    NSIndexPath *indexPath = [self.fileListTableView indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath != nil)
    {
        [self tableView:self.fileListTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
- (BOOL)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.fileListTableView.allowsMultipleSelectionDuringEditing) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileInfo *fileinfo = (FileInfo *)[_tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    //如果是文件夹的时候进入下一层画面
    if(!self.fileListTableView.allowsMultipleSelectionDuringEditing){
        //如果是根目录点击的是相册cell则打开相册view
        if([fileinfo.fileType isEqualToString:@"folder"] && [self.cpath isEqualToString:kDocument_Folder] && (indexPath.row==0) ){
            
            if(self.isOpenFromAppList){
                AlbumCollectionViewController *localFileView = [[AlbumCollectionViewController alloc] initWithNibName:@"AlbumCollectionViewController" bundle:nil];
                localFileView.isOpenFromAppList = YES;
                [self.navigationController pushViewController:localFileView  animated:YES];
            }else{
                AlbumCollectionViewController *localFileView = [[AlbumCollectionViewController alloc] initWithNibName:@"AlbumCollectionViewController" bundle:nil];
                UINavigationController *localFileNav =[[UINavigationController alloc]initWithRootViewController:localFileView];
                [self.navigationController presentViewController:localFileNav animated:NO completion:nil];
            }
            
        }
        else if ([fileinfo.fileType isEqualToString:@"folder"] )
        {
            if(self.isOpenFromAppList){
                LocalFileViewController *localFileView = [[LocalFileViewController alloc] initWithNibName:@"LocalFileViewController" bundle:nil];
                localFileView.isOpenFromAppList =YES;
                localFileView.cpath =[self.cpath stringByAppendingPathComponent: fileinfo.fileName];
                [self.navigationController pushViewController:localFileView  animated:YES];
            }else{
                LocalFileViewController *localFileView = [[LocalFileViewController alloc] initWithNibName:@"LocalFileViewController" bundle:nil];
                localFileView.folderLocationStr = [NSString stringWithFormat:@"%@%@/", self.folderLocationStr, fileinfo.fileName];
                localFileView.cpath = [NSString stringWithFormat:@"%@/%@", self.cpath , fileinfo.fileName];
                localFileView.cfolder = fileinfo.fileName;
                UINavigationController *localFileNav =[[UINavigationController alloc]initWithRootViewController:localFileView];
                [self.navigationController presentViewController:localFileNav animated:NO completion:nil];
            }
        }
    }else{
        if ([fileinfo.fileType isEqualToString:@"folder"] && [self.cpath isEqualToString:kDocument_Folder] && (indexPath.row==0) ) {
            return;
        }
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
        self.curCel =cell;
        if(cell && !([[selectedTableDataDic allKeys] containsObject:cell.fileinfo.fileUrl])){
            [selectedTableDataDic setObject:cell.fileinfo.fileUrl forKey:cell.fileinfo.fileUrl];
            [self setFooterButtonState]; //更新按钮的状态
            if([self.cpath isEqualToString:kDocument_Folder] ){
                if (selectedTableDataDic.count>0 && selectedTableDataDic.count == self.tableDataDic.count-1) {
                    isCheckedAll = YES;
                    UIImage *image = [UIImage imageNamed:@"checbox"];
                    self.item1.image = image;
                }
            }else{
                if (selectedTableDataDic.count>0 && selectedTableDataDic.count == self.tableDataDic.count) {
                    isCheckedAll = YES;
                    UIImage *image = [UIImage imageNamed:@"checbox"];
                    self.item1.image = image;
                }
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSIndexPath * indexP =[NSIndexPath indexPathForRow:0 inSection:0];
    //NSLog(@"----------------");
    //NSLog(@"%zi",indexP == indexPath);
    if ( [self.cpath isEqualToString:kDocument_Folder]) {
//        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
//        if([cell.fileinfo.fileName isEqualToString:@"My Photos"]){
//            return NO;
//        }else{
//            return YES;
//        }
        if(indexPath.row == 0){ //My Photos can not be edit
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
//UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AU_Cell_Height;
}

#pragma mark -
#pragma mark handleTap 点击图片时触发的事件
- (void)showPic:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            BOOL displayActionButton = NO;
            BOOL displaySelectionButtons = NO;
            BOOL displayNavArrows = NO;
            BOOL enableGrid = NO;
            BOOL startOnGrid = NO;
            BOOL autoPlayOnAppear = NO;
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
            NSUInteger picIndex= 0;

            for(int i =0;i<pics.count;i++){
                if([[pics objectAtIndex: i] isEqualToString:self.curCel.fileinfo.fileUrl]){
                    picIndex = i;
                }
            }
            NSUInteger index= picIndex;
            [browser setCurrentPhotoIndex:index];
            [self.navigationController pushViewController:browser animated:YES];
        }
    }
}

#pragma mark -
#pragma mark playVideo 播放视频触发的事件
- (void)playVideo:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
            if (self.kxvc != NULL) {
                [self.kxvc.view removeFromSuperview ];
            }
            self.kxvc = [KxMovieView movieViewControllerWithContentPath:(NSMutableString*)self.curCel.fileinfo.fileUrl parameters:parameters];
            [self addChildViewController:self.kxvc];
            self.kxvc.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height);
            self.kxvc.filePath = (NSMutableString*)self.curCel.fileinfo.fileUrl;

            [self.kxvc fullscreenMode:nil];
            [self.kxvc bottomBarAppears];
            [self.view addSubview:self.kxvc.view];
            
            //根据文件名获取当前视频的索引
            NSUInteger index = 0;
            for(int i =0;i<videos.count;i++){
                if([[videos objectAtIndex: i] isEqualToString:self.curCel.fileinfo.fileUrl]){
                    index = i;
                }
            }
            [self.kxvc setCurrentVideoIndex:index];
            self.navigationController.navigationBarHidden = YES;
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    if(self.navigationController.navigationBarHidden){
        return YES;//隐藏为YES，显示为NO
    }
    else{
        return NO;
    }
}

#pragma mark -
#pragma mark playAudio 播放音频触发的事件
- (void)playAudio:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            AudioViewController *audioPlayerView= [[AudioViewController alloc] initWithNibName:@"AudioViewController" bundle:nil];
            
            audioPlayerView.playerURL = audiosUrl;
            
            NSUInteger  audioIndex =0;
            
            for(int i =0;i<audiosUrl.count;i++){
                if([[audiosUrl objectAtIndex: i] isEqualToString:self.curCel.fileinfo.fileUrl]){
                    audioIndex = i;
                }
            }
            
            audioPlayerView.songIndex =audioIndex;
            audioPlayerView.netOrLocalFlag =@"1";
            
            if(self.isOpenFromAppList){
                audioPlayerView.isOpenFromAppList = YES;
                [self.navigationController pushViewController:audioPlayerView  animated:YES];
            }else{
                UINavigationController *audioPlayerViewNav =[[UINavigationController alloc]initWithRootViewController:audioPlayerView];
                [self.navigationController presentViewController:audioPlayerViewNav animated:NO completion:nil];
            }
        }
    }
    
}

#pragma mark -
#pragma mark showOther 打开其他格式文件触发的事件
- (void)showOther:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            NSFileManager *fileManager =[NSFileManager defaultManager];
            NSString *docPath = self.curCel.fileinfo.fileUrl;
            if(![fileManager fileExistsAtPath:docPath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
                [alert show];
            }else{
                self.documentInteractionController =  [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:docPath]];
                [self.documentInteractionController setDelegate:self];
                if (![self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请安装打开该类文件的应用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
                    [alert show];
                }
            }
        }
    }
}
#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.picUrl = pics;
    
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
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return false;
}


- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//加载本地文件数据
- (void)loadFileData
{
    
    NSString* documentsPath=@"";
    if(self.cpath!=nil && [self.cpath length]>0)
    {
        documentsPath =self.cpath;
        NSLog(@"documentsPath=%@",documentsPath);
    }
    else
    {
        documentsPath=kDocument_Folder;
    }
    self.tableDataDic = [FileTools getAllFiles:documentsPath skipDescendents:YES isShowAlbum:YES]; //根据路径获取该路径下的文件和目录
    self.cpath = documentsPath;
    
    
    NSEnumerator *enumerator = [self.tableDataDic keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        FileInfo *fileinfo = (FileInfo*)[self.tableDataDic objectForKey:key];
        if([videoArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
            [videos addObject:fileinfo.fileUrl];
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            app.videoUrl = videos;
            NSLog(@"videos%@",videos);
        }else if([picArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
            [pics addObject:fileinfo.fileUrl];
        }else if([audioArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
            [audiosUrl addObject:fileinfo.fileUrl];
            NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:fileinfo.fileUrl]];
            UIImage *image = [audioDataDic objectForKey:@"Artwork"];
            if (image) {
                [audioPlayerThumbsArray addObject:image];
            }else{
                [audioPlayerThumbsArray addObject:[UIImage imageNamed:@"audio_default"]];
            }
        }
    }
    self.tabbar.selectedItem = nil;
//    [self setFooterButtonState];
    [_fileListTableView reloadData];
}

- (void)returnBeforeWindowAction:(id)sender {
    if (self.isOpenFromAppList){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
    if(cell && [[selectedTableDataDic allKeys] containsObject:cell.fileinfo.fileUrl]){
        [selectedTableDataDic removeObjectForKey:cell.fileinfo.fileUrl];
        [self setFooterButtonState]; //更新按钮的状态
        isCheckedAll = NO;
        UIImage *image = [UIImage imageNamed:@"checkbox-down"];
        self.item1.image = image;
        self.item1.enabled = YES;
    }
}

#pragma mark -
#pragma mark setFooterButtonState 设置底部按钮的状态
- (void)setFooterButtonState {
    if(selectedTableDataDic.count>0){
        BOOL isContainFoler = NO;
        NSFileManager* fm = [NSFileManager defaultManager];
        for (NSString *fileUrl in [selectedTableDataDic allKeys]){
            [fm fileExistsAtPath:fileUrl isDirectory:&isContainFoler];
            if (isContainFoler) {
                break;
            }
        }
        
        UIImage *image3 = [UIImage imageNamed:@"upload"];
        self.item2.image = image3;
        self.item2.enabled = YES;

    }else{
        UIImage *image3 = [UIImage imageNamed:@"upload-prohibt"];
        
        self.item1.enabled = YES;
//        self.item2.image = image3;
//        self.item2.enabled = NO;
        
    }
}

#pragma mark -
#pragma mark switchTableViewModel 设置TableView的状态（可选、不可选）
- (void)switchTableViewModel:(UIBarButtonItem *)sender {
    self.fileListTableView.allowsMultipleSelectionDuringEditing=!self.fileListTableView.allowsMultipleSelectionDuringEditing;
    if (self.fileListTableView.allowsMultipleSelectionDuringEditing) {
        self.fileListTableView.allowsMultipleSelectionDuringEditing=YES;
        currentModel = 1;
        [self.fileListTableView setEditing:YES animated:YES];
        [rightBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1] forState:UIControlStateNormal];
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        UIImage *image1 = [UIImage imageNamed:@"checkbox-down"];
        UIImage *image2 = [UIImage imageNamed:@"upload-prohibt"];
        UIImage *image3 = [UIImage imageNamed:@"more"];
        
        self.tabbar.selectedItem = nil;
        self.item1.image = image1;
        self.item1.title = @"全选";
        self.item2.image = image2;
        self.item2.title = @"上传";
//        self.item2.enabled = NO;
        self.item3.image = image3;
        self.item3.title = @"更多";
        
    }else{
        currentModel =0;
        self.fileListTableView.allowsMultipleSelectionDuringEditing=NO;
        [self.fileListTableView setEditing:NO animated:YES];
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        [rightBtn.layer setCornerRadius:0];
        [selectedTableDataDic removeAllObjects];
        self.moreBar.hidden = YES;
        self.misButton.hidden = YES;
        self.tabbar.selectedItem = nil;
        UIImage *image1 = [UIImage imageNamed:@"download"];
        UIImage *image2 = [UIImage imageNamed:@"refurbish"];
        UIImage *image3 = [UIImage imageNamed:@"new-folder"];
        
        self.item1.image = image1;
        self.item1.title = @"下载";
        self.item1.enabled = YES;
        self.item2.image = image2;
        self.item2.title = @"刷新";
        self.item2.enabled = YES;
        self.item3.image = image3;
        self.item3.title = @"新建目录";
        
    }
}


#pragma mark -
#pragma mark selectAllRows 设置TableView的全选
- (void) selectAllRows{
    for (int row=0; row<self.tableDataDic.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.fileListTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    for (NSString *keys in [self.tableDataDic allKeys]){
        FileInfo *fileinfo = (FileInfo *)[self.tableDataDic valueForKey:keys];
        if(!([self.cpath isEqualToString:kDocument_Folder] && [fileinfo.fileName isEqualToString:@"My Photos"])){
            if(  !([[selectedTableDataDic allKeys] containsObject:fileinfo.fileUrl])){
                [selectedTableDataDic setObject:fileinfo forKey:fileinfo.fileUrl];
            }
        }
    }
   [self setFooterButtonState];
    
}
#pragma mark -
#pragma mark deSelectAllRows 取消TableView的全选
- (void) deSelectAllRows{
    for (int row=0; row<self.tableDataDic.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.fileListTableView deselectRowAtIndexPath:indexPath animated:NO ];
        [selectedTableDataDic removeAllObjects];
    }
    [self setFooterButtonState];
}

#pragma mark -
#pragma mark chooseFileDirAction的委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
    bool isLegal = YES;
    for (NSString *fileUrl in [selectedTableDataDic allKeys]){//移动、复制对象所在的目录和要移动复制的目标目录所在的子目录
        if([fileDialog.cpath rangeOfString:fileUrl].location !=NSNotFound)
        {
            NSString *subPath = [fileDialog.cpath componentsSeparatedByString:fileUrl][1];
            NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
            NSString *firstSubPathComponent = subPathComponentArray[0];
            if([firstSubPathComponent isEqualToString:@""] ){
                isLegal = NO;
                break;
            }
        }
        if ([fileDialog.cpath isEqualToString:self.cpath]) {//移动、复制对象所在的目录和要移动复制的目标目录所在的目录相同
            isLegal = NO;
            break;
        }
    }
    
    if(selectedTableDataDic.count>0){
        switch ([self.opType intValue]) {
            case 2:{//上传
                NSString* cpath = fileDialog.cpath;
                NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"/%@",[g_sDataManager userName]];
                if (![cpath isEqualToString:@"/"]) {
                    [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",cpath]];
                }
                //服务器端重名文件判断
                //1.先判断队列中是否已有该文件
                for(FileUploadByBlockOperation *operation in [NSOperationUploadQueue sharedInstance].operations) {
                    NSString *fileName = operation.taskInfo.fileName;
                    NSString *fileNamePath = [self.cpath stringByAppendingPathExtension:fileName];

                    if ([selectedTableDataDic objectForKey:fileNamePath] && [uploadUrl isEqualToString:operation.taskInfo.serverPath]) { //如果当前上传队列中包含该文件，且该文件的目标路径和当前操作要上传到的目标路径相同
                        [selectedTableDataDic removeObjectForKey:fileNamePath];
                    }
                }
                //2.再判断未完成已取消任务中是否有该文件
                for(NSString *taskId in [[ProgressBarViewController sharedInstance].uploadTaskDic allKeys] ){
                    TaskInfo *taskInfo = [[ProgressBarViewController sharedInstance].downloadTaskDic objectForKey:taskId];
                    for (NSString *fileNamePath in [selectedTableDataDic allKeys]) {
                        if (([taskInfo.taskName isEqualToString:[fileNamePath lastPathComponent]] && [uploadUrl isEqualToString:taskInfo.serverPath]) && ([taskInfo.taskStatus isEqualToString:CANCLED]|| [taskInfo.taskStatus isEqualToString:FAILURE])) {
                            [selectedTableDataDic removeObjectForKey:fileNamePath];
                        }
                    }
                }
                [duplicateFileNamesArray removeAllObjects];
                //3.判断是否服务器端目标路径下已经包含一个同名的文件
                for (NSString *fileNamePath in [selectedTableDataDic allKeys]) {
                    NSString *fileName = [fileNamePath lastPathComponent];
                    if ([fileDialog.filesDic objectForKey:fileName]) {
                        [duplicateFileNamesArray addObject:fileName ];
                    }
                }
                if(duplicateFileNamesArray.count>0){//如果目标路径下包含重名的文件，提示用户是否需要覆盖
                    [self launchDialog:duplicateFileNamesArray];
                    
                }else{

                    NSString* localFilePath = self.cpath;
                    for (NSString *filePath in [selectedTableDataDic allKeys]){
                        NSString *fileName = [filePath lastPathComponent];
                        [fileHandler uploadFileWithHttp:[NSOperationUploadQueue sharedInstance] fileName:fileName localFilePath:localFilePath serverCpath:cpath];
                    }
                    
                    [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                    [selectedTableDataDic removeAllObjects];
                }
                break;
            }
                
            case 3:{//复制
                if(!isLegal){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"操作非法:不能操作至对象子目录或当前目录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
                
                //判断目标路径下是否包含同名的文件
                [duplicateFileNamesArray removeAllObjects];
                for (NSString *fileNamePath in [selectedTableDataDic allKeys]) {
                    NSString *fileName = [fileNamePath lastPathComponent];
                    NSMutableDictionary *desFilesDic=[FileTools getAllFiles:fileDialog.cpath skipDescendents:YES isShowAlbum:NO];
                    
                    for (NSString *keys in [desFilesDic allKeys]){
                        FileInfo *fileinfo = (FileInfo *)[desFilesDic valueForKey:keys];
                            if( [fileinfo.fileName isEqualToString:fileName] ){
                                [duplicateFileNamesArray addObject:fileName ];
                            }
                    }
                }
                if(duplicateFileNamesArray.count>0){//如果目标路径下包含重名的文件，提示用户是否需要覆盖
                    [self launchDialog:duplicateFileNamesArray];
                }else{
                    for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                        NSString* cpath = fileDialog.cpath;
                        cpath=[cpath stringByAppendingString :@"/"];
                        cpath=[cpath stringByAppendingString :[fileUrl lastPathComponent]];
                        //[FileTools copyFileByUrl:fileUrl   toPath:cpath];
                        BOOL  opreationIsExist= false;
                        opreationIsExist= false;
                        for (FileCopyTools *operation in [copyAndMoveQueue operations]) {
                            if ([operation.fileUrl isEqualToString:fileUrl]) {
                                opreationIsExist = true;
                            }
                        }
                        if (!opreationIsExist) {
                            FileCopyTools *opreation = [[FileCopyTools alloc] initWithFileInfo];
                            opreation.fileUrl = fileUrl;
                            opreation.destinationUrl = cpath;
                            opreation.opType = @"copy";
                            [copyAndMoveQueue addOperation:opreation];
                        }
                    }
                    [self loadFileData];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已复制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    [self requestSuccessCallback];
                }
                
                break;
            }
            case 4:{//移动
                if(!isLegal){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"操作非法:不能操作至对象子目录或当前目录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
                
                //判断目标路径下是否包含同名的文件
                [duplicateFileNamesArray removeAllObjects];
                for (NSString *fileNamePath in [selectedTableDataDic allKeys]) {
                    NSString *fileName = [fileNamePath lastPathComponent];
                    NSMutableDictionary *desFilesDic=[FileTools getAllFiles:fileDialog.cpath skipDescendents:YES isShowAlbum:NO];
                    
                    for (NSString *keys in [desFilesDic allKeys]){
                        FileInfo *fileinfo = (FileInfo *)[desFilesDic valueForKey:keys];
                        if( [fileinfo.fileName isEqualToString:fileName] ){
                            [duplicateFileNamesArray addObject:fileName ];
                        }
                    }
                }
                if(duplicateFileNamesArray.count>0){//如果目标路径下包含重名的文件，提示用户是否需要覆盖
                    [self launchDialog:duplicateFileNamesArray];
                }else{
                    for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                        NSString* cpath = fileDialog.cpath;
                        cpath=[cpath stringByAppendingString :@"/"];
                        cpath=[cpath stringByAppendingString :[fileUrl lastPathComponent]];

                        [FileTools moveFileByUrl:fileUrl toPath:cpath];
                    }
                    [self loadFileData];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已移动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    [self requestSuccessCallback];
                }
                break;
            }
            case 8:{//备份
                BOOL isFolder = NO;
                sourceDirsArray = [[NSMutableArray alloc]init];
                sourceFilesArray = [[NSMutableArray alloc]init];
                NSFileManager* fm = [NSFileManager defaultManager];
                for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                    [fm fileExistsAtPath:fileUrl isDirectory:&isFolder];
                    if (isFolder) {
                        [sourceDirsArray addObject:fileUrl];
                    }else{
                        [sourceFilesArray addObject:fileUrl];
                    }
                }
                
                NSString* cpath = fileDialog.cpath;
                NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"/%@",[g_sDataManager userName]];
                if (![cpath isEqualToString:@"/"]) {
                    [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",cpath]];
                }
                //服务器端重名文件判断
                //1.先判断队列中是否已有该文件
                for(FileUploadByBlockOperation *operation in [NSOperationUploadQueue sharedInstance].operations) {
                    NSString *fileName = operation.taskInfo.fileName;
                    NSString *fileNamePath = [self.cpath stringByAppendingPathExtension:fileName];
                    
                    if ([selectedTableDataDic objectForKey:fileNamePath] && [uploadUrl isEqualToString:operation.taskInfo.serverPath]) { //如果当前上传队列中包含该文件，且该文件的目标路径和当前操作要上传到的目标路径相同
                        [selectedTableDataDic removeObjectForKey:fileNamePath];
                    }
                }
                //2.再判断未完成已取消任务中是否有该文件
                for(NSString *taskId in [[ProgressBarViewController sharedInstance].uploadTaskDic allKeys] ){
                    TaskInfo *taskInfo = [[ProgressBarViewController sharedInstance].uploadTaskDic objectForKey:taskId];
                    for (NSString *fileNamePath in [selectedTableDataDic allKeys]) {
                        if ([taskInfo.taskType isEqualToString:@"上传"]) {
                            if (([taskInfo.taskName isEqualToString:[fileNamePath lastPathComponent]] && [uploadUrl isEqualToString:taskInfo.serverPath]) && ([taskInfo.taskStatus isEqualToString:CANCLED]|| [taskInfo.taskStatus isEqualToString:FAILURE])) {
                                [selectedTableDataDic removeObjectForKey:fileNamePath];
                            }
                        }
                        else if([taskInfo.taskType isEqualToString:@"备份"]){
                            for (int i=0; i<[taskInfo.filesArray count]; i++) {
                                if (([[taskInfo.filesArray[i] lastPathComponent] isEqualToString:[fileNamePath lastPathComponent]] && [uploadUrl isEqualToString:taskInfo.serverPath]) && ([taskInfo.taskStatus isEqualToString:CANCLED]|| [taskInfo.taskStatus isEqualToString:FAILURE])) {
                                    [selectedTableDataDic removeObjectForKey:fileNamePath];
                                }
                            }
                        }
                        
                    }
                }
                [duplicateFileNamesArray removeAllObjects];
                //3.判断是否服务器端目标路径下已经包含一个同名的文件
                for (NSString *fileNamePath in [selectedTableDataDic allKeys]) {
                    NSString *fileName = [fileNamePath lastPathComponent];
                    if ([fileDialog.filesDic objectForKey:fileName]) {
                        [duplicateFileNamesArray addObject:fileName ];
                    }
                    if([fileDialog.dirsDic objectForKey:fileName]) {
                        [duplicateFileNamesArray addObject:fileName ];
                    }
                }
                
                
                if(duplicateFileNamesArray.count>0){//如果目标路径下包含重名的文件，提示用户是否需要覆盖
                    [self launchDialog:duplicateFileNamesArray];
                    
                }else{
                    BackupHandler *backupHandler = [[BackupHandler alloc]init:sourceFilesArray sourceDirsArray:sourceDirsArray localCurrentDir:self.cpath targetDir:fileDialog.cpath userName:[g_sDataManager userName] password:[g_sDataManager password]];
                    [backupHandler backupHandle];
                    [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                    break;
                }
            }
            default:
                break;
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
   // [self requestSuccessCallback];
}


#pragma mark -
#pragma mark chooseFileAction FileDialogViewController委托方法
- (void)chooseFileAction:(UIButton *)sender{
    NSString *fileName = fileDialog.selectedFile;
    NSString *targetPath =self.cpath;
    selectedItemsDic = [[NSMutableDictionary alloc] init];
    [selectedItemsDic setObject:fileName forKey:fileName];
    //1.先判断队列中是否已有该文件
    for(FileDownloadOperation *operation in [NSOperationDownloadQueue sharedInstance].operations) {
        NSString *fileName = operation.taskInfo.fileName;
        NSString *fileNamePath = [targetPath stringByAppendingPathComponent:fileName];
        if ([selectedItemsDic objectForKey:fileName] && [fileNamePath isEqualToString:operation.taskInfo.cachePath]) { //如果当前下载队列中包含该文件，且该文件的目标路径和当前操作要下载到的目标路径相同
            [selectedItemsDic removeObjectForKey:fileName];
        }
    }
    //2.再判断未完成已取消任务中是否有该文件
    for(NSString *taskId in [[ProgressBarViewController sharedInstance].taskDic allKeys] ){
        TaskInfo *taskInfo = [[ProgressBarViewController sharedInstance].downloadTaskDic objectForKey:taskId];
        for (NSString *fileName in [selectedItemsDic allKeys]) {
            if (([taskInfo.taskName isEqualToString:fileName] && [taskInfo.cachePath isEqualToString:[targetPath stringByAppendingPathComponent:fileName]]) && ([taskInfo.taskStatus isEqualToString:CANCLED]|| [taskInfo.taskStatus isEqualToString:FAILURE])) {
                [selectedItemsDic removeObjectForKey:fileName];
            }
        }
    }
    //3.判断是否目标路径下已经包含一个同名的文件
    duplicateFileNamesArray =[FileTools getDuplicateFileNames: targetPath fileNames:[selectedItemsDic allKeys]];
    if(duplicateFileNamesArray.count>0){//如果目标路径下包含重名的文件，提示用户是否需要覆盖
        [self launchDialog:duplicateFileNamesArray];
    }else{
        [fileHandler downloadFiles:[NSOperationDownloadQueue sharedInstance] selectedItemsDic:selectedItemsDic cpath:fileDialog.cpath cachePath:targetPath];
        [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
        [selectedItemsDic removeAllObjects];
    }
    
    
}

#pragma mark -
#pragma mark loginCallbackAction LoginViewController委托方法
- (void)loginCallbackAction:(UIButton *)sender{
    [self uploadAction];
}

-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==0){ //下载时用户未登录
        [UIHelper showLoginViewWithDelegate:self loginViewDelegate:nil];
    }
}

#pragma mark -
#pragma mark CustomActionSheet 的代理方法
-(void)cancleAction{
    [sheet dismissSheet:self];
}

#pragma mark -
#pragma mark customActionSheet 的代理方法
-(void) customActionSheet:(NSInteger)buttonIndex{
    if(buttonIndex==1){ //复制
        self.opType=@"3";
        [sheet dismissSheet:self];
        if (selectedTableDataDic.count>0) {
            fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
            fileDialog.isShowFile =YES;
            fileDialog.isServerFile = NO;
            fileDialog.cpath =kDocument_Folder;
            fileDialog.rootUrl = kDocument_Folder;
            fileDialog.isSelectFileMode =NO;
            fileDialog.fileDialogDelegate = self;
            [self.navigationController pushViewController: fileDialog animated:YES ];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }else if(buttonIndex==2){//移动
        
        [sheet dismissSheet:self];
        self.opType=@"4";
        if (selectedTableDataDic.count>0) {
            fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
            fileDialog.isShowFile =YES;
            fileDialog.isServerFile = NO;
            fileDialog.cpath =kDocument_Folder;
            fileDialog.rootUrl = kDocument_Folder;
            fileDialog.isSelectFileMode =NO;
            fileDialog.fileDialogDelegate = self;
            [self.navigationController pushViewController: fileDialog animated:YES ];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
        
    }else if(buttonIndex==3){//重命名
        
        localFileHandler.cpath = self.cpath;
        localFileHandler.opType=5;
        localFileHandler.queue =copyAndMoveQueue;
        localFileHandler.tableDataDic = self.tableDataDic;
        localFileHandler.selectedFileName =self.curCel.fileinfo.fileName;
        [localFileHandler renameFile:(FileInfo *)self.curCel.fileinfo ];
        
    }else if(buttonIndex==4){//删除
        localFileHandler.opType=1;
        self.curCel.fileinfo.isSelect=YES;
        [self.fileListTableView setEditing:YES animated:YES];
        self.fileListTableView.allowsMultipleSelectionDuringEditing=YES;
        [localFileHandler deleteFiles:selectedTableDataDic];
        
        [selectedTableDataDic removeAllObjects];
        [self setFooterButtonState];
        
    }
}

#pragma mark -
#pragma mark FileHandler 的代理方法 刷新
- (void)requestSuccessCallback{
    [self loadFileData];
    [self.fileListTableView reloadData];
    if (self.moreBar.hidden == NO) {
        self.moreBar.hidden = YES;
    }
  
    [selectedTableDataDic removeAllObjects];
    if (sheet) {
        [sheet dismissSheet:self];
    }
//    [self setFooterButtonState];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.folderLocationStr = 0;
        self.cpath = 0;
        self.cfolder = 0;
        self.opType =@"-1";
    }
    return self;
}

//自定义alertView相关的代码
- (void)launchDialog:(NSArray*)fileNamesArray
{
    // Here we need to pass a full frame
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    // Add some custom content to the alert view
    [alertView setContainerView:[self createAlertView:fileNamesArray]];
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", @"取消", nil]];
    [alertView setDelegate:self];
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    // And launch the dialog
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if(buttonIndex==0){//按下确定按钮
        if ([self.opType isEqualToString:@"7"]) {
            NSString *targetPath = [kDocument_Folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[g_sDataManager userName]]];
            if (tableViewDelegate.selectedFileNamesDic.count>0) {
                for (int i=0; i<duplicateFileNamesArray.count; i++) {
                    if ([tableViewDelegate.selectedFileNamesDic objectForKey:duplicateFileNamesArray[i]]==nil) {
                        [selectedItemsDic removeObjectForKey:duplicateFileNamesArray[i]];
                    }
                }
                [fileHandler downloadFiles:[NSOperationDownloadQueue sharedInstance] selectedItemsDic:selectedItemsDic cpath:self.cpath cachePath:targetPath];
                [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                [selectedItemsDic removeAllObjects];
            }
        }
        else if([self.opType isEqualToString:@"2"]){
            for (int i=0; i<duplicateFileNamesArray.count; i++) {
                if ([tableViewDelegate.selectedFileNamesDic objectForKey:duplicateFileNamesArray[i]]==nil) {
                    NSString *fileNamePath = [self.cpath stringByAppendingPathComponent:duplicateFileNamesArray[i]];
                    [selectedTableDataDic removeObjectForKey:fileNamePath];
                }
            }
            NSString* localFilePath = self.cpath;
            NSString* cpath = fileDialog.cpath;
            for (NSString *filePath in [selectedTableDataDic allKeys]){
                NSString *fileName = [filePath lastPathComponent];
                [fileHandler uploadFileWithHttp:[NSOperationUploadQueue sharedInstance] fileName:fileName localFilePath:localFilePath serverCpath:cpath];
            }
            [selectedTableDataDic removeAllObjects];
            [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
        }else if([self.opType isEqualToString:@"3"]){//复制
            for (int i=0; i<duplicateFileNamesArray.count; i++) {
                if ([tableViewDelegate.selectedFileNamesDic objectForKey:duplicateFileNamesArray[i]]==nil) {
                    NSString *fileNamePath = [self.cpath stringByAppendingPathComponent:duplicateFileNamesArray[i]];
                    [selectedTableDataDic removeObjectForKey:fileNamePath];
                }
            }
            for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                NSString* destinationUrl = fileDialog.cpath;
                destinationUrl=[destinationUrl stringByAppendingString :@"/"];
                destinationUrl=[destinationUrl stringByAppendingString :[fileUrl lastPathComponent]];
                //[FileTools copyFileByUrl:fileUrl   toPath:cpath];
                BOOL  opreationIsExist= false;
                opreationIsExist= false;
                for (FileCopyTools *operation in [copyAndMoveQueue operations]) {
                    if ([operation.fileUrl isEqualToString:fileUrl]) {
                        opreationIsExist = true;
                    }
                }
                if (!opreationIsExist) {
                    FileCopyTools *opreation = [[FileCopyTools alloc] initWithFileInfo];
                    opreation.fileUrl = fileUrl;
                    opreation.destinationUrl = destinationUrl;
                    opreation.opType = @"copy";
//                    NSFileManager *fileMgr = [NSFileManager defaultManager];
//                    BOOL bRet = [fileMgr fileExistsAtPath:destinationUrl];
//                    if(bRet){
//                        [FileTools deleteFileByUrl:destinationUrl];
//                    }
                    [copyAndMoveQueue addOperation:opreation];
                }
            }
            [self loadFileData];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已复制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }else if([self.opType isEqualToString:@"4"]){
            for (int i=0; i<duplicateFileNamesArray.count; i++) {
                if ([tableViewDelegate.selectedFileNamesDic objectForKey:duplicateFileNamesArray[i]]==nil) {
                    NSString *fileNamePath = [self.cpath stringByAppendingPathComponent:duplicateFileNamesArray[i]];
                    [selectedTableDataDic removeObjectForKey:fileNamePath];
                }
            }
            for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                NSString* destinationUrl = fileDialog.cpath;
                destinationUrl=[destinationUrl stringByAppendingString :@"/"];
                destinationUrl=[destinationUrl stringByAppendingString :[fileUrl lastPathComponent]];
//                NSFileManager *fileMgr = [NSFileManager defaultManager];
//                BOOL bRet = [fileMgr fileExistsAtPath:destinationUrl];
//                if(bRet){
//                    [FileTools deleteFileByUrl:destinationUrl];
//                }

                [FileTools moveFileByUrl:fileUrl toPath:destinationUrl];
            }
            [self loadFileData];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已移动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [self requestSuccessCallback];
        }else if([self.opType isEqualToString:@"8"]){
            for (int i=0; i<duplicateFileNamesArray.count; i++) {
                if ([tableViewDelegate.selectedFileNamesDic objectForKey:duplicateFileNamesArray[i]]==nil) {
                    NSString *fileNamePath = [self.cpath stringByAppendingPathComponent:duplicateFileNamesArray[i]];
                    for (int j=0; j<[sourceDirsArray count]; j++) {
                        NSString *fileName = [sourceDirsArray[j] lastPathComponent];
                        if ([fileName isEqualToString:duplicateFileNamesArray[i]]) {
                            [sourceDirsArray removeObjectAtIndex:j];
                        }
                    }
                    for (int j=0; j<[sourceFilesArray count]; j++) {
                        NSString *fileName = [sourceFilesArray[j] lastPathComponent];
                        if ([fileName isEqualToString:duplicateFileNamesArray[i]]) {
                            [sourceFilesArray removeObjectAtIndex:j];
                        }
                    }
                }
            }
            
            BackupHandler *backupHandler = [[BackupHandler alloc]init:sourceFilesArray sourceDirsArray:sourceDirsArray localCurrentDir:self.cpath targetDir:fileDialog.cpath userName:[g_sDataManager userName] password:[g_sDataManager password]];
            [backupHandler backupHandle];
            [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
            
            [selectedTableDataDic removeAllObjects];
        }
    }
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    
}

- (UIView *)createAlertView:(NSArray*)fileNamesArray
{
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 270)];
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 270, 60)];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"目标路径下存在以下%d个同名的文件，确定覆盖吗",fileNamesArray.count];
    [alertView addSubview:label];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 290, 200)];
    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    tableViewDelegate = [[TableViewDelegate alloc]init];
    tableViewDelegate.fileNamesArray = fileNamesArray;
    tableView.delegate = tableViewDelegate;
    tableView.dataSource = tableViewDelegate;
    tableView.allowsMultipleSelectionDuringEditing = YES;
    [tableView setEditing:YES animated:YES];
    [alertView addSubview:tableView];
    
    return alertView;
}

@end
