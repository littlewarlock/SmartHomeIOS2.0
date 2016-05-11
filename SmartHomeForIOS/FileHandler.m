//
//  FileHandler.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/11/4.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FileHandler.h"
#import "FileDownloadTools.h"
#import "UploadFileTools.h"
#import "NSUUIDTool.h"
#import "FileUploadByBlockOperation.h"
#import "FileDownloadOperation.h"
#import "NSOperationUploadQueue.h"
#import "FileInfo.h"
#import "ValidateTool.h"
#import "UIHelper.h"
@interface FileHandler ()
{
    NSString *fileName;
}
@end

@implementation FileHandler

- (id) init
{
    self = [super init];
    if (self) {
        self.condition = [[NSCondition alloc]init];
    }
    return self;
}

#pragma mark -
#pragma mark downloadFiles 下载文件的处理
/* 没有添加断点下载前的，下载处理
 - (void)downloadFiles:(NSOperationQueue *)downloadQueue selectedItemsDic: (NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath
 {
 BOOL  operationIsExist= false;
 for (NSString *fileName in [selectedItemsDic allKeys]){
 operationIsExist= false;
 for (FileDownloadTools *operation in [downloadQueue operations]) {
 if ([operation.fileName isEqualToString:fileName]) {
 operationIsExist = true;
 }
 }
 if (!operationIsExist) {
 FileDownloadTools *operation = [[FileDownloadTools alloc] initWithFileInfo];
 TaskInfo* task = [[TaskInfo alloc] init];
 task.taskId = [NSUUIDTool gen_uuid];
 task.taskName =fileName;
 task.taskType = @"下载";
 operation.fileName = fileName;
 operation.filePath = cpath;
 operation.progressBarView = [ProgressBarViewController sharedInstance];
 operation.taskId = task.taskId;
 [downloadQueue addOperation:operation];
 [[ProgressBarViewController sharedInstance].taskDic  setObject:task forKey:task.taskId];
 [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
 }
 }
 }*/

- (void)downloadFiles:(NSOperationDownloadQueue *)downloadQueue selectedItemsDic: (NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath cachePath:(NSString*)cachePath{
    for (NSString *fileName in [selectedItemsDic allKeys]){
        TaskInfo* taskInfo = [[TaskInfo alloc] init];
        taskInfo.taskId = [NSUUIDTool gen_uuid];
        taskInfo.taskName =fileName;
        taskInfo.taskType = @"下载";
        taskInfo.fileName = fileName;
        taskInfo.filePath = cpath;
        taskInfo.cachePath = [NSString stringWithFormat:@"%@/%@",cachePath,fileName];
        taskInfo.taskStatus = RUNNING;
        taskInfo.transferedBlocks = 0;
        taskInfo.totalBytes = [self getFileSize:cpath fileName:fileName];
        FileDownloadOperation *operation = [[FileDownloadOperation alloc] initWithTaskInfo:taskInfo];
        operation.taskId = taskInfo.taskId;
        operation.completionBlock = ^(void){ //如果是任务执行完成则设置暂停按钮不可用
            if ([taskInfo.taskStatus isEqualToString:FINISHED]) {
                
                NSLog(@"completionBlock======ooooo");
                //更新进度按钮的状态
                NSMutableDictionary * btnStateDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:taskInfo.taskId,@"taskId",@"disable" ,@"btnState", nil];
                [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnState:) withObject:btnStateDic waitUntilDone:NO];
                //更新进度条的状态信息
                NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:taskInfo.taskId,@"taskId",FINISHED ,@"taskStatus", nil];
                //在主线程刷新UI
                [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setTaskStatusInfo:) withObject:taskStatusDic waitUntilDone:NO];
            }
        };
        [downloadQueue addOperation:operation];
        [[ProgressBarViewController sharedInstance].downloadTaskDic  setObject:taskInfo forKey:taskInfo.taskId];
        [ProgressBarViewController sharedInstance].showTabIndex = 1;
        [[ProgressBarViewController sharedInstance] addProgressBarRow:taskInfo];
        [[ProgressBarViewController sharedInstance] setTabBarStyle];
    }
}

