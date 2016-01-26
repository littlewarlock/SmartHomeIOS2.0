//
//  CloudFileViewController.m
//  SmartHomeForIOS===
//
//  Created by riqiao on 15/10/13.
//  Copyright © 2014年 riqiao. All rights reserved.
//
#import "CloudFileViewController.h"
#import "FileInfo.h"
#import "FileTools.h"
#import "FDTableViewCell.h"
#import "KxMenu.h"
#import "UIHelper.h"
#import "FileDownloadTools.h"
#import "UploadFileTools.h"
#import "UIButton+UIButtonExt.h"
#import "UserEditViewController.h"
#import "DataManager.h"
#import "ValidateTool.h"
#import "RequestConstant.h"
#import "CustomActionSheet.h"
#import "HomeViewController.h"
#import "DeckTableViewController.h"
#import "KxMovieView.h"
#import "TableViewDelegate.h"
#import "TaskStatusConstant.h"
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define AU_Cell_Height 52


@interface CloudFileViewController ()
{
    NSOperationQueue *downloadQueue;
    NSOperationQueue *uploadQueue;
    NSMutableDictionary * tableDataDic;
    UIButton *leftBtn;
    UIButton* rightBtn;
    UIView* loadingView;
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名
    FileDialogViewController *fileDialog;
    int opType;
    NSMutableArray* pics;
    NSMutableArray* videos;
    MWPhoto *photo;
    FileHandler *fileHandler;
    NSMutableArray *defaultToolBarBtnArray;
    NSMutableArray *editToolBarBtnArray;
    CustomActionSheet *sheet;
    BOOL isCheckedAll;
    NSInteger currentModel; //0,表示正常模式 1，表示编辑模式 区分底部不同按钮的处理事件
    UITableView *tableView;
    TableViewDelegate *tableViewDelegate;
    NSMutableArray *duplicateFileNamesArray;
}
@property KxMovieView *kxvc;
@end

