//
//  LocalHander.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/16.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "LocalFileHandler.h"
#import "FileInfo.h"
#import "FileTools.h"
#import "FileCopyTools.h"
#import "DataManager.h"
#import "UIHelper.h"
@interface LocalFileHandler ()
{
    NSString *fileReName;
}
@end
@implementation LocalFileHandler

#pragma mark -
#pragma mark renameFile 重命名文件的处理
-(void)renameFile:(FileInfo *) fileInfo {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入新名称" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];

    UITextField *textField=[alertView textFieldAtIndex:0];
    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入文件名称"];
    textField.text = fileInfo.fileName;
    textField.delegate = self;
    [alertView show];
    
    self.fileInfo =fileInfo;
}

#pragma mark -
#pragma mark deleteFiles 删除文件的处理
-(void)deleteFiles:(NSMutableDictionary*) selectedItemsDic{
    if (selectedItemsDic.count>0) {
        for (NSString *fileUrl in [selectedItemsDic allKeys]){
            int result = [FileTools deleteFileByUrl:fileUrl];
            if (result==0) {
                [selectedItemsDic removeObjectForKey:fileUrl];
            }
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"文件已删除" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alertView show];
        
        if ([self.localFileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
            [self.localFileHandlerDelegate requestSuccessCallback];//调用委托方法
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark createFolderAction 新建文件夹的处理
- (void)createFolderAction{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新建目录" message:@"" delegate:self cancelButtonTitle:@"新建" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入目录名称"];
    [alertView show];
    
}

- (void)downloadAction{
    NSString* userName = [g_sDataManager userName];
    if (!userName || [userName isEqualToString:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"下载文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
        [alertView show];
    }
}
#pragma mark -
#pragma mark clickedButtonAtIndex 弹出菜单的重命名处理事件
-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (self.opType) {
        case 5: //重命名
            if(buttonIndex ==0 ){
                //得到输入框
                UITextField *textField=[alertView textFieldAtIndex:0];
                if([textField.text isEqualToString:@""] ){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"名称不能为空" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入文件名称"];
                    [alertView show];
                    UITextField *textField=[alertView textFieldAtIndex:0];
                    textField.text = self.selectedFileName;
                    textField.delegate = self;
                    return;
                }
                NSString * fullFileName = self.fileInfo.fileName;
                NSString *fileName = textField.text;
                fileReName = fileName;
                NSString *extName = [fullFileName pathExtension];
                BOOL isExist =  NO;
                for(NSString *dicKey in self.tableDataDic) {
                    FileInfo  *fileInfo = [self.tableDataDic objectForKey:dicKey];
                    if([fileInfo.fileName isEqualToString: fileName] && (self.fileInfo!=fileInfo)){
                        isExist = YES;
                        break;
                    }
                }
                if(isExist){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件名已存在,请重新输入！" message:@"" delegate:self cancelButtonTitle:@"新建" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入目录名称"];
                    UITextField *textField=[alertView textFieldAtIndex:0];
                    textField.text = self.selectedFileName;
                    textField.delegate = self;
                    [alertView show];
                    return;
                }
                
                
                if(![[fileName pathExtension] isEqualToString:extName])//如果拓展名有改变
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扩展名修改后会导致文件不可使用，确定修改吗？" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];[alertView show];
                    self.opType = 8;
                    return;
                }
                NSString *path = self.cpath;
                path=[path stringByAppendingPathComponent:fileName];
                [FileTools moveFileByUrl:self.fileInfo.fileUrl toPath:path];

                if ([self.localFileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                    [self.localFileHandlerDelegate requestSuccessCallback];//调用委托方法
                }
                
            }
            
            break;
        case 6://新建文件夹
            
            if(buttonIndex ==0)
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
                
                BOOL isExist =  NO;
                for(NSString *dicKey in self.tableDataDic) {
                    FileInfo  *fileInfo = [self.tableDataDic objectForKey:dicKey];
                    if([fileInfo.fileName isEqualToString: folderName] && [fileInfo.fileType isEqualToString:@"folder"]){
                        isExist = YES;
                        break;
                    }
                }
                if(isExist){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"目录已存在，请重新命名" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [[alertView textFieldAtIndex:0] setPlaceholder:@"请输入目录名称"];
                    [alertView show];
                    return;
                }
                
                NSString *path = self.cpath;
                NSString *newFolderName =folderName;
                NSString *folderDir = [NSString stringWithFormat:@"%@/%@", path, newFolderName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if([fileManager createDirectoryAtPath:folderDir withIntermediateDirectories:YES attributes:nil error:nil]){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"新建文件夹成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alertView show];
                    if ([self.localFileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                        [self.localFileHandlerDelegate requestSuccessCallback];//调用委托方法
                    }
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"新建文件夹失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alertView show];
                    
                }
            }
            
            break;
        case 7://下载
            if(buttonIndex ==0){ //下载时用户未登录
                [UIHelper showLoginViewWithDelegate:self loginViewDelegate:self];
            }
            break;
        case 8://重命名（修改拓展名）
            if(buttonIndex ==0){ //下载时用户未登录
                NSString *path = self.cpath;
                path=[path stringByAppendingPathComponent:fileReName];
                [FileTools moveFileByUrl:self.fileInfo.fileUrl toPath:path];
                if ([self.localFileHandlerDelegate respondsToSelector:@selector(requestSuccessCallback)]) {
                    [self.localFileHandlerDelegate requestSuccessCallback];//调用委托方法
                }
            }
            break;
        default:
            break;
    }
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
