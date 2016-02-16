//
//  FileDialogViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/28.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "FileDialogViewController.h"
#import "FileInfo.h"
#import "FileTools.h"
#import "FDTableViewCell.h"
#import "UIHelper.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "ProgressBarViewController.h"
@interface FileDialogViewController ()
{
    NSMutableDictionary * tableDataDic;
    UIBarButtonItem *leftBtn;
    UIButton* rightBtn;
    UIView* loadingView;
}
@end

@implementation FileDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"确认返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(confirmReturnAction:)];
    [leftBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftBtn;
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 50, 50);
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    [self.returnLastDirBtn addTarget: self action: @selector(returnParentDirectoryAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.returnRootDirBtn addTarget: self action: @selector(returnRootDirectoryAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.fileListTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线
    self.filesDic = [[NSMutableDictionary alloc]init];
    self.dirsDic = [[NSMutableDictionary alloc]init];
    [self loadFileData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadFileData
{
    self.selectedFile = @"";
    tableDataDic = [[NSMutableDictionary alloc] init];
    //1.如果是选择本地文件夹，则直接从根目录下开始展示
    if (!self.isServerFile) {
        NSString* documentsPath= @"";
        if(self.cpath!=nil && [self.cpath length]>0)
        {
            documentsPath =self.cpath;
            NSLog(@"documentsPath=%@",documentsPath);
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
        if(!self.isServerFile) //
        {
            tableDataDic=[FileTools getAllFiles:documentsPath skipDescendents:YES isShowAlbum:NO];
        }
        [self.fileListTableView reloadData];
    }else if(self.isServerFile){//2.如果是选择服务器端文件夹，则需要发送请求到服务器端
        self.rootUrl = @"/";
        [self requestFileData];
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
    FDTableViewCell *cell = (FDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:fileinfo.fileName];
    if (cell == nil) {
        cell = [[FDTableViewCell alloc] initWithFile:fileinfo];
    }
  
    cell.fileinfo = fileinfo;
    [cell setDetailText];
    cell.textLabel.text = fileinfo.fileName;
    return cell;

}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}
//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableDataDic.count;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileInfo *fileinfo = (FileInfo *)[tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    if (self.isSelectFileMode && ![fileinfo.fileType isEqualToString:@"folder"]) {// 如果是当前模式是选择文件
        self.selectedFile = fileinfo.fileName;
    }else{
        if (!self.isServerFile) { // 如果是文件夹的时候，进入下一级文件夹
            if ([fileinfo.fileType isEqualToString:@"folder"] )
            {
                if (tableDataDic != nil) {
                    [tableDataDic removeAllObjects];
                }
                self.cpath = [self.cpath stringByAppendingPathComponent:fileinfo.fileName];
                tableDataDic=[FileTools getAllFiles:self.cpath skipDescendents:YES isShowAlbum:NO];
                self.selectedFile=@"";
                [self.fileListTableView reloadData];
                
            }
        }else{
            if ([fileinfo.fileType isEqualToString:@"folder"] )
            {
                self.cpath =[self.cpath stringByAppendingPathComponent:fileinfo.fileName];
                NSLog(@"%@",self.cpath);
                [self requestFileData];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
//UITableViewDelegate协议中的方法
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark -
#pragma mark returnParentDirectoryAction 返回上一级目录
-(void)returnParentDirectoryAction:(id)sender {
    if ([self.cpath isEqualToString:self.rootUrl]) {
        return;
    }
    if (!self.isServerFile) {
        if(self.cpath && ![self.cpath isEqualToString:self.rootUrl])
        {
            NSMutableArray* pathArray = (NSMutableArray*)[self.cpath pathComponents];
            if (pathArray && [pathArray count]>0) {
                [pathArray removeLastObject];
            }
            if (pathArray && [pathArray count]>=2) {
                self.cpath =  [NSString stringWithFormat:@"%@%@",pathArray[0],pathArray[1]];
                for (int i=2; i<[pathArray count]; i++) {
                    self.cpath = [NSString stringWithFormat:@"%@/%@", self.cpath,pathArray[i]];
                }
            }
            else if(pathArray && [pathArray count]==1){
                self.cpath =  pathArray[0];
            }else{
                self.cpath =  self.rootUrl;
            }

            if (tableDataDic != nil) {
                [tableDataDic removeAllObjects];
            }
            tableDataDic=[FileTools getAllFiles:self.cpath skipDescendents:YES isShowAlbum:NO];
            self.selectedFile=@"";
            [self.fileListTableView reloadData];
        }
    }else{
        if(self.cpath && ![self.cpath isEqualToString:self.rootUrl])
        {
            NSMutableArray* pathArray = (NSMutableArray*)[self.cpath pathComponents];
            if (pathArray && [pathArray count]>0) {
                [pathArray removeLastObject];
            }
            if (pathArray && [pathArray count]>=2) {
                self.cpath =  [NSString stringWithFormat:@"%@%@",pathArray[0],pathArray[1]];
                for (int i=2; i<[pathArray count]; i++) {
                    self.cpath = [NSString stringWithFormat:@"%@/%@", self.cpath,pathArray[i]];
                }
                [self requestFileData];
            }else if(pathArray && [pathArray count]==1){
                self.cpath =  pathArray[0];
                [self requestFileData];
            }else{
                self.cpath =  @"/";
                [self requestFileData];
            }
        }
    }
}

#pragma mark -
#pragma mark returnRootDirectoryAction 返回根目录
-(void)returnRootDirectoryAction:(id)sender {
    self.selectedFile=@"";
    if (!self.isServerFile) {
        NSString* documentsPath = kDocument_Folder;
        self.cpath = documentsPath;
        if(self.cpath)
        {
            tableDataDic=[FileTools getAllFiles:self.cpath skipDescendents:YES isShowAlbum:NO];
            [self.fileListTableView reloadData];
        }
    }else{
        self.cpath=@"/";
        if(self.cpath)
        {
            [self requestFileData];
        }
    }
}
#pragma mark -
#pragma mark confirmReturnAciton 确认返回按钮的事件
- (void)confirmReturnAction:(UIBarButtonItem *)sender
{
    if(self.isSelectFileMode)
    {
        if([self.selectedFile isEqualToString:@""])
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择文件！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
        if ([self.fileDialogDelegate respondsToSelector:@selector(chooseFileAction:)]) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.fileDialogDelegate chooseFileAction:nil];//调用委托方法
           // [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }else{
        if ([self.fileDialogDelegate respondsToSelector:@selector(chooseFileDirAction:)]) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.fileDialogDelegate chooseFileDirAction:nil];//调用委托方法
        }
    }

}
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark requestFileData 返回dirPath下的所有文件
-(void)requestFileData
{
    self.selectedFile=@"";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
    [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
    if (self.cpath && [self.cpath length]>0) {
        [dic setValue:self.cpath forKey:@"cpath"];
    }
 
    if (tableDataDic != nil) {
        [tableDataDic removeAllObjects];
    }
    if (self.filesDic!=nil) {
        [self.filesDic removeAllObjects];
    }
    if (self.dirsDic!=nil) {
        [self.dirsDic removeAllObjects];
    }
    loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在获取目录" ];
    // Reachability
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_FETCH_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"1"])//获取目录成功
        {
            NSLog(@"responseJSON====%@",responseJSON);
            NSArray *responseJSONResult=responseJSON[@"result"];
            if([responseJSONResult isEqual:@"file not exit"]){
                if (loadingView)
                {
                    [loadingView removeFromSuperview];
                    loadingView = nil;
                }
                return;
            }
            //先取文件夹
            [responseJSONResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                if (responseJSONResult && responseJSONResult.count>0) {
                    
                    FileInfo *fileInfo = [[FileInfo alloc] init];
                    fileInfo.fileName = dict[ @"fileName"];
                    fileInfo.fileSize = [FileTools  convertFileSize: dict[@"fileSize"]];
                    fileInfo.fileChangeTime = dict[ @"fileChangeTime"];
                    fileInfo.fileType = dict[ @"fileType"];
                    if([fileInfo.fileType isEqualToString:@"folder"])
                    {
                        fileInfo.fileSubtype =@"folder";
                        fileInfo.isShare = dict[ @"isShare"];
                        [tableDataDic setObject:fileInfo forKey:[NSString stringWithFormat:@"%zi", [tableDataDic count]]];
                        [self.dirsDic setObject:fileInfo.fileName forKey:fileInfo.fileName];
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
                    fileInfo.fileSize = [FileTools  convertFileSize: dict[@"fileSize"]];
                    fileInfo.fileChangeTime = dict[@"fileChangeTime"];
                    fileInfo.fileType = dict[@"fileType"];
                    if([fileInfo.fileType isEqualToString:@"file"])
                    {
                        fileInfo.fileSubtype =[fileInfo.fileName pathExtension];
                        if (!fileInfo.fileSubtype || [fileInfo.fileSubtype isEqualToString:@""]) {
                            fileInfo.fileSubtype=@"";
                        }
                        fileInfo.isShare = dict[@"isShare"];
                        [tableDataDic setObject:fileInfo forKey:[NSString stringWithFormat:@"%zi", index]];
                        [self.filesDic setObject:fileInfo.fileName forKey:fileInfo.fileName];
                        index++;
                    }
                }else{
                    *stop = YES;
                }
                
            }];
            [self.fileListTableView reloadData];
        }
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        if (loadingView)
        {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
    }];
    [engine enqueueOperation:op];
}
@end
