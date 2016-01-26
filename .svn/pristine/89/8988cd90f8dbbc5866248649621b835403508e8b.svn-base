//
//  VideoCollctionViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/24.
//  Copyright (c) 2015年 riqiao. All rights reserved.c c
//
#import <AVFoundation/AVFoundation.h>
#import "AlbumVideoTableViewController.h"
#import "FileInfo.h"
#import "FileTools.h"
#import "FDTableViewCell.h"
#import "PlayViewController.h"
#import "UIHelper.h"
#import "PhotoTools.h"


#import "NSUUIDTool.h"
#import "UploadFileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"

#define AU_Cell_Height 52

static NSString* cellIdentifier = @"cellId";
@interface AlbumVideoTableViewController ()
{
    NSMutableArray *videosArray;
    NSMutableArray* albums; //保存所有相册的NSMutableArray对象
    //NSMutableArray* albumNames; //保存所有相册名称的NSMutableArray
    NSDictionary* thumbnails; //保存所有相册图片的缩略图NSDictionary对象

    UIButton* rightBtn;
    UIBarButtonItem *leftBtn;
    
    ALAsset* asset;
    ALAssetRepresentation *rap;
    CGImageRef ref;
    UIImage * image;
    NSMutableArray* pics;
    NSUInteger sectionNo;//当前显示的是第section
    PhotoTools* photoTools;
    
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名
    FileDialogViewController *fileDialog;
    
    NSString *opType; //1移动 2上传
}
@end

@implementation AlbumVideoTableViewController 
- (void)viewDidLoad {
    [super viewDidLoad];
    photoTools = [[PhotoTools alloc]init];
    videosArray = [[NSMutableArray alloc]init];
    albums =[[NSMutableArray alloc]init];
    //albumNames=[[NSMutableArray alloc]init];
    thumbnails=[[NSDictionary alloc]init];
    [photoTools getALLAlbumAndVideosByAlbums];
    albums = photoTools.getAlbumsArray;
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    leftBtn=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=leftBtn;
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 32, 32);
    [rightBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(switchTableViewModel:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    
    [self.videoTableView registerClass:[FDTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    //去掉tableView分割线左边短15像素
    if ([self.videoTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.videoTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.videoTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.videoTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.videoTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    //[self loadFileData];
    CGSize screenSize = [UIHelper getScreenSize];
    float width =screenSize.width;
    //底部按钮的添加
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [uploadBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn addTarget: self action: @selector(uploadFilesAction) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *uploadBtnItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    delBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
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
    [self.videoTableView reloadData];
    
    selectedItemsDic   = [[NSMutableDictionary alloc] init];
}

- (void)uploadFilesAction{
    opType =@"2";
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
            [self.navigationController pushViewController:fileDialog animated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择视频" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
}


- (void)moveFilesAction{    
    opType =@"1";
    
    if (!self.videoTableView.allowsMultipleSelectionDuringEditing){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择视频" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
    fileDialog.isShowFile =YES;
    fileDialog.isServerFile = NO;
    fileDialog.cpath =kDocument_Folder;
    fileDialog.rootUrl =kDocument_Folder;
    fileDialog.isSelectFileMode =NO;
    fileDialog.fileDialogDelegate = self;
    [self.navigationController pushViewController:fileDialog animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedVideosNotif:) name:@"VideosFinishedNotify" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"VideosFinishedNotify" object:nil];//移除观察者
}


//UITableViewDataSource协议中的方法
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FDTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];       FileInfo *fileinfo = [[FileInfo alloc] init];
    NSInteger rowNo = indexPath.row;
    ALAsset* thumbPhoto = [videosArray objectAtIndex:rowNo];
    CGImageRef  thumbRef = [thumbPhoto thumbnail];
    UIImageView *thumbImage = [[UIImageView alloc] initWithImage:[[UIImage alloc]initWithCGImage:thumbRef]];
    
    ALAsset *cellAsset = [videosArray objectAtIndex:indexPath.row];
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
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"done"]];
    bgView.contentMode = UIViewContentModeBottomRight;
    cell.selected = false;
    

    if(cell == nil)
    {
        cell = [[FDTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
    }
    //去掉tableView分割线左边短15像素
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    cell.imageView.image = thumbImage.image;
    cell.imageView.frame = CGRectMake(5,10,60,60);
    CGSize itemSize = CGSizeMake(60, 50);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(2.0, 2.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];

    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageView.frame = CGRectMake(0, 0, 29, 29);
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accessoryButton.frame = CGRectMake(100,5,50,50);
    [accessoryButton setImage:[UIImage imageNamed:@"playBtn.jpg"] forState:UIControlStateNormal];
    [accessoryButton addTarget:self action:@selector(accessoryButtonIsTapped:event:)forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryButton;
    //设置视频文件名为创建日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.textLabel.text = [dateFormatter stringFromDate:[ thumbPhoto valueForProperty:ALAssetPropertyDate ]];
    
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
}



//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}
//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return pics.count;
    return videosArray.count;
}
//UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AU_Cell_Height;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.videoTableView.allowsMultipleSelectionDuringEditing ==YES){
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.videoTableView cellForRowAtIndexPath:indexPath];
        
        ALAsset *cellAsset = [videosArray objectAtIndex:indexPath.row];
        if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl])){
            [selectedItemsDic setObject:cellAsset forKey:cell.fileinfo.fileUrl];
        }
    }
    NSLog(@"%zi",selectedItemsDic.count);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.videoTableView cellForRowAtIndexPath:indexPath];
    if(cell && [[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl]){
        [selectedItemsDic removeObjectForKey:cell.fileinfo.fileUrl];
    }
    NSLog(@"%zi",selectedItemsDic.count);
}