- (void)uploadFile:(NSString*) fileName localFilePath:(NSString*)localFilePath    serverCpath:(NSString*)serverCpath
{
    NSString* requestHost = [g_sDataManager requestHost];
    NSRange range  = [requestHost rangeOfString:@":"];
    if (range.location != NSNotFound) {
        requestHost = [requestHost substringToIndex:range.location];
    }
    if (![localFilePath isEqualToString:@""] && ![localFilePath isEqualToString:@"/"]) {
        localFilePath = [localFilePath stringByAppendingString:@"/"];
        localFilePath = [localFilePath stringByAppendingString:fileName];
    }
    NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"%@/root/%@", requestHost,[g_sDataManager userName]];
    if (![serverCpath isEqualToString:@"/"]) {
        [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",serverCpath]];
    }
    
    UploadFileTools * ud = [[UploadFileTools alloc] initWithLocalPath:[localFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  withServer:uploadUrl withName:FTP_USERNAME withPass:FTP_PASSWORD];
    
    TaskInfo* task = [[TaskInfo alloc] init];
    task.taskId = [NSUUIDTool gen_uuid];
    task.taskName = fileName;
    task.taskType = @"上传";
    ud.taskId =  task.taskId;
    [[ProgressBarViewController sharedInstance].uploadTaskDic setObject:task forKey:task.taskId];
    [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
    [ud start];
}
#pragma mark -
#pragma mark deleteFiles 删除文件的处理
-(void)deleteFiles:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath
{
    if(selectedItemsDic.count==0 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择文件" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alertView show];
        return ;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    
    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
    [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
    [dic setValue:cpath forKey:@"cpath"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    NSString *delFileName =@"";
    BOOL isFirstFile =YES;
    for (NSString *fileName in [selectedItemsDic allKeys]){
        NSLog(@"%zi",selectedItemsDic.count);
        if(isFirstFile){
            delFileName =fileName;
            isFirstFile =NO;
        }else{
            delFileName =[NSString stringWithFormat:@"%@@%@",delFileName,fileName];
        }
    }
    [dic setValue:delFileName forKey:@"dname"];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_DELETE_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"删除成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
            }
            
        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]){
            if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
            }
            
        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"删除失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

#pragma mark -
#pragma mark shareFile 共享文件的处理
-(void)shareFile:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath isShare:(NSString*) isShare{
    if(selectedItemsDic.count==0 ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择文件" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alertView show];
        return ;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
    [dic setValue:cpath forKey:@"filePath"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    NSString *shareFileName =@"";
    BOOL isFirstFile =YES;
    for (NSString *fileName in [selectedItemsDic allKeys]){
        NSLog(@"%zi",selectedItemsDic.count);
        if(isFirstFile){
            shareFileName = fileName;
            isFirstFile =NO;
        }else{
            shareFileName =[NSString stringWithFormat:@"%@@%@",shareFileName,fileName];
        }
    }
    [dic setValue:shareFileName forKey:@"fileName"];
    [dic setValue:isShare forKey:@"isShare"];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_SHARE_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"共享/取消共享成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
            }
        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"共享/取消共享失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
            }
        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]){
            if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
            }
            
        }
        
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

#pragma mark -
#pragma mark shareFile 共享文件夹的处理
-(void)shareFiles:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath isShare:(NSString*) isShare{
    
    @try {
        if(selectedItemsDic.count==0 ){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择文件夹" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            return ;
        }
        
        NSString* requestUrl=[NSString stringWithFormat: @"http://%@/%@",[g_sDataManager requestHost],REQUEST_SHARE_URL];
        
        BOOL isAllSuccess =YES;
        for (NSString *fileName  in [selectedItemsDic allKeys]){
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setTimeoutInterval:10];
            [request setURL:[NSURL URLWithString:requestUrl]];
            [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
            NSError * error=nil;
            NSString* post=[NSString stringWithFormat:@"uname=%@&fileName=%@&isShare=%@",[g_sDataManager userName],fileName, [((FileInfo *)[selectedItemsDic objectForKey:fileName]).isShare isEqualToString:@"0"] ?@"1" :@"0"];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
            [request setHTTPBody:postData];
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            if (!error){
                NSError * jsonError=nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:&jsonError];
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSString* result =[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"result"]];
                    if([result isEqualToString: @"1"]){
                        
                    }
                    else if([result isEqualToString: @"0"]){
                        //此文件已被共享
                    }
                    else{
                        isAllSuccess = NO;
                    }
                }else{
                    isAllSuccess = NO;
                }
            }else{
                isAllSuccess = NO;
            }
        }
        if(isAllSuccess){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"共享/取消共享成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误,共享/取消共享未全部完成!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
        }
        if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
            [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
        }
    }
    @catch (NSException *exception) {
        
    }
}