@implementation CloudFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人私有云";
    UIImage* img=[UIImage imageNamed:@"back"];
    leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame =CGRectMake(200, 0, 32, 32);
    [leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    [leftBtn addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    //设置右侧按钮
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 50, 30);
    [rightBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(switchTableViewModel:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    
    selectedItemsDic = [[NSMutableDictionary alloc] init];
    [self.fileListTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线
    [self.fileListTableView setSeparatorInset:UIEdgeInsetsZero]  ;
    [self loadFileData];
    downloadQueue = [[NSOperationQueue alloc] init];
    [downloadQueue setMaxConcurrentOperationCount:1];
    uploadQueue = [[NSOperationQueue alloc] init];
    [uploadQueue setMaxConcurrentOperationCount:1];
    //添加滑动手势
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
    pics = [[NSMutableArray alloc]init];
    videos = [[NSMutableArray alloc]init];
    
    UIRefreshControl *control=[[UIRefreshControl alloc]init];
    [control addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.fileListTableView addSubview:control];
    currentModel =0;
    fileHandler = [[FileHandler alloc] init];
    fileHandler.fileHandlerDelegate = self;
    fileHandler.tableDataDic = tableDataDic;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [rightBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
}
-(void) viewDidAppear:(BOOL)animated
{
    [selectedItemsDic removeAllObjects];
    [self requestFileData:NO refreshControl:nil];
    [self setFooterButtonState];
}

- (void)loadFileData
{
    tableDataDic = [[NSMutableDictionary alloc] init];
    //1.如果是选择本地文件夹，则直接从根目录下开始展示
    if (!self.isServerFile) {
        NSString* documentsPath= @"";
        if(self.cpath!=nil && [self.cpath length]>0)
        {
            documentsPath =self.cpath;
        }
        else
        {
            documentsPath=kDocument_Folder;
            self.rootUrl =documentsPath;//指定当前根目录为doucuments
        }
        self.cpath =documentsPath;
        if (tableDataDic != nil) {
            [tableDataDic removeAllObjects];
        }
        if(!self.isShowFile && !self.isServerFile) //只显示本地的目录
        {
            tableDataDic=[FileTools getAllFiles:documentsPath skipDescendents:YES isShowAlbum:YES];
        }
        [self.fileListTableView reloadData];
    }else if(self.isServerFile){//2.如果是选择服务器端文件夹，则需要发送请求到服务器端
        self.rootUrl = @"/";
        [self requestFileData:YES refreshControl:nil];
    }
}

//UITableViewDataSource协议中的方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//UITableViewDataSource协议中的方法
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FileInfo *fileinfo = (FileInfo *)[tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    fileinfo.cpath = self.cpath;
    FDTableViewCell *cell = (FDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:fileinfo.fileName];
    if (cell == nil) {
        cell = [[FDTableViewCell alloc] initWithFile:fileinfo];
    }
    if ([cell.fileinfo.fileType isEqualToString:@"folder"]) {
        
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryButton.frame = CGRectMake(100,5,50,50);
        [accessoryButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
        [accessoryButton addTarget:self action:@selector(accessoryButtonIsTapped:event:)forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = accessoryButton;
    }
    NSString *subType = [cell.fileinfo.fileName pathExtension];
    NSArray *documentArray=  [NSArray arrayWithObjects:@"doc",@"docx",@"xls",@"xlsx", nil];
    BOOL isDocument = [documentArray containsObject:[subType lowercaseString]];
    NSArray *audioArray=  [NSArray arrayWithObjects:@"mp3", nil];
    BOOL isAudio = [audioArray containsObject:[subType lowercaseString]];
    NSArray *videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                           @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
    BOOL isVideo = [videoArray containsObject:[subType lowercaseString]];
    
    NSArray *picArray=  [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg", nil];
    BOOL isPic = [picArray containsObject:[subType lowercaseString]];
    
    if(isPic ){
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [cell addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
    }else if(isVideo ){
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo:)];
        [cell addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
    }else if(isAudio){
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAudio:)];
        [cell addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
    }
    cell.fileinfo = fileinfo;
    [cell setDetailText];
    cell.textLabel.text = fileinfo.fileName;
    return cell;
}

- (BOOL)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.fileListTableView.allowsMultipleSelectionDuringEditing) {
        return NO;
    }
    return YES;
}

//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableDataDic.count;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileInfo *fileinfo = (FileInfo *)[tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    if(!self.fileListTableView.allowsMultipleSelectionDuringEditing){
        //    如果是文件夹的时候，进入下一级文件夹
        if (!self.isServerFile) {
            if ([fileinfo.fileType isEqualToString:@"folder"])
            {
                if (tableDataDic != nil) {
                    [tableDataDic removeAllObjects];
                }
                self.cpath = [self.cpath stringByAppendingPathComponent:fileinfo.fileName];
                tableDataDic=[FileTools getAllFiles:self.cpath skipDescendents:YES isShowAlbum:NO];
                [self.fileListTableView reloadData];
                
            }
            else{
                FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
                if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
                    [selectedItemsDic setObject:cell.fileinfo.fileName forKey:cell.fileinfo.fileName];
                }
            }
        }else{
            if ([fileinfo.fileType isEqualToString:@"folder"] )
            {
                CloudFileViewController *cloudFileView = [[CloudFileViewController alloc] initWithNibName:@"CloudFileViewController" bundle:nil];
                cloudFileView.cpath =[self.cpath stringByAppendingPathComponent: fileinfo.fileName];
                cloudFileView.isServerFile = YES;
                cloudFileView.isInSharedFolder = self.isInSharedFolder;
                if([self.cpath isEqualToString:@"/"]){
                    if([fileinfo.isShare isEqualToString:@"1"]){
                        cloudFileView.isInSharedFolder = YES;
                    }else{
                        cloudFileView.isInSharedFolder = NO;
                    }
                }
                
                [self.navigationController pushViewController:cloudFileView  animated:YES];
            }
            else{
                FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
                if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
                    //  [selectedItemsDic setObject:cell.fileinfo.fileName forKey:cell.fileinfo];
                }
            }
        }
    }else{
        if (!self.isServerFile) {
            FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
            if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl])){
                [selectedItemsDic setObject:cell.fileinfo.fileUrl forKey:cell.fileinfo.fileUrl];
            }
        }else{
            
            FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
            
            if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
                [selectedItemsDic setObject:cell.fileinfo forKey:cell.fileinfo.fileName];
                [self setFooterButtonState]; //更新按钮的状态
                if (tableDataDic.count>0 && selectedItemsDic.count == tableDataDic.count) {
                    isCheckedAll = YES;
                    UIImage *image = [UIImage imageNamed:@"checkall"];
                    [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
                }
                
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isServerFile) {
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
        if(cell && [[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl]){
            [selectedItemsDic removeObjectForKey:cell.fileinfo.fileUrl];
        }
    }else{
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
        if(cell && [[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName]){
            [selectedItemsDic removeObjectForKey:cell.fileinfo.fileName];
            [self setFooterButtonState]; //更新按钮的状态
            isCheckedAll = NO;
            UIImage *image = [UIImage imageNamed:@"checkbox-down"];
            [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
        }
    }
}
//UITableViewDelegate协议中的方法
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
#pragma mark -
#pragma mark UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AU_Cell_Height;
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

#pragma mark -
#pragma mark returnAction 返回按钮
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark requestFileData 返回dirPath下的所有文件
-(void)requestFileData:(BOOL) isShowLoading refreshControl:(UIRefreshControl *)control
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
    [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
    if (self.cpath && [self.cpath length]>0) {
        [dic setValue:self.cpath forKey:@"cpath"];
        
    }
    if([self.cpath isEqualToString:@"/"]){
        [dic setValue:@"" forKey:@"cpath"];
    }
    
    if (isShowLoading) {
        loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在获取目录" ];
    }
    
    // Reachability
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_FETCH_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"1"])//获取目录成功
        {
            if (tableDataDic != nil) {
                [tableDataDic removeAllObjects];
            }
            if(pics!=nil){
                [pics removeAllObjects];
            }
            NSArray *responseJSONResult=responseJSON[@"result"];
            if([responseJSONResult isEqual:@"file not exit"]){
                if (isShowLoading) {
                    if (loadingView)
                    {
                        [loadingView removeFromSuperview];
                        loadingView = nil;
                    }
                }else{
                    [control endRefreshing];
                }
                return;
            }
            //先取文件夹
            [responseJSONResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                if (responseJSONResult && responseJSONResult.count>0) {
                    FileInfo *fileInfo = [[FileInfo alloc] init];
                    fileInfo.fileName = dict[@"fileName"];
                    if(![dict[@"fileSize"] isEqualToString:@""]){
                        fileInfo.fileSize = [FileTools  convertFileSize: dict[@"fileSize"]];
                    }
                    fileInfo.fileChangeTime = dict[@"fileChangeTime"];
                    fileInfo.fileType = dict[@"fileType"];
                    if([fileInfo.fileType isEqualToString:@"folder"])
                    {
                        fileInfo.fileSubtype =@"folder";
                        NSString *isShare = [NSString stringWithFormat:@"%@",dict[@"isShare"]];
                        fileInfo.isShare = isShare;
                        [tableDataDic setObject:fileInfo forKey:[NSString stringWithFormat:@"%zi", [tableDataDic count]]];
                    }
                }else{
                    *stop = YES;
                }
            }];
            __block NSUInteger index =[tableDataDic count];
            //再获取文件
            [responseJSONResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                
                if (responseJSONResult && responseJSONResult.count>0) {
                    FileInfo *fileInfo = [[FileInfo alloc] init];
                    fileInfo.fileName = dict[@"fileName"];
                    fileInfo.fileSize = [FileTools  convertFileSize: dict[ @"fileSize"]];
                    fileInfo.fileChangeTime = dict[@"fileChangeTime"];
                    fileInfo.fileType = dict[@"fileType"];
                    NSString *isShare = [NSString stringWithFormat:@"%@",dict[@"isShare"]];
                    
                    fileInfo.isShare = isShare;
                    if([fileInfo.fileType isEqualToString:@"file"])
                    {
                        fileInfo.fileSubtype =[fileInfo.fileName pathExtension];
                        if (!fileInfo.fileSubtype || [fileInfo.fileSubtype isEqualToString:@""]) {
                            fileInfo.fileSubtype=@"";
                        }
                        if ([[fileInfo.fileSubtype lowercaseString] isEqualToString:@"jpg"] || [[fileInfo.fileSubtype lowercaseString] isEqualToString:@"png"]) {
                            NSMutableString *picUrl = [NSMutableString stringWithFormat:@"http://%@/%@",[g_sDataManager requestHost],REQUEST_PIC_URL];
                            picUrl =[NSMutableString stringWithFormat:@"%@?uname=%@&filePath=%@&fileName=%@",picUrl,[[g_sDataManager userName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.cpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileInfo.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                            [pics addObject:picUrl];
                        } else if ([[fileInfo.fileSubtype lowercaseString] isEqualToString:@"mp4"] ||              [[fileInfo.fileSubtype lowercaseString] isEqualToString:@"mkv"]        || [[fileInfo.fileSubtype lowercaseString] isEqualToString:@"rmvb"]       || [[fileInfo.fileSubtype lowercaseString] isEqualToString:@"avi"]        || [[fileInfo.fileSubtype lowercaseString] isEqualToString:@"h264"]) {//视频文件
                            
                            NSMutableString *VideoUrl = [NSMutableString stringWithFormat:@"http://%@/smarty_storage",[g_sDataManager requestHost]];
                            
                            VideoUrl =[NSMutableString stringWithFormat:@"%@/ftp/root/%@%@/%@",VideoUrl,[g_sDataManager userName],self.cpath,fileInfo.fileName];
                            [videos addObject:VideoUrl];
                            
                            AppDelegate *app = [[UIApplication sharedApplication] delegate];
                            app.videoUrl = videos;
                            
                        }
                        NSString *isShare = [NSString stringWithFormat:@"%@",dict[@"isShare"]];
                        fileInfo.isShare = isShare;
                        [tableDataDic setObject:fileInfo forKey:[NSString stringWithFormat:@"%zi", index]];
                        index++;
                    }
                    
                }else{
                    *stop = YES;
                }
                
            }];
            [self.fileListTableView reloadData];
        }
        if (isShowLoading) {
            if (loadingView)
            {
                [loadingView removeFromSuperview];
                loadingView = nil;
            }
        }else{
            [control endRefreshing];
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        if (isShowLoading) {
            if (loadingView)
            {
                [loadingView removeFromSuperview];
                loadingView = nil;
            }
        }else{
            [control endRefreshing];
        }
    }];
    [engine enqueueOperation:op];
}


- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if(!self.navigationController.navigationBarHidden){
            [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
        }
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        
    }
}

