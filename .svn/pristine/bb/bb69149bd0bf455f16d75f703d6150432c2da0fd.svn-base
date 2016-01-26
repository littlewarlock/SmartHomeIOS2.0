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
#import "FileCopyAndMoveTools.h"
#import "DataManager.h"
#import "UIHelper.h"

@implementation LocalFileHandler

#pragma mark -
#pragma mark renameFile 重命名文件的处理
-(void)renameFile:(FileInfo *) fileInfo {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入新名称" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];

    UITextField *textField=[alertView textFieldAtIndex:0];
    textField.text = [fileInfo.fileName stringByDeletingPathExtension];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入文件夹名称" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
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
                    [alertView show];
                    return;
                }
                NSString * fullFileName = self.fileInfo.fileName;
                NSString *fileName = textField.text;
                NSString *extName = [fullFileName pathExtension];
                if(![extName isEqualToString:@""])
                {
                    fileName = [fileName stringByAppendingString:@"."];
                    fileName =[fileName stringByAppendingString:extName];
                }
                BOOL isExist =  NO;
                for(NSString *dicKey in self.tableDataDic) {
                    FileInfo  *fileInfo = [self.self.tableDataDic objectForKey:dicKey];
                    if([fileInfo.fileName isEqualToString: fileName] && (self.fileInfo!=fileInfo)){
                        isExist = YES;
                        break;
                    }
                }
                if(isExist){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件已存在,请重新输入！" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [alertView show];
                    return;
                }
                NSString *path = self.cpath;
                //NSRange range = [path rangeOfString:self.curCel.textLabel.text];//匹配得到的下标
                //
                //path=[path substringToIndex:range.location];
                path=[path stringByAppendingPathComponent:fileName];
               //[FileTools moveFileByUrl:self.fileInfo.fileUrl   toPath:path];
                
                BOOL  opreationIsExist= false;
                opreationIsExist= false;
                for (FileCopyAndMoveTools *operation in [self.queue operations]) {
                    if ([operation.fileUrl isEqualToString:self.fileInfo.fileUrl]) {
                        opreationIsExist = true;
                    }
                }
                if (!opreationIsExist) {
                    FileCopyAndMoveTools *opreation = [[FileCopyAndMoveTools alloc] initWithFileInfo];
                    opreation.fileUrl = self.fileInfo.fileUrl;
                    opreation.destinationUrl = path;
                    opreation.opType = @"move";
                    [self.queue addOperation:opreation];
                }

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
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入不能为空" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
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
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件已存在,请重新输入！" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
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
            
        default:
            break;
    }
    
}

@end