-(void)renameFile:(NSString*)fileName alertViewDelegate:(nullable id)alertViewDelegate{
    NSString *fileNameNoExt = [fileName stringByDeletingPathExtension];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重命名文件名称" message:@"" delegate:alertViewDelegate cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
    UITextField *textField=[alertView textFieldAtIndex:0];
    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入文件名称"];
    textField.text = fileName;
    textField.delegate = self;
}

-(void)createFolder :(nullable id)alertViewDelegate{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新建目录" message:@"" delegate:alertViewDelegate cancelButtonTitle:@"新建" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [alertView show];
}


#pragma mark -
#pragma mark clickedButtonAtIndex alertView的委托处理方法
-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger opType = self.opType;
    if(buttonIndex ==0){
        switch (opType) {
            case 1://移动
            {
                [self signal:@"1"];
                break;
            }
            case 2://复制
            {
                [self signal:@"1"];
                break;
            }
            case 4:
            {
                //得到输入框
                UITextField *textField=[alertView textFieldAtIndex:0];
                NSString *folderName = textField.text;
                if([textField.text isEqualToString:@""] ){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入目录名称" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入目录名称"];
                    [alertView show];
                    return;
                }
                if([ValidateTool isEqualToKeyword:folderName]){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"“%@”禁止新建!",folderName] message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入目录名称"];
                    [alertView show];
                    return;
                }
                
                BOOL isExist =  NO;
                for(NSString *dicKey in self.tableDataDic) {
                    FileInfo  *fileInfo = [ self.tableDataDic objectForKey:dicKey];
                    if([fileInfo.fileName isEqualToString: folderName]){
                        isExist = YES;
                        break;
                    }
                }
                if(isExist){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"目录已存在,请重新输入！" message:@"" delegate:self cancelButtonTitle:@"新建" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入目录名称"];
                    [alertView show];
                    return;
                }
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                __block NSError *error = nil;
                [dic setValue:self.cpath forKey:@"cpath"];
                [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
                [dic setValue:folderName forKey:@"newName"];
                NSString* requestHost = [g_sDataManager requestHost];
                NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                MKNetworkOperation *op = [engine operationWithPath:REQUEST_NEWFOLDER_URL params:dic httpMethod:@"POST" ssl:NO];
                [op addCompletionHandler:^(MKNetworkOperation *operation) {
                    NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                    
                    if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"新建文件夹成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                            [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
                        }
                        
                    }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]){
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                            [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
                        }
                        
                    }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"新建文件夹失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }
                }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                }];
                [engine enqueueOperation:op];
                break;
            }
            case 5: //重命名文件名
            {
                UITextField *textField=[alertView textFieldAtIndex:0];
                if([textField.text isEqualToString:@""] ){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"名称不能为空" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入文件名称"];
                    [alertView show];
                    return;
                }
                NSString * fullFileName = self.selectedFileName;
                fileName = textField.text;
                NSString *extName = [fullFileName pathExtension];
                BOOL isExist =  NO;
                BOOL isSpecialName = NO;
                for(NSString *dicKey in  self.tableDataDic) {
                    FileInfo  *fileInfo = [self.tableDataDic objectForKey:dicKey];
                    if([fileInfo.fileName isEqualToString: fileName]){
                        isExist = YES;
                        break;
                    }
                    if([ValidateTool isEqualToKeyword:fileName]){
                        isSpecialName = YES;
                        break;
                    }
                    
                }
                if(isExist){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件已存在,请重新输入！" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入文件名称"];
                    [alertView show];
                    UITextField *textField=[alertView textFieldAtIndex:0];
                    textField.text = self.selectedFileName;
                    textField.delegate = self;
                    return;
                }
                
                
                if(isSpecialName){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"文件名“%@”不能使用",fileName] message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [alertView show];
                    UITextField *textField=[alertView textFieldAtIndex:0];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入文件名称"];
                    textField.text = self.selectedFileName;
                    textField.delegate = self;
                    return;
                }
                if(![extName isEqualToString:[fileName pathExtension]])//如果拓展名有改变
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扩展名修改后会导致文件不可使用，确定修改吗？" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];[alertView show];
                    self.opType = 6;
                    return;
                }
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                __block NSError *error = nil;
                NSString * newName = nil;
                if ([self.cpath isEqualToString:@"/"]) {
                    newName = [self.cpath stringByAppendingString:fileName];
                    
                }else if([self.cpath isEqualToString:@""]){
                    newName = self.cpath;
                }else if([self.cpath length]>1){
                    NSString *lastChar =[self.cpath substringFromIndex:self.cpath.length];
                    if(![lastChar isEqualToString:@"/"])
                    {
                        newName = [self.cpath stringByAppendingString:@"/"];
                        newName = [newName stringByAppendingString:fileName];
                    }
                    
                }
                NSString * oldName = nil;
                if ([self.cpath isEqualToString:@"/"]) {
                    oldName = [self.cpath stringByAppendingString:fullFileName];
                }else if(![self.cpath isEqualToString:@""])
                {
                    oldName = [self.cpath stringByAppendingString:@"/"];
                    oldName =[oldName stringByAppendingString:fullFileName];
                }
                [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
                [dic setValue:newName forKey:@"newname"];
                [dic setValue:oldName forKey:@"oldname"];
                NSString* requestHost = [g_sDataManager requestHost];
                NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                MKNetworkOperation *op = [engine operationWithPath:REQUEST_RENAME_URL params:dic httpMethod:@"POST" ssl:NO];
                [op addCompletionHandler:^(MKNetworkOperation *operation) {
                    NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                    if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                            [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
                        }
                        
                    }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该文件已存在，请重新命名" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]){
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                            [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
                        }
                        
                    }else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }
                }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alert show];
                }];
                [engine enqueueOperation:op];
                break;
            }
            case 6:{ //修改扩展名之后的重命名
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                __block NSError *error = nil;
                NSString * newName = nil;
                NSString * fullFileName = self.selectedFileName;
                if ([self.cpath isEqualToString:@"/"]) {
                    newName = [self.cpath stringByAppendingString:fileName];
                    
                }else if([self.cpath isEqualToString:@""]){
                    newName = self.cpath;
                }else if([self.cpath length]>1){
                    NSString *lastChar =[self.cpath substringFromIndex:self.cpath.length];
                    if(![lastChar isEqualToString:@"/"])
                    {
                        newName = [self.cpath stringByAppendingString:@"/"];
                        newName = [newName stringByAppendingString:fileName];
                    }
                    
                }
                NSString * oldName = nil;
                if ([self.cpath isEqualToString:@"/"]) {
                    oldName = [self.cpath stringByAppendingString:fullFileName];
                }else if(![self.cpath isEqualToString:@""])
                {
                    oldName = [self.cpath stringByAppendingString:@"/"];
                    oldName =[oldName stringByAppendingString:fullFileName];
                }
                [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
                [dic setValue:newName forKey:@"newname"];
                [dic setValue:oldName forKey:@"oldname"];
                NSString* requestHost = [g_sDataManager requestHost];
                NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                MKNetworkOperation *op = [engine operationWithPath:REQUEST_RENAME_URL params:dic httpMethod:@"POST" ssl:NO];
                [op addCompletionHandler:^(MKNetworkOperation *operation) {
                    NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                    if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                            [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
                        }
                        
                    }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该文件已存在，请重新命名" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"]){
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                            [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
                        }
                        
                    }else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }
                }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alert show];
                }];
                [engine enqueueOperation:op];
                break;
            }
                
                
            default:
                break;
        }
    }else if(buttonIndex==1){ //如果点击取消时
        switch (opType) {
            case 1://移动
            {
                [self signal:@"0"];
                break;
            }
            case 2://复制
            {
                [self signal:@"0"];
                break;
            }
            default:
                break;
        }
    }
}

