//
//  DocumentViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/26.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "DocumentViewController.h"
#import "FileInfo.h"
#import "FileTools.h"
#import "FDTableViewCell.h"
#import "UIHelper.h"
#import "UploadFileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "UIHelper.h"

#define AU_Cell_Height 52

@interface DocumentViewController ()
{
    UIButton* rightBtn;
    UIBarButtonItem *leftBtn;
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名
    FileDialogViewController *fileDialog;
}

@end

@implementation DocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.docDataDict = [[NSMutableDictionary alloc]init];
    [self loadFileData];
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
    //去掉tableView分割线左边短15像素
    if ([self.docTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.docTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.docTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.docTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.docTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    CGSize screenSize = [UIHelper getScreenSize];
    float width =screenSize.width;
    //底部按钮的添加
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [uploadBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    UIBarButtonItem *uploadBtnItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    [uploadBtn addTarget: self action: @selector(uploadFiles:) forControlEvents: UIControlEventTouchUpInside];
    UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    delBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn addTarget: self action: @selector(deleteFiles:) forControlEvents: UIControlEventTouchUpInside];
    [delBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    UIBarButtonItem *delBtnItem = [[UIBarButtonItem alloc] initWithCustomView:delBtn];
    UIBarButtonItem *space= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44.0, width, 44.0)];
    [toolBar setBarStyle:UIBarStyleDefault];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [toolBar setItems:@[uploadBtnItem,space,delBtnItem]];
    [self.view addSubview:toolBar];
    selectedItemsDic = [[NSMutableDictionary alloc] init];
    //添加滑动手势
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.docDataDict.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileInfo *fileinfo = (FileInfo *)[self.docDataDict objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    FDTableViewCell *cell = (FDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:fileinfo.fileUrl];
    if (cell == nil) {
        cell = [[FDTableViewCell alloc] initWithFile:fileinfo];
    }
    cell.fileinfo = fileinfo;
    [cell setDetailText];
    cell.textLabel.text = fileinfo.fileName;
    
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accessoryButton.frame = CGRectMake(100,5,50,50);
    [accessoryButton setImage:[UIImage imageNamed:@"playBtn.jpg"] forState:UIControlStateNormal];
    [accessoryButton addTarget:self action:@selector(accessoryButtonIsTapped:event:)forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.docTableView cellForRowAtIndexPath:indexPath];
    if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl])){
        [selectedItemsDic setObject:cell.fileinfo.fileUrl forKey:cell.fileinfo.fileUrl];
        
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.docTableView cellForRowAtIndexPath:indexPath];
    if(cell){
        [selectedItemsDic removeObjectForKey:cell.fileinfo.fileUrl];
        
    }
}

//加载本地文件数据
- (void)loadFileData
{
    NSString* documentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"/Documents"];
    self.docDataDict =  [FileTools getAllFilesByType:documentsPath skipDescendents:true fileExtend:@[@"doc",@"docx",@"xls",@"xlsx",@"dmg"]];
    [self.docTableView reloadData];
    
}
#pragma mark -
#pragma mark switchTableViewModel 设置TableView的状态（可选、不可选）
- (void)switchTableViewModel:(UIBarButtonItem *)sender {
    self.docTableView.allowsMultipleSelectionDuringEditing=!self.docTableView.allowsMultipleSelectionDuringEditing;
    if (self.docTableView.allowsMultipleSelectionDuringEditing) {
        self.docTableView.allowsMultipleSelectionDuringEditing=YES;
        [self.docTableView setEditing:YES animated:YES];
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"全选"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllRows:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }else{
        self.docTableView.allowsMultipleSelectionDuringEditing=NO;
        [self.docTableView setEditing:NO animated:YES];
        [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
        leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(returnAction:)];
        self.navigationItem.leftBarButtonItem = leftBtn;
        [selectedItemsDic removeAllObjects];
        
    }
    
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark selectAllRows 设置TableView的全选
- (void) selectAllRows:(id)sender{
    for (int row=0; row<self.docDataDict.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.docTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView :self.docTableView didSelectRowAtIndexPath:indexPath];
    }
}

//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}

- (void)accessoryButtonIsTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.docTableView];
    NSIndexPath *indexPath = [self.docTableView indexPathForRowAtPoint:currentTouchPosition];
    
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.docTableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath != nil)
    {
        NSFileManager *fileManager =[NSFileManager defaultManager];
        
        NSString *docPath = cell.fileinfo.fileUrl;
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


#pragma mark -
#pragma mark uploadFiles 上传本地文件的方法
- (void) uploadFiles:(id)sender{
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
    }else{
        if (selectedItemsDic.count>0) {
            fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
            fileDialog.isShowFile =YES;
            fileDialog.isServerFile = YES;
            fileDialog.cpath =@"/";
            fileDialog.isSelectFileMode =NO;
            fileDialog.fileDialogDelegate = self;
            [self.navigationController pushViewController:fileDialog animated:YES];
            
        }
    }
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
    }
}
#pragma mark -
#pragma mark deleteFiles 删除本地文件的方法
- (void) deleteFiles:(id)sender{
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
#pragma mark chooseFileDirAction的委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
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
    
    NSArray *keys = [selectedItemsDic allKeys];
    for (int i =0; i<[selectedItemsDic count]; i++) {
        NSString *firstKey = [keys objectAtIndex:i];
        UploadFileTools * ud = [[UploadFileTools alloc] initWithLocalPath:[firstKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  withServer:uploadUrl withName:FTP_USERNAME withPass:FTP_PASSWORD];
        
        TaskInfo* task = [[TaskInfo alloc] init];
        task.taskId = [NSUUIDTool gen_uuid];
        task.taskName =firstKey;
        task.taskType = @"上传";
        ud.taskId =  task.taskId;
        [[ProgressBarViewController sharedInstance].taskDic setObject:task forKey:task.taskId];
        [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
        [ud start];
    }
    [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
}

#pragma mark -
#pragma mark alertView的委托方法
-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [UIHelper showLoginView:self];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AU_Cell_Height;
}
@end
