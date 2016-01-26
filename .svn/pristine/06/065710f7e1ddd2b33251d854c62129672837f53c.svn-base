//
//  TableViewDelegate.m
//  CustomIOSAlertView
//
//  Created by riqiao on 16/1/4.
//  Copyright © 2016年 Wimagguc. All rights reserved.
//

#import "TableViewDelegate.h"
#define AU_Cell_Height 30
@implementation TableViewDelegate

- (id) init {
    if((self = [super init]))
    {
        self.fileNamesArray = [[NSArray alloc]init];
        self.selectedFileNamesDic = [[NSMutableDictionary alloc]init];
    }
    return self;

}

//UITableViewDataSource协议中的方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//UITableViewDataSource协议中的方法
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FILENAME"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FILENAME"];
    }
    cell.textLabel.text = self.fileNamesArray[indexPath.row];
    return cell;
}


//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fileNamesArray.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = self.fileNamesArray[indexPath.row];
    
    if(fileName && ([[self.selectedFileNamesDic allKeys] containsObject:fileName])){
        [self.selectedFileNamesDic removeObjectForKey:fileName];
    }
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileName = self.fileNamesArray[indexPath.row];
    
    if(fileName && !([[self.selectedFileNamesDic allKeys] containsObject:fileName])){
        [self.selectedFileNamesDic setObject:fileName forKey:fileName];
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


@end