- (void)uploadFileWithHttp:(NSOperationUploadQueue *)uploadQueue fileName:(NSString*) fileName localFilePath:(NSString*)localFilePath    serverCpath:(NSString*)serverCpath{
    if (![localFilePath isEqualToString:@""] && ![localFilePath isEqualToString:@"/"]) {
        localFilePath = [localFilePath stringByAppendingString:@"/"];
        localFilePath = [localFilePath stringByAppendingString:fileName];
    }
    NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"/%@",[g_sDataManager userName]];
    if (![serverCpath isEqualToString:@"/"]) {
        [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",serverCpath]];
    }
    BOOL operationIsExist = NO;
    //    for (FileUploadByBlockTool *operation in [uploadQueue operations]) {
    //        if ([operation.fileName isEqualToString:fileName]) {
    //            operationIsExist = YES;
    //        }
    //    }
    if (!operationIsExist) {
        TaskInfo* taskInfo = [[TaskInfo alloc] init];
        taskInfo.taskId = [NSUUIDTool gen_uuid];
        taskInfo.taskName = fileName;
        taskInfo.taskType = @"上传";
        taskInfo.localFileNamePath = [localFilePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        taskInfo.ip = [g_sDataManager requestHost] ;
        taskInfo.serverPath = uploadUrl;
        taskInfo.userName = [g_sDataManager userName];
        taskInfo.fileName = fileName;
        taskInfo.port = REQUEST_PORT;
        taskInfo.password = [g_sDataManager password];
        FileUploadByBlockOperation *operation = [[FileUploadByBlockOperation alloc] initWithTaskInfo:taskInfo];
        operation.taskId = taskInfo.taskId;
        operation.fileName = fileName;
        operation.taskId = taskInfo.taskId;
        operation.taskInfo = taskInfo;
        [uploadQueue addOperation:operation];
        [[ProgressBarViewController sharedInstance].uploadTaskDic  setObject:taskInfo forKey:taskInfo.taskId];
        [ProgressBarViewController sharedInstance].showTabIndex = 0;
        [[ProgressBarViewController sharedInstance] setTabBarStyle];
        [[ProgressBarViewController sharedInstance] addProgressBarRow:taskInfo];
    }
    
}

-(void)copyFiles:(NSMutableDictionary*) paramsDic{
    [self.condition lock];
    NSString *targetPath;
    NSString *sourcePath;
    NSMutableDictionary *selectedItemsDic;
    if([[paramsDic allKeys]containsObject:@"targetPath"]){
        targetPath = [paramsDic objectForKey:@"targetPath"];
    }
    if([[paramsDic allKeys]containsObject:@"selectedItemsDic"]){
        selectedItemsDic = [paramsDic objectForKey:@"selectedItemsDic"];
    }
    if ([[paramsDic allKeys]containsObject:@"sourcePath"]) {
        sourcePath =[paramsDic objectForKey:@"sourcePath"];
    }
    if(selectedItemsDic.count>0){
        int copyCount = 0;
        
        
        BOOL isSuccess =YES;
        for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
            NSDictionary * filesDic = [self getAllFilesByPath:targetPath];
            if (filesDic && [[filesDic allKeys] containsObject:fileNameTmp]) { //如果目标目录下已存在该文件，则等待
                NSString *message = [NSString stringWithFormat:@"目标目录下已经存在一个名为：%@的文件，覆盖掉原有的目录吗？",fileNameTmp];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil] ;
                    [alert show];
                });
                [self.condition wait];
                if ([self.flag isEqualToString:@"0"]) {
                    copyCount++;//如果提示目标路径下有重名文件后，用户按下取消按钮，表示不覆盖该文件，因此需要将已复制的文件总数加1
                    continue;
                }
            }
            NSString *postTargetPath;
            NSString *postSourcePath;
            postTargetPath = targetPath;
            postSourcePath = sourcePath;
            if ([postTargetPath isEqualToString:@""] || ![postTargetPath isEqualToString:@"/"]) {
                postTargetPath=[postTargetPath stringByAppendingString :@"/"];
            }
            postTargetPath=[postTargetPath stringByAppendingString :fileNameTmp];
            if ([postSourcePath isEqualToString:@""] || ![postSourcePath isEqualToString:@"/"]) {
                postSourcePath=[postSourcePath stringByAppendingString :@"/"];
            }
            postSourcePath = [postSourcePath stringByAppendingString :fileNameTmp];
            NSString* requestHost = [g_sDataManager requestHost];
            NSString* requestUrl = [NSString stringWithFormat:@"http://%@/%@",requestHost,REQUEST_COPY_URL];
            
            NSURL *copyFileUrl = [NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:copyFileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
            [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
            NSError * copyFileError = nil;
            NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&sourcepath=%@&targetpath=%@",[g_sDataManager userName],[g_sDataManager password],postSourcePath,postTargetPath];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
            [request setHTTPBody:postData];
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&copyFileError];
            if (!copyFileError) {
                NSError * jsonError=nil;
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&jsonError];
                NSLog(@"responseJSON。。。。。=======%@",responseJSON);
                if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
                {
                    copyCount++;
                }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"] && !self.isServerSessionTimeOut)//session time out
                {
                    isSuccess = NO;
                    if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                        [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
                    }
                }else{
                    isSuccess = NO;
                    
                }
            }
            
        }
        if(isSuccess && copyCount==selectedItemsDic.count){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"复制成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"复制失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
        }
    }
    [self.condition unlock];
}

