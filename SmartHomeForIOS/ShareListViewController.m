//
//  ShareListViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/26.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "ShareListViewController.h"
#import "FileInfo.h"
#import "FileTools.h"
#import "FDTableViewCell.h"
#import "KxMenu.h"
#import "UIHelper.h"
#import "FileDownloadTools.h"
#import "UIButton+UIButtonExt.h"
#import "UserEditViewController.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "HomeViewController.h"
#import "FileHandler.h"
#define AU_Cell_Height 52

@interface ShareListViewController ()
{
    NSOperationQueue *downloadQueue;
    NSMutableDictionary * tableDataDic;
    UIButton *leftBtn;
    UIButton* rightBtn;
    UIView* loadingView;
    FileHandler *fileHandler;
    NSMutableDictionary* selectedItemsDic; //存储所有选中的行的文件名
    NSMutableArray* pics;
    
}
@property (weak, nonatomic) FDTableViewCell *curCel;
@end

@implementation ShareListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [rightBtn setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"下载" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(downloadAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    
    selectedItemsDic = [[NSMutableDictionary alloc] init];
    [self.fileListTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线
    [self.fileListTableView setSeparatorInset:UIEdgeInsetsZero]  ;
    [self loadFileData];
    downloadQueue = [[NSOperationQueue alloc] init];
    [downloadQueue setMaxConcurrentOperationCount:1];

    pics = [[NSMutableArray alloc]init];
    UIRefreshControl *control=[[UIRefreshControl alloc]init];
    [control addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.fileListTableView addSubview:control];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [selectedItemsDic removeAllObjects];
    [self requestFileData:NO refreshControl:nil];
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
    FDTableViewCell *cell = (FDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:fileinfo.fileName];
    if (cell == nil) {
        cell = [[FDTableViewCell alloc] initWithFile:fileinfo];
    }
    cell.fileinfo = fileinfo;
    [cell setDetailText];
    cell.textLabel.text = fileinfo.fileName;
    return cell;
}

//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableDataDic.count;
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileInfo *fileinfo = (FileInfo *)[tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
    if(cell && !([[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileName])){
        [selectedItemsDic setObject:cell.fileinfo.fileName forKey:cell.fileinfo.fileName];
    }

}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
    if(cell && [[selectedItemsDic allKeys] containsObject:cell.fileinfo.fileUrl]){
        [selectedItemsDic removeObjectForKey:cell.fileinfo.fileUrl];
    }
}
//UITableViewDelegate协议中的方法
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


#pragma mark -
#pragma mark returnAction 返回按钮
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}
#pragma mark -
#pragma mark downLoadAction 下载
- (void)downloadAction:(id *)sender {
    /*
    [fileHandler downloadFiles:downloadQueue selectedItemsDic:  selectedItemsDic cpath:self.cpath];
    [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
    [selectedItemsDic removeAllObjects];*/
}

#pragma mark -
#pragma mark requestFileData 返回dirPath下的所有文件
-(void)requestFileData:(BOOL) isShowLoading refreshControl:(UIRefreshControl *)control
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
    [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
    [dic setValue:@"1" forKey:@"getShare"];
//    if (self.cpath && [self.cpath length]>0) {
//        [dic setValue:@"1" forKey:@"getShare"];
//    }
//    
    if (tableDataDic != nil) {
        [tableDataDic removeAllObjects];
    }
    if(pics!=nil){
        [pics removeAllObjects];
    }
    if (isShowLoading) {
        loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在获取目录" ];
    }
    
    // Reachability
    
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%@",requestHost,REQUEST_GETSHARE_URL];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:@"" params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"1"])//获取目录成功
        {
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

            __block NSUInteger index =[tableDataDic count];
            //获取文件
            
            if(![responseJSONResult isEqual:[NSNull null]]){
                [responseJSONResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                    
                    if (responseJSONResult && responseJSONResult.count>0) {
                        FileInfo *fileInfo = [[FileInfo alloc] init];
                        fileInfo.fileName = dict[@"file_name"];
                        //fileInfo.fileSize = dict[@"file_size"];
                        fileInfo.fileId  = dict[@"file_id"];
                        fileInfo.fileChangeTime = dict[@"file_chtime"];
                        fileInfo.fileSubtype =[fileInfo.fileName pathExtension];
                        if (!fileInfo.fileSubtype || [fileInfo.fileSubtype isEqualToString:@""]) {
                            fileInfo.fileSubtype=@"";
                        }
    //                        if ([fileInfo.fileSubtype isEqualToString:@"jpg"] || [fileInfo.fileSubtype isEqualToString:@"png"]) {
    //                            NSMutableString *picUrl = [NSMutableString stringWithFormat:@"http://%@/%@",[g_sDataManager requestHost],REQUEST_PIC_URL];
    //                            picUrl =[NSMutableString stringWithFormat:@"%@?uname=%@&filePath=%@&fileName=%@",picUrl,[g_sDataManager userName],self.cpath,fileInfo.fileName];
    //                            [pics addObject:picUrl];
    //                        }
                        [tableDataDic setObject:fileInfo forKey:[NSString stringWithFormat:@"%zi", index]];
                        index++;
                    }
                }];
                
                [self.fileListTableView reloadData];
            }
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
        [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        
    }
}

- (void)refreshTableView:(UIRefreshControl *)control
{
    [self requestFileData:NO refreshControl:control];
}

#pragma mark -
#pragma mark UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AU_Cell_Height;
}

@end