- (void)accessoryButtonIsTapped:(id)sender event:(id)event{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.videoTableView];
    NSIndexPath *indexPath = [self.videoTableView indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath != nil)
    {
        [self tableView:self.videoTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        FDTableViewCell* cell =(FDTableViewCell*)[self tableView:self.videoTableView  cellForRowAtIndexPath:indexPath];
        
         ALAsset *cellAsset = [videosArray objectAtIndex:indexPath.row];
         [FileTools saveFileFromAsset:cellAsset toPath:cell.fileinfo.fileUrl];
  
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已移动" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
        
        NSString * filePath = cell.fileinfo.fileUrl;
        PlayViewController *playerView= [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
        playerView.filePath =(NSMutableString*)filePath;
        [self presentViewController:playerView animated:YES completion:nil];
    }
}


#pragma mark -
#pragma mark switchTableViewModel 设置TableView的状态（可选、不可选）
- (void)switchTableViewModel:(UIBarButtonItem *)sender {
    self.videoTableView.allowsMultipleSelectionDuringEditing=!self.videoTableView.allowsMultipleSelectionDuringEditing;
    if (self.videoTableView.allowsMultipleSelectionDuringEditing) {
        self.videoTableView.allowsMultipleSelectionDuringEditing=YES;
        [self.videoTableView setEditing:YES animated:YES];
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"全选"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllRows:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }else{
        self.videoTableView.allowsMultipleSelectionDuringEditing=NO;
        [self.videoTableView setEditing:NO animated:YES];
        [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(returnAction:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
        [selectedItemsDic removeAllObjects];
    }
    
}

#pragma mark -
#pragma mark selectAllRows 设置TableView的全选
- (void) selectAllRows:(id)sender{
    for (int row=0; row<videosArray.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.videoTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.videoTableView cellForRowAtIndexPath:indexPath];
        
        ALAsset *cellAsset = [videosArray objectAtIndex:indexPath.row];
        if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl])){
            [selectedItemsDic setObject:cellAsset forKey:cell.fileinfo.fileUrl];
        }
    }
}

- (void)returnAction:(UIBarButtonItem *)sender {
   // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)receivedVideosNotif:(NSNotification *)notification {
    videosArray = [photoTools getVideosArray];
    [self.videoTableView reloadData];
    
}

#pragma mark -
#pragma mark chooseFileDirAction的委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
    switch ([opType intValue]) {
        case 1:{//move
            if (selectedItemsDic.count>0) {
                for (NSString *filePath in [selectedItemsDic allKeys]){
                    //[FileTools saveFileFromAsset:cellAsset toPath:filePath ];
                    int result = [FileTools saveFileFromAsset:[selectedItemsDic valueForKey:filePath] toPath:filePath];
//                    if (result==0) {
//                        [selectedItemsDic removeObjectForKey:filePath];
//                    }
                    
                    NSString* cpath = fileDialog.cpath;
                    cpath=[cpath stringByAppendingString :@"/"];
                    cpath=[cpath stringByAppendingString :[filePath lastPathComponent]];
                    //mark in 2015.11.24 此方法已废
                    //                    [FileTools moveFileByUrl:filePath   toPath:cpath];
                    [selectedItemsDic removeObjectForKey:filePath];
                    
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已移动" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
            break;
        
        case 2:{ //upload
            if (selectedItemsDic.count>0) {
                
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
                    int result = [FileTools saveFileFromAsset:[selectedItemsDic valueForKey:filePath] toPath:filePath];
//                    if (result==0) {
//                        [selectedItemsDic removeObjectForKey:filePath];
//                    }
                    
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
            break;
        
        
        default:
            break;
    }
 
}

#pragma mark -
#pragma mark alertView的委托方法
-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0 && [opType intValue] ==2) {
        [UIHelper showLoginView:self];
    }
}

@end
