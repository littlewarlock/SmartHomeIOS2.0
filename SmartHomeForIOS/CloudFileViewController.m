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
#import "NSOperationUploadQueue.h"
#import "NSOperationDirsDownloadQueue.h"
#import "DirsDownloadOperation.h"
#import "DirsHandler.h"
#import "KeyWordConstant.h"
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define AU_Cell_Height 52


@interface CloudFileViewController ()<UITabBarDelegate>
{
    NSMutableArray *tableDataArray;//存储所有返回的文件（夹）
    NSOperationQueue *downloadQueue;
    NSMutableDictionary * tableDataDic;
    UIButton *leftBtn;
    UIButton* rightBtn;
    UIView* loadingView;
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名
    FileDialogViewController *fileDialog;
    int opType; //1.移动 2.复制 3.无 4.新建文件夹 5.重命名 6.共享 7.下载 8.上传
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
    self.isServerSessionTimeOut = NO;
    downloadQueue = [[NSOperationQueue alloc] init];
    [downloadQueue setMaxConcurrentOperationCount:1];
    //添加滑动手势
    
    pics = [[NSMutableArray alloc]init];
    videos = [[NSMutableArray alloc]init];
    
    UIRefreshControl *control=[[UIRefreshControl alloc]init];
    [control addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.fileListTableView addSubview:control];
    currentModel =0;
    fileHandler = [[FileHandler alloc] init];
    fileHandler.fileHandlerDelegate = self;
    fileHandler.tableDataDic = tableDataDic;
    duplicateFileNamesArray =[[NSMutableArray alloc] init];
    UITabBar *tabbar = self.tabbar;
    tabbar.delegate = self;
    self.moreBar.hidden = YES;
    self.moreBar.delegate = self;
    self.misButton.hidden = YES;
    NSLog(@"viewDidLoad:%@",tableDataDic);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [rightBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
}

-(void) viewDidAppear:(BOOL)animated
{
    [selectedItemsDic removeAllObjects];
    //edit by lcw 20160229
    //此判断用于防止重复提示session超时 若viewDidAppear去掉requestFileData 返回按钮后不在刷新表单
    if(!self.isServerSessionTimeOut){
        [self requestFileData:NO refreshControl:nil];
    }
    [self setFooterButtonState];
}

- (void)loadFileData
{
    tableDataDic = [[NSMutableDictionary alloc] init];
    self.rootUrl = @"/";
    [self requestFileData:YES refreshControl:nil];
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
    }else{
        if(![cell.fileinfo.isShare isEqualToString: fileinfo.isShare]){
            cell = [[FDTableViewCell alloc] initWithFile:fileinfo];
        }
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
        }else{
            
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAlert:)];
            [cell addGestureRecognizer:tapRecognizer];
            tapRecognizer.delegate = self;
        }
    }
    cell.fileinfo = fileinfo;
    [cell setDetailText];
    
    NSLog(@"cell.fileinfo.fileChangeTime%@",cell.fileinfo.fileChangeTime);
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
        if ([fileinfo.fileType isEqualToString:@"folder"] )
        {
            CloudFileViewController *cloudFileView = [[CloudFileViewController alloc] initWithNibName:@"CloudFileViewController" bundle:nil];
            cloudFileView.cpath =[self.cpath stringByAppendingPathComponent: fileinfo.fileName];
            cloudFileView.isInSharedFolder = self.isInSharedFolder;
            if([self.cpath isEqualToString:@"/"]){
                if([fileinfo.isShare isEqualToString:@"1"]){
                    cloudFileView.isInSharedFolder = YES;
                }else{
                    cloudFileView.isInSharedFolder = NO;
                }
            }
            
            [self.navigationController pushViewController:cloudFileView  animated:YES];
        }else{
            FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
            if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
                //  [selectedItemsDic setObject:cell.fileinfo.fileName forKey:cell.fileinfo];
            }
        }
    }else{
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
        
        if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
            [selectedItemsDic setObject:cell.fileinfo forKey:cell.fileinfo.fileName];
            [self setFooterButtonState]; //更新按钮的状态
            if (tableDataDic.count>0 && selectedItemsDic.count == tableDataDic.count) {
                isCheckedAll = YES;
                UIImage *image = [UIImage imageNamed:@"checbox"];
                self.item1.selectedImage = image;
                self.tabbar.selectedItem = self.item1;
            }
            
        }
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
    if(cell && [[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName]){
        [selectedItemsDic removeObjectForKey:cell.fileinfo.fileName];
        [self setFooterButtonState]; //更新按钮的状态
        isCheckedAll = NO;
        self.tabbar.selectedItem = nil;
        UIImage *image = [UIImage imageNamed:@"checkbox-down"];
        self.item1.image = image;
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
    self.tabbar.selectedItem = nil;
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
            NSInteger index1 = [tableDataDic count];
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
                        
                        NSArray *videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                                               @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
                        BOOL isVideo = [videoArray containsObject:[fileInfo.fileSubtype lowercaseString]];
                        NSArray *picArray=  [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg", nil];
                        BOOL isPic = [picArray containsObject:[fileInfo.fileSubtype lowercaseString]];
                        
                        if (isPic) {
                            NSMutableString *picUrl = [NSMutableString stringWithFormat:@"http://%@/%@",[g_sDataManager requestHost],REQUEST_PIC_URL];
                            picUrl =[NSMutableString stringWithFormat:@"%@?uname=%@&filePath=%@&fileName=%@",picUrl,[[g_sDataManager userName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.cpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileInfo.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                            [pics addObject:picUrl];
                        } else if (isVideo) {//视频文件
                            
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
            [self sortWithIndex:0];
            
            [self.fileListTableView reloadData];
        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"200"]){
            self.isServerSessionTimeOut = YES;
            [UIHelper showLoginViewWithServerSessionTimeOut:self ];
            
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

//返回的数据进行排序(共享文件等不参与排序)
- (void)sortWithIndex:(NSInteger)index
{
    
    NSMutableArray *folderArray = [NSMutableArray array];
    NSMutableArray *fileArray = [NSMutableArray array];
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    //遍历tableDataDic中的文件，将特殊文件、文件夹和文件分别存到不同的数组中
    for (int i = 0; i < tableDataDic.count; i++) {
        FileInfo *file = (FileInfo *)[tableDataDic objectForKey:[NSString stringWithFormat:@"%zi", i]];
        NSString *cpath = [self.cpath stringByAppendingPathComponent: file.fileName];
        if([cpath isEqualToString:[@"/" stringByAppendingPathComponent: SHARE_FOLDER]] || [cpath isEqualToString:[@"/" stringByAppendingPathComponent: USB_FOLDER]] || [cpath isEqualToString:[@"/" stringByAppendingPathComponent: CAMERA_FOLDER]]|| [cpath isEqualToString:[@"/" stringByAppendingPathComponent: PUBLIC_FOLDER]]){
            
            //将特殊文件夹添加到临时数组，不进行排序
            [tmpArray addObject:file];
        }else if ([file.fileSubtype isEqualToString:@"folder"]) {
            [folderArray addObject:file];
        }else {
            [fileArray addObject:file];
        }
        
    }
    //根据文件名进行排序
    //    NSSortDescriptor *Desc = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES];
    //根据修改时间进行排序
    NSSortDescriptor *Desc = [NSSortDescriptor sortDescriptorWithKey:@"fileChangeTime" ascending:YES];
    NSArray *descriptorArray = [NSArray arrayWithObjects:Desc, nil];
    
    //分别对文件夹和文件进行排序
    NSArray *sortedfolderArray = [folderArray sortedArrayUsingDescriptors: descriptorArray];
    NSArray *sortedfileArray = [fileArray sortedArrayUsingDescriptors: descriptorArray];
    
    //将文件数组拼接在文件夹数组后面
    NSMutableArray *array = [tmpArray arrayByAddingObjectsFromArray:sortedfolderArray];
    NSMutableArray *array1 = [array arrayByAddingObjectsFromArray:sortedfileArray];
    
    //将排序后的文件存放到tableDataDic中
    for (int i = index ; i < array1.count; i++) {
        
        FileInfo *file = (FileInfo *)array1[i];
        [tableDataDic setObject:file forKey:[NSString stringWithFormat:@"%zi", i]];
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
    }
    for (NSString *keys in [tableDataDic allKeys]){
        FileInfo *fileinfo = (FileInfo *)[tableDataDic valueForKey:keys];
        if(  !([[selectedItemsDic allKeys] containsObject:fileinfo.fileName])){
            [selectedItemsDic setObject:fileinfo forKey:fileinfo.fileName];
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
    }
    [selectedItemsDic removeAllObjects];
    [self setFooterButtonState]; //更新按钮的状态
    isCheckedAll = NO;
    self.tabbar.selectedItem = nil;
    UIImage *image = [UIImage imageNamed:@"checkbox-down"];
    self.item1.image = image;
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
    //防止以后支持批量上传 预留数组形式
    NSMutableDictionary* selectedFilesDic = [[NSMutableDictionary alloc] init];
    [selectedFilesDic setObject:fileDialog.selectedFile forKey:fileDialog.selectedFile];
    
    //NSMutableString *fileName=fileDialog.selectedFile;
    NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"/%@",[g_sDataManager userName]];
    if (![self.cpath isEqualToString:@"/"]) {
        [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",self.cpath]];
    }
    //    //服务器端重名文件判断
    //    //1.先判断队列中是否已有该文件
    for(FileUploadByBlockOperation *operation in [NSOperationUploadQueue sharedInstance].operations) {
        NSString *fileName = operation.taskInfo.fileName;
        if ([selectedFilesDic objectForKey:fileName] && [uploadUrl isEqualToString:operation.taskInfo.serverPath]) { //如果当前上传队列中包含该文件，且该文件的目标路径和当前操作要上传到的目标路径相同
            [selectedFilesDic removeObjectForKey:fileName];
        }
    }
    //2.再判断未完成已取消任务中是否有该文件
    for(NSString *taskId in [[ProgressBarViewController sharedInstance].uploadTaskDic allKeys] ){
        TaskInfo *taskInfo = [[ProgressBarViewController sharedInstance].uploadTaskDic objectForKey:taskId];
        for (NSString *fileNamePath in [selectedFilesDic allKeys]) {
            if (([taskInfo.taskName isEqualToString:[fileNamePath lastPathComponent]] && [uploadUrl isEqualToString:taskInfo.serverPath]) && ([taskInfo.taskStatus isEqualToString:CANCLED]|| [taskInfo.taskStatus isEqualToString:FAILURE])) {
                [selectedFilesDic removeObjectForKey:fileNamePath];
            }
        }
    }
    [duplicateFileNamesArray removeAllObjects];
    //3.判断是否服务器端目标路径下已经包含一个同名的文件
    for (NSString *selectedFileName in [selectedFilesDic allKeys]) {
        NSString *fileName = [selectedFileName lastPathComponent];
        //if ([fileDialog.filesDic objectForKey:fileName]) {
        
        //遍历tableDataDic 和 duplicateFileNamesArray中的文件
        for (int i = 0; i < tableDataDic.count; i++) {
            FileInfo *file = (FileInfo *)[tableDataDic objectForKey:[NSString stringWithFormat:@"%zi", i]];
            for (NSString *selectedFilePath in [selectedFilesDic allKeys]){
                NSString *selectedFileName = [selectedFilePath lastPathComponent];
                if ([file.fileName isEqualToString:selectedFileName]) {
                    [duplicateFileNamesArray addObject:fileName ];
                }
            }
        }
    }
    if(duplicateFileNamesArray.count>0){//如果目标路径下包含重名的文件，提示用户是否需要覆盖
        [self launchDialog:duplicateFileNamesArray];
    }else{
        for (NSString *selectedFilePath in [selectedFilesDic allKeys]){
            NSString *selectedFileName = [selectedFilePath lastPathComponent];
            [fileHandler uploadFileWithHttp:[NSOperationUploadQueue sharedInstance] fileName:selectedFileName localFilePath:fileDialog.cpath serverCpath:self.cpath];
        }
        
        [ProgressBarViewController sharedInstance].progressType = @"upload";
        [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
    }
    
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
        self.tabbar.selectedItem = nil;
        UIImage *image1 = [UIImage imageNamed:@"checkbox-down"];
        UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
        UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
        UIImage *image4 = [UIImage imageNamed:@"more"];
        
        self.item1.image = image1;
        self.item1.enabled = YES;
        self.item1.title = @"全选";
        
        self.item2.image = image2;
        self.item2.enabled = NO;
        self.item2.title = @"下载";
        
        self.item3.image = image3;
        self.item3.enabled = NO;
        self.item3.title = @"共享";
        
        self.item4.image = image4;
        self.item4.title = @"更多";
        
    }else{
        self.moreBar.hidden = YES;
        self.misButton.hidden = YES;
        currentModel =0;
        self.fileListTableView.allowsMultipleSelectionDuringEditing=NO;
        [self.fileListTableView setEditing:NO animated:YES];
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        [selectedItemsDic removeAllObjects];
        self.tabbar.selectedItem = nil;
        UIImage *image1 = [UIImage imageNamed:@"home"];
        UIImage *image2 = [UIImage imageNamed:@"upload"];
        UIImage *image3 = [UIImage imageNamed:@"refurbish"];
        UIImage *image4 = [UIImage imageNamed:@"new-folder"];
        
        self.item1.image = image1;
        self.item1.enabled = YES;
        self.item1.title = @"首页";
        
        self.item2.image = image2;
        self.item2.enabled = YES;
        self.item2.title = @"上传";
        
        self.item3.image = image3;
        self.item3.enabled = YES;
        self.item3.title = @"刷新";
        
        self.item4.image = image4;
        self.item4.title = @"新建目录";
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止复制！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        NSString *fileName;
        BOOL isSpecialName =NO;
        if(selectedItemsDic.count>0){
            for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
                if (fileNameTmp) {
                    if([ValidateTool isEqualToKeyword:fileNameTmp]){
                        fileName = fileNameTmp;
                        isSpecialName = YES;
                        break;
                    }
                }
            }
        }
        if(isSpecialName){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"“%@”禁止复制操作，请重新选择！",fileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        
        opType=2;
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = YES;
        fileDialog.cpath =@"/";
        fileDialog.fileDialogDelegate = self;
        fileDialog.onType = 3;
        [self.navigationController pushViewController:fileDialog animated:YES];
    }else if(buttonIndex==2){//移动
        [sheet dismissSheet:self];
        
        if([ValidateTool isInKeywordFolder:self.cpath]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止移动！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        NSString *errorFileName;
        BOOL isSpecialName =NO;
        BOOL isSharedFolder = NO;
        if(selectedItemsDic.count>0){
            for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
                if (fileNameTmp) {
                    if([ValidateTool isEqualToKeyword:fileNameTmp]){
                        errorFileName = fileNameTmp;
                        isSpecialName = YES;
                        break;
                    }
                }
            }
        }
        if(isSpecialName){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"“%@”禁止移动操作，请重新选择！",errorFileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        for (NSString *key in [tableDataDic allKeys]){
            if (key) {
                FileInfo *fileInfo = (FileInfo *)[tableDataDic objectForKey:key];
                if([fileInfo.isShare isEqualToString:@"1"]){
                    for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
                        if (fileNameTmp) {
                            if([fileNameTmp isEqualToString: fileInfo.fileName]){
                                isSharedFolder =YES;
                                errorFileName = fileNameTmp;
                                break;
                            }
                        }
                    }
                }
            }
        }
        if(errorFileName && isSharedFolder){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"“%@”已被共享，禁止移动操作，请重新选择！",errorFileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        opType=1;
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = YES;
        fileDialog.cpath =@"/";
        fileDialog.fileDialogDelegate = self;
        fileDialog.onType = 4;
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"“%@”禁止重命名操作，请重新选择！",fileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        for (NSString *key in [tableDataDic allKeys]){
            if (key) {
                FileInfo *fileInfo = (FileInfo *)[tableDataDic objectForKey:key];
                if([fileInfo.isShare isEqualToString:@"1"] && [fileInfo.fileName isEqualToString:fileName]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"“%@”已被共享，禁止重命名操作，请重新选择！",fileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alert show];
                    return;
                }
            }
        }
        fileHandler.cpath = self.cpath;
        fileHandler.opType =5;
        fileHandler.selectedFileName =fileName;
        fileHandler.tableDataDic = tableDataDic;
        [fileHandler renameFile :fileName alertViewDelegate:fileHandler];
        
    }else if(buttonIndex==4){//删除
        if([ValidateTool isInKeywordFolder:self.cpath]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止删除！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        NSString *errorFileName;
        BOOL isSpecialName =NO;
        BOOL isSharedFolder = NO;
        if(selectedItemsDic.count>0){
            for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
                if (fileNameTmp) {
                    if([ValidateTool isEqualToKeyword:fileNameTmp]){
                        errorFileName = fileNameTmp;
                        isSpecialName = YES;
                        break;
                    }
                }
            }
        }
        if(isSpecialName){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"“%@”禁止删除操作，请重新选择！",errorFileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        for (NSString *key in [tableDataDic allKeys]){
            if (key) {
                FileInfo *fileInfo = (FileInfo *)[tableDataDic objectForKey:key];
                if([fileInfo.isShare isEqualToString:@"1"]){
                    for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
                        if (fileNameTmp) {
                            if([fileNameTmp isEqualToString: fileInfo.fileName]){
                                isSharedFolder =YES;
                                errorFileName = fileNameTmp;
                                break;
                            }
                        }
                    }
                }
            }
        }
        if(errorFileName && isSharedFolder){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"文件“%@”已被共享，禁止删除操作，请重新选择！",errorFileName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alert show];
            return;
        }
        
        //        if(self.isInSharedFolder){
        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"被共享文件夹下禁止删除！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        //            [alert show];
        //            return;
        //        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定要删除选中文件吗?" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
        [alertView show];
        
    }
}

#pragma mark -
#pragma mark setFooterButtonState 设置底部按钮的状态
- (void)setFooterButtonState{
    if(selectedItemsDic.count>0){
        BOOL isContainFoler = NO;
        
        NSString *specialFolderName = [[NSString alloc] init];
        for (NSString *fileName in [selectedItemsDic allKeys]){
            if (fileName) {
                FileInfo *fileInfo = (FileInfo*) [selectedItemsDic objectForKey:fileName];
                if ([fileInfo.fileType isEqualToString:@"folder"]) {
                    isContainFoler = YES;
                }
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
            self.item2.image = image2;
            self.item2.enabled = YES;
            
            UIImage *image3 = [UIImage imageNamed:@"share"];
            self.item3.image = image3;
            self.item3.enabled = YES;
            
        }else{
            UIImage *image2 = [UIImage imageNamed:@"download"];
            self.item2.image = image2;
            self.item2.enabled = YES;
            
            UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
            self.item3.image = image3;
            self.item3.enabled = NO;
            
        }
    }else{
        if (self.fileListTableView.allowsMultipleSelectionDuringEditing){
            
            UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
            UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
            self.item1.image = [UIImage imageNamed:@"checkbox-down"];
            self.item2.image = image2;
            self.item2.enabled = NO;
            
            self.item3.image = image3;
            self.item3.enabled = NO;
        }else{
            UIImage *image2 = [UIImage imageNamed:@"upload"];
            UIImage *image3 = [UIImage imageNamed:@"refurbish"];
            self.item2.image = image2;
            self.item2.enabled = YES;
            
            self.item3.image = image3;
            self.item3.enabled = YES;
        }
    }
}


#pragma mark -
#pragma mark footerButtonEventHandleAction 底部按钮点击处理事件
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if (tabBar == self.tabbar) {
        
        if(currentModel == 0){//正常模式下的处理
            if (item == self.item1){//首页
                self.item1.selectedImage = [UIImage imageNamed:@"home"];
                DeckTableViewController* leftController = [[DeckTableViewController alloc] initWithNibName:@"DeckTableViewController" bundle:nil];
                leftController = [[UINavigationController alloc] initWithRootViewController:leftController];
                
                UIViewController *centerController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                
                centerController = [[UINavigationController alloc] initWithRootViewController:centerController];
                
                IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController leftViewController:leftController];
                
                deckController.delegateMode = IIViewDeckDelegateOnly;
                [self presentViewController:deckController animated:NO completion:nil];
                
            }else if(item == self.item2){//上传
                
                if([ValidateTool isInKeywordFolder:self.cpath]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止上传！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alert show];
                    return;
                }
                opType =8;
                fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
                fileDialog.isShowFile =YES;
                fileDialog.isServerFile = NO;
                fileDialog.isSelectFileMode = YES;
                fileDialog.fileDialogDelegate = self;
                NSString* documentsPath = kDocument_Folder;
                fileDialog.cpath = documentsPath;
                fileDialog.rootUrl = documentsPath;
                fileDialog.title = @"本地文件";
                fileDialog.onType = 2;
                
                self.item2.selectedImage = [UIImage imageNamed:@"upload"];
                
                [self.navigationController pushViewController:fileDialog animated:YES];
                
                
                
            }else if(item == self.item3) {//刷新
                
                [self requestFileData:YES refreshControl:nil];
                
            }else if(item == self.item4){//新建文件夹
                self.tabbar.selectedItem = nil;
                if([ValidateTool isInKeywordFolder:self.cpath]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下禁止新建文件夹！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alert show];
                    return;
                }
                
                //                if(self.isInSharedFolder) {
                //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"被共享文件夹下禁止新建文件夹！" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                //                    [alert show];
                //                    return;
                //                }else {
                opType =4;
                fileHandler.opType = 4;
                fileHandler.cpath =self.cpath;
                [fileHandler createFolder:fileHandler];
                //                }
            }
        }else if(currentModel == 1){//编辑模式下的处理
            if(item == self.item1){ //全选
                isCheckedAll = !isCheckedAll;
                if (isCheckedAll) {
                    [self selectAllRows];
                    self.item1.selectedImage = [UIImage imageNamed:@"checbox"];
                }else{
                    [self didDeSelectAllRows];
                    self.tabbar.selectedItem = nil;
                    self.item1.selectedImage = [UIImage imageNamed:@"checkbox-down"];
                }
            }else if(item == self.item2){//下载
                BOOL isContainFoler = NO;
                opType =7;
                self.item2.selectedImage = [UIImage imageNamed:@"download"];
                for (NSString *fileName in [selectedItemsDic allKeys]){
                    if (fileName) {
                        FileInfo *fileInfo = (FileInfo*) [selectedItemsDic objectForKey:fileName];
                        if ([fileInfo.fileType isEqualToString:@"folder"]) {
                            isContainFoler = YES;
                        }
                    }
                }
                if(!isContainFoler){ //下载文件的处理
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
                        [fileHandler downloadFiles:[NSOperationDownloadQueue sharedInstance] selectedItemsDic:selectedItemsDic cpath:self.cpath cachePath:targetPath];
                        [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                        [selectedItemsDic removeAllObjects];
                    }
                }else{//下载目录的处理
                    NSMutableArray *dirsArray = [[NSMutableArray alloc]init];
                    NSMutableArray *filesArray = [[NSMutableArray alloc]init];
                    for (NSString *fileName in [selectedItemsDic allKeys])
                    {
                        FileInfo *fileInfo = (FileInfo*) [selectedItemsDic objectForKey:fileName];
                        if([fileInfo.fileType isEqualToString:@"folder"]){
                            [dirsArray addObject:fileName];
                        }else if([fileInfo.fileType isEqualToString:@"file"]){
                            fileInfo.fileUrl = [self.cpath stringByAppendingPathComponent: fileInfo.fileName];
                            [filesArray addObject:fileInfo];
                        }
                        
                    }
                    NSString *targetPath =[kDocument_Folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[g_sDataManager userName]]];
                    DirsHandler *dirsHandler = [[DirsHandler alloc]init:dirsArray filesArray:filesArray cloundCurrentDir:self.cpath targetDir:targetPath];
                    [dirsHandler dirsHandle];
                    
                }
                
            }else if(item == self.item3){//共享
                
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"路径“%@”下文件夹禁止共享！",self.cpath] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
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
            }else if(item == self.item4){//更多
                self.misButton.hidden = NO;
                self.moreBar.hidden = NO;
                self.tabbar.selectedItem = nil;
                if (selectedItemsDic.count == 0) {
                    
                    [self setItemState:1 itemState:NO];
                    [self setItemState:2 itemState:NO];
                    [self setItemState:3 itemState:NO];
                    [self setItemState:4 itemState:NO];
                    
                }else if(selectedItemsDic.count == 1) {
                    
                    [self setItemState:1 itemState:YES];
                    [self setItemState:2 itemState:YES];
                    [self setItemState:3 itemState:YES];
                    [self setItemState:4 itemState:YES];
                    
                }else if(selectedItemsDic.count >= 2) {
                    
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
    
    [self setFooterButtonState];
    
}

- (IBAction)moreBarMiss:(id)sender {
    self.moreBar.hidden = YES;
    self.tabbar.selectedItem = nil;
    [self setFooterButtonState];
    self.misButton.hidden = YES;
    
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




#pragma mark -
#pragma mark FileHandler 的代理方法
- (void)requestSuccessCallback{
    [self loadFileData];
    [selectedItemsDic removeAllObjects];
    if (self.moreBar.hidden == NO) {
        self.moreBar.hidden = YES;
    }
    if (loadingView)
    {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
    [self setFooterButtonState];
}

- (void)sessionTimeOutCallback{
    //[self loadFileData];
    self.isServerSessionTimeOut =YES;
    [selectedItemsDic removeAllObjects];
    if (self.moreBar.hidden == NO) {
        self.moreBar.hidden = YES;
    }
    if (loadingView)
    {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
    [self setFooterButtonState];
    
    [UIHelper showLoginViewWithServerSessionTimeOut:self ];
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
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                
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

- (void)openAlert:(UITapGestureRecognizer *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"当前文件不支持远程打开，请下载到本地打开" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
    [alert show];
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


-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==0){//删除文件
        [fileHandler deleteFiles:selectedItemsDic cpath:self.cpath];
        [selectedItemsDic removeAllObjects];
        [self setFooterButtonState];
    }
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if(buttonIndex==0){//按下确定按钮
        
        if(opType == 7){
            NSString *targetPath = [kDocument_Folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[g_sDataManager userName]]];
            if (tableViewDelegate.selectedFileNamesDic.count>0) {
                for (int i=0; i<duplicateFileNamesArray.count; i++) {
                    if ([tableViewDelegate.selectedFileNamesDic objectForKey:duplicateFileNamesArray[i]]==nil) {
                        [selectedItemsDic removeObjectForKey:duplicateFileNamesArray[i]];
                    }
                }
                [fileHandler downloadFiles:[NSOperationDownloadQueue sharedInstance] selectedItemsDic:selectedItemsDic cpath:self.cpath cachePath:targetPath];
                [ProgressBarViewController sharedInstance].progressType = @"download";
                [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                [selectedItemsDic removeAllObjects];
            }
        }else if(opType == 8){
            //防止以后支持批量上传 预留数组形式
            NSMutableDictionary* selectedFilesDic = [[NSMutableDictionary alloc] init];
            [selectedFilesDic setObject:fileDialog.selectedFile forKey:fileDialog.selectedFile];
            
            NSString* cpath = self.cpath;
            NSString* localFilePath = fileDialog.cpath;
            
            if (tableViewDelegate.selectedFileNamesDic.count>0) {
                for (int i=0; i<duplicateFileNamesArray.count; i++) {
                    if ([tableViewDelegate.selectedFileNamesDic objectForKey:duplicateFileNamesArray[i]]==nil) {
                        [selectedFilesDic removeObjectForKey:duplicateFileNamesArray[i]];
                    }
                }
                if(selectedFilesDic.count >0){
                    [fileHandler uploadFileWithHttp:[NSOperationUploadQueue sharedInstance] fileName:[selectedFilesDic objectForKey:fileDialog.selectedFile] localFilePath:localFilePath serverCpath:cpath];
                    [ProgressBarViewController sharedInstance].progressType = @"upload";
                    [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                }
            }
        }
    }else{
        
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