#pragma mark -
#pragma mark moveFiles 复制文件的处理
-(void)moveFiles:(NSMutableDictionary*) paramsDic{
    [self.condition lock];
    NSString *targetPath;
    NSString *sourcePath;
    NSMutableDictionary *selectedItemsDic;
    if([[paramsDic allKeys]containsObject:@"targetPath"]){
        targetPath = [paramsDic objectForKey:@"targetPath"];
    }
    if([[paramsDic allKeys]containsObject:@"selectedItemsDic"]){
        selectedItemsDic = [paramsDic objectForKey:@"selectedItemsDic"];
    }
    if ([[paramsDic allKeys]containsObject:@"sourcePath"]) {
        sourcePath =[paramsDic objectForKey:@"sourcePath"];
    }
    if(selectedItemsDic.count>0){
        int moveCount = 0;
        
        BOOL isSuccess = YES;
        for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
            NSDictionary * filesDic = [self getAllFilesByPath:targetPath];
            if (filesDic && [[filesDic allKeys] containsObject:fileNameTmp]) { //如果目标目录下已存在该文件，则等待
                NSString *message = [NSString stringWithFormat:@"目标目录下已经存在一个名为：%@的文件，覆盖掉原有的目录吗？",fileNameTmp];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil] ;
                    [alert show];
                });
                [self.condition wait];
                if ([self.flag isEqualToString:@"0"]) {
                    moveCount++;//如果提示目标路径下有重名文件后，用户按下取消按钮，表示不覆盖该文件，因此需要将已移动的文件总数加1
                    continue;
                }
            }
            NSString *postTargetPath;
            NSString *postSourcePath;
            postTargetPath = targetPath;
            postSourcePath = sourcePath;
            if ([postTargetPath isEqualToString:@""] || ![postTargetPath isEqualToString:@"/"]) {
                postTargetPath=[postTargetPath stringByAppendingString :@"/"];
            }
            postTargetPath=[postTargetPath stringByAppendingString :fileNameTmp];
            if ([postSourcePath isEqualToString:@""] || ![postSourcePath isEqualToString:@"/"]) {
                postSourcePath=[postSourcePath stringByAppendingString :@"/"];
            }
            postSourcePath = [postSourcePath stringByAppendingString :fileNameTmp];
            NSString* requestHost = [g_sDataManager requestHost];
            NSString* requestUrl = [NSString stringWithFormat:@"http://%@/%@",requestHost,REQUEST_MOVE_URL];
            
            NSURL *copyFileUrl = [NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:copyFileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
            [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
            NSError * moveFileError = nil;
            NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&sourcepath=%@&targetpath=%@",[g_sDataManager userName],[g_sDataManager password],postSourcePath,postTargetPath];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
            [request setHTTPBody:postData];
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&moveFileError];
            if (!moveFileError) {
                NSError * jsonError=nil;
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&jsonError];
                NSLog(@"responseJSON。。。。。=======%@",responseJSON);
                if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//移动成功
                {
                    moveCount++;
                    //   if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                    //       [self.fileHandlerDelegate requestSuccessCallback];//调用委托方法
                    //  }
                    
                }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"200"] && !self.isServerSessionTimeOut)//session time out
                {
                    isSuccess = NO;
                    if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                        [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
                    }
                }else{
                    isSuccess = NO;
                }
            }
        }
        
        
        if(isSuccess && moveCount==selectedItemsDic.count){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"移动成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"移动失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alert show];
        }
    }
    [self.condition unlock];
}