- (void)createFolderAction:(id)sender{//新建文件夹的方法
    opType =4;
    FileHandler *fileHandler = [[FileHandler alloc] init];
    fileHandler.opType = 4;
    [fileHandler createFolder:fileHandler];
}


#pragma mark -
#pragma mark selectAllRows 设置TableView的全选
- (void) selectAllRows{
    for (int row=0; row<tableDataDic.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.fileListTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
        if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
            [selectedItemsDic setObject:cell.fileinfo forKey:cell.fileinfo.fileName];
        }
    }
    [self setFooterButtonState];
}

#pragma mark -
#pragma mark didDeSelectAllRows 设置TableView取消全选
- (void) didDeSelectAllRows{
    for (int row=0; row<tableDataDic.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.fileListTableView deselectRowAtIndexPath:indexPath animated:YES];
        [self tableView: self.fileListTableView didDeselectRowAtIndexPath:indexPath];
        
    }
    [self setFooterButtonState];
}

- (void)refreshAction:(id)sender
{
    [self loadFileData];
    [self.fileListTableView reloadData];
}

#pragma mark -
#pragma mark chooseFileAction FileDialogViewController委托方法
- (void)chooseFileAction:(UIButton *)sender{
    NSString *fileName=fileDialog.selectedFile;
    NSString* cpath = self.cpath;
    NSString* localFilePath = fileDialog.cpath;
    //[fileHandler uploadFile:fileName localFilePath:localFilePath serverCpath:cpath];
    [fileHandler uploadFileWithHttp:uploadQueue fileName:fileName localFilePath:localFilePath serverCpath:cpath];
    [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
}

#pragma mark -
#pragma mark chooseFileDirAction FileDialogViewController委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
    switch (opType) {
        case 1: //移动
        {
            NSString *targetPath = fileDialog.cpath;
            NSString *sourcePath=self.cpath;
            NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc]init];
            [paramsDic setValue:targetPath forKey:@"targetPath"];
            [paramsDic setValue:sourcePath forKey:@"sourcePath"];
            [paramsDic setValue:selectedItemsDic forKey:@"selectedItemsDic"];
            FileHandler * fileHandler  = [[FileHandler alloc]init];
            fileHandler.opType = 1;
            fileHandler.fileHandlerDelegate = self;
            if([sourcePath isEqualToString:targetPath]){ //如果目标目录和源目录相同 则不进行复制
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"目标目录不能为当前目录！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            BOOL isLegal = YES;
            if([targetPath length]>= [sourcePath length]){//如果目标目录是源目录的子目录 则不进行复制
                for (NSString *fileUrl in [selectedItemsDic allKeys]){//移动、复制对象所在的目录和要移动复制的目标目录所在的子目录
                    NSString *sourcefileUrl  = [sourcePath stringByAppendingPathComponent:fileUrl];
                    if([targetPath rangeOfString:sourcefileUrl].location !=NSNotFound)
                    {
                        NSString *subPath = [targetPath componentsSeparatedByString:sourcefileUrl][1];
                        NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
                        NSString *firstSubPathComponent = subPathComponentArray[0];
                        if([firstSubPathComponent isEqualToString:@""] ){
                            isLegal = NO;
                            break;
                        }
                    }
                }
            }
            if(!isLegal){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"目标目录不能为子目录！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            if([ValidateTool isInKeywordFolder:sourcePath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"目录“%@”下禁止移动！",sourcePath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            if([ValidateTool isInKeywordFolder:targetPath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"禁止向“%@”移动！",targetPath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            [NSThread detachNewThreadSelector:@selector(moveFiles:) toTarget:fileHandler withObject:paramsDic];
            break;
        }
        case 2:  //复制
        {
            
            NSString *targetPath = fileDialog.cpath;
            NSString *sourcePath=self.cpath;
            NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc]init];
            [paramsDic setValue:targetPath forKey:@"targetPath"];
            [paramsDic setValue:sourcePath forKey:@"sourcePath"];
            [paramsDic setValue:selectedItemsDic forKey:@"selectedItemsDic"];
            FileHandler * fileHandler  = [[FileHandler alloc]init];
            fileHandler.opType = 2;
            if([sourcePath isEqualToString:targetPath]){ //如果目标目录和源目录相同 则不进行复制
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"目标目录不能为当前目录！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            BOOL isLegal = YES;
            if([targetPath length]>= [sourcePath length]){//如果目标目录是源目录的子目录 则不进行复制
                for (NSString *fileUrl in [selectedItemsDic allKeys]){//移动、复制对象所在的目录和要移动复制的目标目录所在的子目录
                    NSString *sourcefileUrl  = [sourcePath stringByAppendingPathComponent:fileUrl];
                    if([targetPath rangeOfString:sourcefileUrl].location !=NSNotFound)
                    {
                        NSString *subPath = [targetPath componentsSeparatedByString:sourcefileUrl][1];
                        NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
                        NSString *firstSubPathComponent = subPathComponentArray[0];
                        if([firstSubPathComponent isEqualToString:@""] ){
                            isLegal = NO;
                            break;
                        }
                    }
                }
            }
            if(!isLegal){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"目标目录不能为子目录！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            
            if([ValidateTool isInKeywordFolder:targetPath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"禁止向“%@”复制！",targetPath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            
            [NSThread detachNewThreadSelector:@selector(copyFiles:) toTarget:fileHandler withObject:paramsDic];
            break;
        }
        default:
            break;
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
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:pics[index]]];
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
    //  return [[_selections objectAtIndex:index] boolValue];
    return false;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark browserPhotoAction 点击图片时触发的事件
- (void)browserPhotoAction:(id )sender
{
    // Browser
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
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
    NSUInteger index= 0;
    NSMutableString *picUrl = [NSMutableString stringWithFormat:@"http://%@/%@",[g_sDataManager requestHost],REQUEST_PIC_URL];
    picUrl =[NSMutableString stringWithFormat:@"%@?uname=%@&filePath=%@&fileName=%@",picUrl,[[g_sDataManager userName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.cpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.curCel.fileinfo.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    for (int i = 0; i<pics.count; i++) {
        if ([picUrl isEqualToString: pics[i]]) {
            index = i;
            break;
        }
    }
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)refreshTableView:(UIRefreshControl *)control
{
    [self requestFileData:NO refreshControl:control];
}


#pragma mark -
#pragma mark switchTableViewModel 设置TableView的状态（可选、不可选）
- (void)switchTableViewModel:(UIBarButtonItem *)sender {
    self.fileListTableView.allowsMultipleSelectionDuringEditing=!self.fileListTableView.allowsMultipleSelectionDuringEditing;
    if (self.fileListTableView.allowsMultipleSelectionDuringEditing) {
        self.fileListTableView.allowsMultipleSelectionDuringEditing=YES;
        currentModel = 1;
        [self.fileListTableView setEditing:YES animated:YES];
        [rightBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]forState:UIControlStateNormal];
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        UIImage *image1 = [UIImage imageNamed:@"checkbox-down"];
        UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
        UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
        UIImage *image4 = [UIImage imageNamed:@"more"];
        [self.footerBtn_1 setImage:image1 forState:(UIControlStateNormal)];
        self.footerLabel_1.text=@"全选";
        [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
        self.footerLabel_2.text=@"下载";
        self.footerBtn_2.enabled = NO;
        [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
        self.footerLabel_3.text=@"共享";
        self.footerBtn_3.enabled = NO;
        [self.footerBtn_4 setImage:image4 forState:(UIControlStateNormal)];
        self.footerLabel_4.text=@"更多";
    }else{
        currentModel =0;
        self.fileListTableView.allowsMultipleSelectionDuringEditing=NO;
        [self.fileListTableView setEditing:NO animated:YES];
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        [selectedItemsDic removeAllObjects];
        UIImage *image1 = [UIImage imageNamed:@"home"];
        UIImage *image2 = [UIImage imageNamed:@"upload"];
        UIImage *image3 = [UIImage imageNamed:@"refurbish"];
        UIImage *image4 = [UIImage imageNamed:@"new-folder"];
        [self.footerBtn_1 setImage:image1 forState:(UIControlStateNormal)];
        self.footerLabel_1.text=@"主页";
        [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
        self.footerBtn_2.enabled = YES;
        self.footerLabel_2.text=@"上传";
        [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
        self.footerBtn_3.enabled = YES;
        self.footerLabel_3.text=@"刷新";
        [self.footerBtn_4 setImage:image4 forState:(UIControlStateNormal)];
        self.footerLabel_4.text=@"新建目录";
        currentModel = 0;
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
        [sheet dismissSheet:self];
        
        if([ValidateTool isInKeywordFolder:self.cpath]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"目录“%@”下禁止复制！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        opType=2;
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = self.isServerFile;
        fileDialog.cpath =@"/";
        fileDialog.fileDialogDelegate = self;
        [self.navigationController pushViewController:fileDialog animated:YES];
    }else if(buttonIndex==2){//移动
        [sheet dismissSheet:self];
        
        if([ValidateTool isInKeywordFolder:self.cpath]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止移动！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        opType=1;
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = self.isServerFile;
        fileDialog.cpath =@"/";
        fileDialog.fileDialogDelegate = self;
        [self.navigationController pushViewController:fileDialog animated:YES];
        
    }else if(buttonIndex==3){//重命名
        
        if([ValidateTool isInKeywordFolder:self.cpath]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁重命名！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        NSString *fileName;
        if(selectedItemsDic.count>0){
            for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
                if (fileNameTmp) {
                    fileName = fileNameTmp;
                    break;
                }
            }
        }
        if([ValidateTool isEqualToKeyword:fileName]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"文件“%@”禁重命名重命名操作，请重新选择！",fileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        for (NSString *key in [tableDataDic allKeys]){
            if (key) {
                FileInfo *fileInfo = (FileInfo *)[tableDataDic objectForKey:key];
                if([fileInfo.isShare isEqualToString:@"1"] && [fileInfo.fileName isEqualToString:fileName]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"共享文件“%@”禁重命名操作，请重新选择！",fileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alert show];
                    return;
                }
            }
        }
        
        
        
        fileHandler.cpath = self.cpath;
        fileHandler.opType =5;
        fileHandler.selectedFileName =fileName;
        [fileHandler renameFile :fileName alertViewDelegate:fileHandler];
        
    }else if(buttonIndex==4){//删除
        if([ValidateTool isInKeywordFolder:self.cpath]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止删除！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        if(self.isInSharedFolder){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"被共享文件夹下禁止删除（临时）！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        
        [fileHandler deleteFiles:selectedItemsDic cpath:self.cpath];
        [selectedItemsDic removeAllObjects];
        [self setFooterButtonState];
    }
}
#pragma mark -
#pragma mark setFooterButtonState 设置底部按钮的状态
- (void)setFooterButtonState{
    if(selectedItemsDic.count>0){
        BOOL isContainFoler = NO;
        //        BOOL isContainSpecialFolder = NO;
        NSString *specialFolderName = [[NSString alloc] init];
        for (NSString *fileName in [selectedItemsDic allKeys]){
            if (fileName) {
                FileInfo *fileInfo = (FileInfo*) [selectedItemsDic objectForKey:fileName];
                if ([fileInfo.fileType isEqualToString:@"folder"]) {
                    isContainFoler = YES;
                }
                //                if ([[self.cpath stringByAppendingPathComponent: fileInfo.fileName] isEqualToString:SHARE_FOLDER_URL] || [[self.cpath stringByAppendingPathComponent: fileInfo.fileName] isEqualToString:USB_FOLDER_URL]) {
                //                    isContainSpecialFolder = YES;
                //                    specialFolderName = fileInfo.fileName;
                //                    break;
                //                }
            }
        }
        
        
        for (NSString *fileName in [selectedItemsDic allKeys]){
            if (fileName) {
                FileInfo *fileInfo = (FileInfo*) [selectedItemsDic objectForKey:fileName];
                if ([fileInfo.fileType isEqualToString:@"folder"]) {
                    isContainFoler = YES;
                    break;
                }
            }
        }
        
        if (isContainFoler) {//如果包含文件夹则下载按钮禁用
            UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
            [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
            self.footerBtn_2.enabled = NO;
            
            //            if(isContainSpecialFolder){
            //                UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
            //                [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
            //                self.footerBtn_3.enabled = NO;
            //            }else{
            UIImage *image3 = [UIImage imageNamed:@"share"];
            [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
            self.footerBtn_3.enabled = YES;
            //            }
        }else{
            UIImage *image2 = [UIImage imageNamed:@"download"];
            [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
            self.footerBtn_2.enabled = YES;
            UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
            [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
            self.footerBtn_3.enabled = NO;
        }
    }else{
        if (self.fileListTableView.allowsMultipleSelectionDuringEditing){
            UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
            UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
            [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
            self.footerBtn_2.enabled = NO;
            [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
            self.footerBtn_3.enabled = NO;
        }else{
            UIImage *image2 = [UIImage imageNamed:@"upload"];
            UIImage *image3 = [UIImage imageNamed:@"refurbish"];
            [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
            self.footerBtn_2.enabled = YES;
            [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
            self.footerBtn_3.enabled = YES;
        }
    }
}
#pragma mark -
#pragma mark footerButtonEventHandleAction 底部按钮点击处理事件
- (void)footerButtonEventHandleAction:(id)sender {
    if(currentModel==0){//正常模式下的处理
        if(sender==self.footerBtn_1){ //主页
            DeckTableViewController* leftController = [[DeckTableViewController alloc] initWithNibName:@"DeckTableViewController" bundle:nil];
            leftController = [[UINavigationController alloc] initWithRootViewController:leftController];
            
            UIViewController *centerController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
            
            centerController = [[UINavigationController alloc] initWithRootViewController:centerController];
            
            IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
                                                                                            leftViewController:leftController];
            
            deckController.delegateMode = IIViewDeckDelegateOnly;
            // self.window.rootViewController = deckController;
            [self presentViewController:deckController animated:NO completion:nil];
        }
        else if(sender==self.footerBtn_2){//上传
            if([ValidateTool isInKeywordFolder:self.cpath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止上传！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
            fileDialog.isShowFile =YES;
            fileDialog.isServerFile = NO;
            fileDialog.isSelectFileMode = YES;
            fileDialog.fileDialogDelegate = self;
            NSString* documentsPath = kDocument_Folder;
            fileDialog.cpath = documentsPath;
            fileDialog.rootUrl = documentsPath;
            //UINavigationController *fileDialogNav =[[UINavigationController alloc]initWithRootViewController:fileDialog];
            //  [self.navigationController presentViewController:fileDialogNav animated:YES completion:nil];
            [self.navigationController pushViewController:fileDialog animated:YES];
            
        }
        else if(sender==self.footerBtn_3){//刷新
            [self requestFileData:YES refreshControl:nil];
        }
        else if(sender==self.footerBtn_4){//新建文件夹
            if([ValidateTool isInKeywordFolder:self.cpath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止新建文件夹！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            if(self.isInSharedFolder){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"被共享文件夹下禁止新建文件夹！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }else{
                opType =4;
                fileHandler.opType = 4;
                fileHandler.cpath =self.cpath;
                [fileHandler createFolder:fileHandler];
            }
        }
    }else if(currentModel==1){
        if(sender==self.footerBtn_1){ //全选
            isCheckedAll = !isCheckedAll;
            if (isCheckedAll) {
                [self selectAllRows];
                UIImage *image = [UIImage imageNamed:@"checkall"];
                [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
            }else{
                [self didDeSelectAllRows];
                UIImage *image = [UIImage imageNamed:@"checkbox-down"];
                [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
            }
        }
        else if(sender==self.footerBtn_2){//下载
            NSString *targetPath =[kDocument_Folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[g_sDataManager userName]]];
            //1.先判断队列中是否已有该文件
            for(FileDownloadOperation *operation in [NSOperationDownloadQueue sharedInstance].operations) {
                NSString *fileName = operation.taskInfo.fileName;
                NSString *fileNamePath = [targetPath stringByAppendingPathComponent:fileName];
                if ([selectedItemsDic objectForKey:fileName] && [fileNamePath isEqualToString:operation.taskInfo.cachePath]) { //如果当前下载队列中包含该文件，且该文件的目标路径和当前操作要下载到的目标路径相同
                    [selectedItemsDic removeObjectForKey:fileName];
                }
            }
            //2.再判断未完成已取消任务中是否有该文件
            for(NSString *taskId in [[ProgressBarViewController sharedInstance].downloadTaskDic allKeys] ){
                TaskInfo *taskInfo = [[ProgressBarViewController sharedInstance].downloadTaskDic objectForKey:taskId];
                for (NSString *fileName in [selectedItemsDic allKeys]) {
                    if ([taskInfo.taskName isEqualToString:fileName] && ([taskInfo.taskStatus isEqualToString:CANCLED]|| [taskInfo.taskStatus isEqualToString:FAILURE])) {
                        [selectedItemsDic removeObjectForKey:fileName];
                    }
                }
                
            }
            //3.判断是否目标路径下已经包含一个同名的文件
            duplicateFileNamesArray =[FileTools getDuplicateFileNames: targetPath fileNames:[selectedItemsDic allKeys]];
            if(duplicateFileNamesArray.count>0){//如果目标路径下包含重名的文件，提示用户是否需要覆盖
                [self launchDialog:duplicateFileNamesArray];
            }else{
                [fileHandler downloadFiles:[NSOperationDownloadQueue sharedInstance] selectedItemsDic:selectedItemsDic cpath:self.cpath cachePath:targetPath];
                [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                [selectedItemsDic removeAllObjects];
            }
        }
        else if(sender==self.footerBtn_3){//共享
            
            BOOL isContainSpecialFolder = NO;
            NSString *specialFolderName = [[NSString alloc] init];
            for (NSString *fileName in [selectedItemsDic allKeys]){
                if (fileName) {
                    FileInfo *fileInfo = (FileInfo*) [selectedItemsDic objectForKey:fileName];
                    if ([fileInfo.fileType isEqualToString:@"folder"]) {
                        if ([ValidateTool isEqualToKeyword:fileInfo.fileName] &&[self.cpath isEqualToString:@"/"]) {
                            isContainSpecialFolder = YES;
                            specialFolderName = fileInfo.fileName;
                            break;
                        }
                    }
                }
            }
            if(isContainSpecialFolder){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"文件夹“%@”禁止共享！",specialFolderName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            if([ValidateTool isInKeywordFolder:self.cpath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"目录“%@”下文件夹禁止共享！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            if(![self.cpath isEqualToString:@"/"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"根目录以外文件夹禁止共享！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                [alert show];
                return;
            }
            
            opType =6;
            fileHandler.opType = 6;
            fileHandler.cpath =self.cpath;
            [fileHandler shareFiles:selectedItemsDic cpath:self.cpath isShare:@"1"];
        }
        else if(sender==self.footerBtn_4){//更多
            sheet= [CustomActionSheet styleDefault];
            sheet.delegate = self;
            if (selectedItemsDic.count==0) {
                [sheet setButtonState:1 buttonState:NO];
                [sheet setButtonState:2 buttonState:NO];
                [sheet setButtonState:3 buttonState:NO];
                [sheet setButtonState:4 buttonState:NO];
            }else if(selectedItemsDic.count==1) {
                [sheet setButtonState:1 buttonState:YES];
                [sheet setButtonState:2 buttonState:YES];
                [sheet setButtonState:3 buttonState:YES];
                [sheet setButtonState:4 buttonState:YES];
            }else if(selectedItemsDic.count>=2) {
                [sheet setButtonState:1 buttonState:YES];
                [sheet setButtonState:2 buttonState:YES];
                [sheet setButtonState:3 buttonState:NO];
                [sheet setButtonState:4 buttonState:YES];
            }
            [sheet showSheet:self];
        }
    }
}


#pragma mark -
#pragma mark FileHandler 的代理方法
- (void)requestSuccessCallback{
    [self loadFileData];
    [selectedItemsDic removeAllObjects];
    if (sheet) {
        [sheet dismissSheet:self];
    }
    if (loadingView)
    {
        [loadingView removeFromSuperview];
        loadingView = nil;
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
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
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
            NSUInteger index= 0;
            NSMutableString *picUrl = [NSMutableString stringWithFormat:@"http://%@/%@",[g_sDataManager requestHost],REQUEST_PIC_URL];
            picUrl =[NSMutableString stringWithFormat:@"%@?uname=%@&filePath=%@&fileName=%@",picUrl,[[g_sDataManager userName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.cpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.curCel.fileinfo.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            browser.filePath = picUrl;
            for (int i = 0; i<pics.count; i++) {
                if ([picUrl isEqualToString: pics[i]]) {
                    index = i;
                    break;
                }
            }
            [browser setCurrentPhotoIndex:index];
            [self.navigationController pushViewController:browser animated:YES];
        }
    }
}

#pragma mark -
#pragma mark handleTap 点击视频时触发的事件
- (void)playVideo:(UITapGestureRecognizer *)sender{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            __block NSError *error = nil;
            [dic setValue:[g_sDataManager userName] forKey:@"uname"];
            [dic setValue:self.cpath forKey:@"filePath"];
            [dic setValue:self.curCel.fileinfo.fileName forKey:@"fileName"];
            
            NSString* requestHost = [g_sDataManager requestHost];
            NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
            
            MKNetworkOperation *op = [engine operationWithPath:REQUEST_VIDEO_URL params:dic httpMethod:@"POST" ssl:NO];
            [op addCompletionHandler:^(MKNetworkOperation *operation) {
                NSLog(@"[operation responseData]-->>%@", [operation responseString]);
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                NSLog(@"[operation responseJSON]-->>%@",responseJSON);
                
                NSString *videoPath =  [responseJSON objectForKey:@"videopath"];
                
                NSRange range  = [videoPath rangeOfString:@"/smarty_storage"];
                NSString *subVideoPath = [videoPath  substringFromIndex:range.location];
                NSString *videoUrl = [NSString stringWithFormat:@"%@%@%@",@"http://",requestHost,subVideoPath];
                
                
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
                self.kxvc = [KxMovieView movieViewControllerWithContentPath:(NSMutableString*)videoUrl parameters:parameters];
                self.kxvc.filePath = videoUrl;
                [self addChildViewController:self.kxvc];
                self.kxvc.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height);
                self.kxvc.filePath = (NSMutableString*)videoUrl;
                [self.kxvc fullscreenMode:nil];
                [self.kxvc bottomBarAppears];
                [self.view addSubview:self.kxvc.view];
                
                //根据文件名获取当前视频的索引
                NSUInteger index = 0;
                for (int i = 0; i<videos.count; i++) {
                    if ([videoUrl isEqualToString: videos[i]]) {
                        index = i;
                        break;
                    }
                }
                [self.kxvc setCurrentVideoIndex:index];
                
                self.navigationController.navigationBarHidden = YES;
                
            }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            }];
            [engine enqueueOperation:op];
        }
    }
}

#pragma mark -
#pragma mark handleTap 点击视频时触发的事件
- (void)playAudio:(UITapGestureRecognizer *)sender{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            __block NSError *error = nil;
            [dic setValue:[g_sDataManager userName] forKey:@"uname"];
            [dic setValue:self.cpath forKey:@"filePath"];
            [dic setValue:self.curCel.fileinfo.fileName forKey:@"fileName"];
            
            NSString* requestHost = [g_sDataManager requestHost];
            NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
            
            MKNetworkOperation *op = [engine operationWithPath:REQUEST_VIDEO_URL params:dic httpMethod:@"POST" ssl:NO];
            [op addCompletionHandler:^(MKNetworkOperation *operation) {
                NSLog(@"[operation responseData]-->>%@", [operation responseString]);
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                NSLog(@"[operation responseJSON]-->>%@",responseJSON);
                
                NSString *videoPath =  [responseJSON objectForKey:@"videopath"];
                
                NSRange range  = [videoPath rangeOfString:@"/smarty_storage"];
                NSString *subVideoPath = [videoPath  substringFromIndex:range.location];
                NSString *videoUrl = [NSString stringWithFormat:@"%@%@%@",@"http://",requestHost,subVideoPath];
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
                self.kxvc = [KxMovieView movieViewControllerWithContentPath:(NSMutableString*)videoUrl parameters:parameters];
                [self addChildViewController:self.kxvc];
                self.kxvc.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height);
                self.kxvc.filePath = (NSMutableString*)videoUrl;
                [self.kxvc fullscreenMode:nil];
                [self.kxvc bottomBarAppears];
                [self.view addSubview:self.kxvc.view];
                
                self.navigationController.navigationBarHidden = YES;
                
            }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            }];
            [engine enqueueOperation:op];
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
    }else{
        
    }
    //  [alertView close];
    //  UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"sss===%d",tableViewDelegate.selectedFileNamesDic.count] delegate:nil cancelButtonTitle:@"1" otherButtonTitles:@"2", nil];
    //   [alert show];
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
