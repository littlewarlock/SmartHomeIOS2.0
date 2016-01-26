//
//  CameraSnapshotHistoryViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/12/2.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraSnapshotHistoryViewController.h"
#import "CameraSnapshotHistoryCollectionViewCell.h"
#import "DWFlowLayout.h"

#define SCREENWITH   [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height



@interface CameraSnapshotHistoryViewController ()
{
    NSArray *data;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *myNavigationBar;

@end



@implementation CameraSnapshotHistoryViewController


NSString *cellIdentifier = @"CameraSnapshotHisViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    DWFlowLayout *layout = [[DWFlowLayout alloc] init];
    self.collectionView.collectionViewLayout = layout;
    //
    //collection nib
    UINib *nib = [UINib nibWithNibName:@"CameraSnapshotHistoryCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView setBackgroundColor:[UIColor lightTextColor]];
    //
    [self.myNavigationBar setBackgroundImage:[UIImage new]  forBarMetrics:UIBarMetricsDefault];
    self.myNavigationBar.shadowImage = [UIImage new];
    self.myNavigationBar.translucent = YES;
    //
    data = @[@"01",@"02",@"03",@"04",@"05",@"01",@"02",@"03",@"04",@"05"];
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark cell的数量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return data.count;
}

#pragma mark cell的视图
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CameraSnapshotHistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    cell.showImg.image = [UIImage imageNamed:[data objectAtIndex:row]];
    
    // hgc test
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://172.16.9.95:8080/smarthome/snapshot/common/snapshotcommon_2.jpg"]]];
//    cell.showImg.image = image;
    
    return cell;
}

#pragma mark cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREENWITH - 60, SCREENHEIGHT - 64 - 60 - 60);
//    return CGSizeMake(200.0f, 150.0f);
}

#pragma mark cell的点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击图片%ld",indexPath.row);
    
}

//back
- (IBAction)backbarButtonPressed:(UIBarButtonItem *)sender {
    
//    if (self.presentingViewController || !self.navigationController)
//        [self dismissViewControllerAnimated:YES completion:nil];
//    else
//        [self.navigationController popViewControllerAnimated:YES];
    [self.view removeFromSuperview];

}

@end