#pragma mark -
#pragma mark getAllFilesByPath 返回指定目录下的所有文件
-(NSDictionary*)getAllFilesByPath:(NSString*)path{
    NSMutableDictionary *filesDic = [[NSMutableDictionary alloc] init];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"http://%@/%@",requestHost,REQUEST_FETCH_URL];
    
    NSURL *fetchFileUrl = [NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:fetchFileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSError * fetchFileError = nil;
    NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&cpath=%@",[g_sDataManager userName],[g_sDataManager password],path];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
    [request setHTTPBody:postData];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&fetchFileError];
    if (!fetchFileError) {
        NSError * jsonError=nil;
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&jsonError];
        NSLog(@"responseJSON。。。。。=======%@",responseJSON);
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"1"])//获取目录成功
        {
            NSArray *responseJSONResult=responseJSON[@"result"];
            if([responseJSONResult isEqual:@"file not exit"]){
                return nil;
            }
            [responseJSONResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                if (responseJSONResult && responseJSONResult.count>0) {
                    FileInfo *fileInfo = [[FileInfo alloc] init];
                    fileInfo.fileName = dict[@"fileName"];
                    fileInfo.fileSize = dict[@"fileSize"];
                    fileInfo.fileChangeTime = dict[ @"fileChangeTime"];
                    fileInfo.fileType = dict[@"fileType"];
                    fileInfo.fileSubtype =@"folder";
                    fileInfo.isShare = dict[@"isShare"];
                    [filesDic setObject:fileInfo forKey:fileInfo.fileName];
                }else{
                    *stop = YES;
                }
            }];
        }else if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"200"]){
            self.isServerSessionTimeOut =YES;
            if ([self.fileHandlerDelegate respondsToSelector:@selector(sessionTimeOutCallback)]) {
                [self.fileHandlerDelegate sessionTimeOutCallback];//调用委托方法
            }
        }
    }
    return filesDic;
}

