//
//  AudioTableViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/25.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "AudioTableViewController.h"
#import "FileInfo.h"
#import "FileTools.h"
#import "FDTableViewCell.h"
#import "AudioViewController.h"
#import "UIHelper.h"

#import "NSUUIDTool.h"
#import "UIHelper.h"
#import "UploadFileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"

#define AU_Cell_Height 52
static NSString* cellIdentifier = @"cellId";
@interface AudioTableViewController ()
{
    NSMutableArray *audiosArray;
    NSMutableArray *audiosUrl;
    NSMutableArray* audioThumbsArray;//存储所有的音频缩略图
    NSMutableArray* audioPlayerThumbsArray;//存储播放器所需的音频缩略图
    UIButton* rightBtn;
    UIBarButtonItem *leftBtn;
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名
    
    FileDialogViewController *fileDialog;
    NSString *opType; //1 delete 2 upload
}
@end

@implementation AudioTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 32, 32);
    [rightBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(switchTableViewModel:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    
    [self.audioTableView registerClass:[FDTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    //去掉tableView分割线左边短15像素
    if ([self.audioTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.audioTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.audioTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.audioTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.audioTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    audiosArray = [[NSMutableArray alloc]init];
    audioThumbsArray = [[NSMutableArray alloc]init];
    audioPlayerThumbsArray=[[NSMutableArray alloc]init];
    selectedItemsDic = [[NSMutableDictionary alloc] init];
    audiosUrl = [[NSMutableArray alloc] init];
    [self loadFileData];
    CGSize screenSize = [UIHelper getScreenSize];
    float width =screenSize.width;
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
    [delBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    [delBtn addTarget: self action: @selector(deleteFiles:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *delBtnItem = [[UIBarButtonItem alloc] initWithCustomView:delBtn];
    UIBarButtonItem *space= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44.0, width, 44.0)];
    [toolBar setBarStyle:UIBarStyleDefault];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [toolBar setItems:@[uploadBtnItem,space,delBtnItem]];
    [self.view addSubview:toolBar];
    [self.audioTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
}

//UITableViewDataSource协议中的方法
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FDTableViewCell * cell = (FDTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
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
    if(audioThumbsArray.count>0)
    {
        cell.fileinfo = audiosArray[indexPath.row];
        cell.imageView.image = audioThumbsArray[indexPath.row];
        cell.imageView.frame = CGRectMake(5,10,60,60);
        CGSize itemSize = CGSizeMake(60, 50);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(2.0, 2.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    cell.imageView.frame = CGRectMake(0, 0, 29, 29);
    //  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accessoryButton.frame = CGRectMake(100,5,50,50);
    [accessoryButton setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    [accessoryButton addTarget:self action:@selector(accessoryButtonIsTapped:event:)forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryButton;
    
    FileInfo* fileInfo = audiosArray[indexPath.row];
    cell.fileinfo = fileInfo;
    cell.textLabel.text = fileInfo.fileName;
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}
//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return audiosArray.count;
}
//UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AU_Cell_Height;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.audioTableView cellForRowAtIndexPath:indexPath];
    if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl])){
        [selectedItemsDic setObject:cell.fileinfo.fileUrl forKey:cell.fileinfo.fileUrl];
        
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.audioTableView cellForRowAtIndexPath:indexPath];
    if(cell){
        [selectedItemsDic removeObjectForKey:cell.fileinfo.fileUrl];
        
    }
}
//UITableViewDelegate协议中的方法
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)accessoryButtonIsTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.audioTableView];
    NSIndexPath *indexPath = [self.audioTableView indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath != nil)
    {
        [self tableView:self.audioTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        //      FDTableViewCell* cell =(FDTableViewCell*)[self tableView:self.audioTableView  cellForRowAtIndexPath:indexPath];
        //    NSString * filePath = cell.fileinfo.fileUrl;
        AudioViewController *audioPlayerView= [[AudioViewController alloc] initWithNibName:@"AudioViewController" bundle:nil];
        audioPlayerView.playerURL = audiosUrl;
        audioPlayerView.songIndex = indexPath.row;
        audioPlayerView.picURL =audioPlayerThumbsArray;
        audioPlayerView.netOrLocalFlag =@"1";
        
        [self presentViewController:audioPlayerView animated:YES completion:nil];
    }
}
//加载本地文件数据
- (void)loadFileData
{
    NSString* documentsPath = kDocument_Folder;
    NSMutableDictionary* fileDictionary = [[NSMutableDictionary alloc] init];
    fileDictionary = [FileTools getAllFilesByType:documentsPath skipDescendents:true fileExtend:@[@"mp3"]];
    FileInfo *dirList = [[FileInfo alloc] init];
    if (audioThumbsArray.count>0) {
        [audioThumbsArray removeAllObjects];
    }
    if(audioPlayerThumbsArray.count>0)
    {
        [audioPlayerThumbsArray removeAllObjects];
    }
    if (audiosArray.count>0) {
        [audiosArray removeAllObjects];
    }
    for (int i=0;i<fileDictionary.count;i++){
        dirList = [fileDictionary valueForKey:[NSString stringWithFormat:@"%d", i]];
        [audiosArray addObject:dirList];
        [audiosUrl addObject:dirList.fileUrl];
        //以下是获取音频缩略图的代码
        NSURL *fileURL = [NSURL fileURLWithPath:dirList.fileUrl];
        NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:fileURL];
        UIImage *image = [audioDataDic objectForKey:@"Artwork"];
        if (image) {
            [audioThumbsArray addObject:image];
            [audioPlayerThumbsArray addObject:image];
        }else{
            [audioThumbsArray addObject:[UIImage imageNamed:@"music-icon"]];
            [audioPlayerThumbsArray addObject:[UIImage imageNamed:@"audio_player_default.jpg"]];
        }
    }
    [self.audioTableView reloadData];
}

#pragma mark -
#pragma mark switchTableViewModel 设置TableView的状态（可选、不可选）
- (void)switchTableViewModel:(UIBarButtonItem *)sender {
    self.audioTableView.allowsMultipleSelectionDuringEditing=!self.audioTableView.allowsMultipleSelectionDuringEditing;
    if (self.audioTableView.allowsMultipleSelectionDuringEditing) {
        self.audioTableView.allowsMultipleSelectionDuringEditing=YES;
        [self.audioTableView setEditing:YES animated:YES];
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"全选"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllRows:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }else{
        self.audioTableView.allowsMultipleSelectionDuringEditing=NO;
        [self.audioTableView setEditing:NO animated:YES];
        [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(returnAction:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
        [selectedItemsDic removeAllObjects];
        
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
#pragma mark selectAllRows 设置TableView的全选
- (void) selectAllRows:(id)sender{
    for (int row=0; row<audiosArray.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.audioTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView :self.audioTableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark deleteFiles 删除本地文件的方法
- (void) deleteFiles:(id)sender{
    opType =  @"1"; //delete;
    if (selectedItemsDic.count>0) {
        for (NSString *fileUrl in [selectedItemsDic allKeys]){
            int result = [FileTools deleteFileByUrl:fileUrl];
            if (result==0) {
                [selectedItemsDic removeObjectForKey:fileUrl];
            }
        }
        [self loadFileData];
    }
}

#pragma mark -
#pragma mark uploadFilesAction 上传本地文件的方法
- (void) uploadFilesAction:(id)sender{
    opType =@"2";//upload
    if (selectedItemsDic.count==0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择要上传的文件！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //如果用户未登录提示用户登录
    NSString* userName = [g_sDataManager userName];
    if (!userName || [userName isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
        [alert show];
        return;
    }else{
        if (selectedItemsDic.count>0) {
            fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
            fileDialog.isShowFile =YES;
            fileDialog.isServerFile = YES;
            fileDialog.cpath =@"/";
            fileDialog.isSelectFileMode =NO;
            fileDialog.fileDialogDelegate = self;
            [self.navigationController pushViewController:fileDialog animated:YES];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择音频" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    self.audioTableView.allowsMultipleSelectionDuringEditing=NO;
    [self.audioTableView setEditing:NO animated:YES];
    [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
    leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(returnAction:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

#pragma mark -
#pragma mark chooseFileDirAction的委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
    switch([opType intValue]){
            
        case 2 :{ //upload
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