-(void)signal:(NSString*)flag{
    self.flag = flag;
    [self.condition broadcast];
}

-(long long int)getFileSize:(NSString*)filePath fileName:(NSString*)fileName{
    NSString* requestUrl=[NSString stringWithFormat: @"http://%@/",[g_sDataManager requestHost]];
    
    NSString* fileSizeString =[requestUrl stringByAppendingString: REQUEST_FILESIZE_URL];
    NSURL *fileSizeUrl = [NSURL URLWithString:[fileSizeString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:fileSizeUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSError * fileSizeError = nil;
    long long int fileLength = 0;
    NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&filePath=%@&fileName=%@",[g_sDataManager userName],[g_sDataManager password],filePath,fileName];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
    [request setHTTPBody:postData];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&fileSizeError];
    if (!fileSizeError) {
        NSError * jsonError=nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:&jsonError];
        if ([jsonObject isKindOfClass:[NSDictionary class]]){
            NSDictionary *dictionary = (NSDictionary *)jsonObject;
            NSString* result =[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"result"]];
            if([result isEqualToString: @"1"]){
                fileLength = [[dictionary objectForKey:@"size"] intValue];
            }
        }
    }
    return fileLength;
}


#pragma mark -
#pragma mark textField 的代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSString * fileName = textField.text;
    NSString * ext = [fileName pathExtension];
    
    UITextPosition * begin = [textField beginningOfDocument];
    UITextPosition * end = nil;
    
    if ([ext length] == 0) {
        end = [textField endOfDocument];
    }
    else {
        end = [textField positionFromPosition:begin offset:([fileName length] - [ext length] - 1)];
    }
    
    [textField setSelectedTextRange:[textField textRangeFromPosition:begin toPosition:end]];
}

@end
