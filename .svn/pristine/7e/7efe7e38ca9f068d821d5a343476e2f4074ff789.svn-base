//
//  PhotoViewController.m
//  photoView
//
//  Created by apple3 on 15/12/10.
//  Copyright © 2015年 apple3. All rights reserved.
//

#import "CameraPhotoViewController.h"
#import "BigCollectionViewCell.h"
#import "SmallCollectionViewCell.h"
#import "BigLayout.h"
#import "SmallLayout.h"

@interface CameraPhotoViewController (){
    NSArray* big;
    NSMutableArray* small;
}

@property (strong, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property Boolean beSingleTaped;
@property Boolean beDoubleTaped;
@property (strong,nonatomic) UIImageView *myBigImage;


@end

@implementation CameraPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.beSingleTaped = NO;
    self.beDoubleTaped = NO;
    //
    [self.myNavigationBar setBackgroundImage:[UIImage new]  forBarMetrics:UIBarMetricsDefault];
    self.myNavigationBar.shadowImage = [UIImage new];
    self.myNavigationBar.translucent = YES;
    
    //dataSource delegate
    self.bigPhoto.dataSource = self;
    self.smallPhoto.dataSource = self;
    self.bigPhoto.delegate = self;
    self.smallPhoto.delegate = self;
    //
//    self.bigPhoto.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 400);
//    self.smallPhoto.bounds = CGRectMake(0, 480, [[UIScreen mainScreen] bounds].size.width, 80);
//    self.bigPhoto.backgroundColor = [UIColor whiteColor];
//    self.smallPhoto.backgroundColor = [UIColor whiteColor];
    
//    big = @[@"01.jpg",@"02.jpg",@"03.jpg",@"04.jpg",@"05.jpg",@"04.jpg",@"02.jpg",@"01.jpg"];
    big = self.arrayPhotos;
    small = [[NSMutableArray alloc]init];
    [small addObject:@""];
    [small addObjectsFromArray:big];
    [small addObject:@""];
    
    NSLog(@"small==%@",small);
    

    [self.bigPhoto registerNib:[UINib nibWithNibName:@"BigCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"bigs"];
    [self.smallPhoto registerNib:[UINib nibWithNibName:@"SmallCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"smalls"];
    BigLayout* bigLayout = [[BigLayout alloc]init];
    SmallLayout* smallLayout = [[SmallLayout alloc]init];
    self.bigPhoto.collectionViewLayout = bigLayout;
    self.smallPhoto.collectionViewLayout = smallLayout;

    self.bigPhoto.alwaysBounceVertical=YES;
    self.smallPhoto.alwaysBounceVertical=YES;
    [self.bigPhoto reloadData];
    [self.smallPhoto reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//item个数

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == self.bigPhoto){
        return big.count;
    }else if(collectionView == self.smallPhoto){
        return small.count;
    }else{
        return 0;
    }
}

#pragma mark cell的视图
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.bigPhoto){
        
        BigCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"bigs" forIndexPath:indexPath];
        NSInteger row = indexPath.row;

        if ([big[row] isEqualToString:@""]) {
            cell.bigImage.image = [UIImage new];
        }else{
//            cell.bigImage.image = [UIImage imageNamed:big[row]];
            cell.bigImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:big[row]]]];
        }
        return cell;
        
    }else if (collectionView ==self.smallPhoto){
        
        SmallCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"smalls" forIndexPath:indexPath];
        NSInteger row = indexPath.row;
        if ([small[row] isEqualToString:@""]) {
            cell.smallImage.image = [UIImage new];
        }else{
//            cell.smallImage.image = [UIImage imageNamed:small[row]];
            cell.smallImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:small[row]]]];
        }
        return cell;
        
    }else{
        return nil;
    }
}

- (void)scrollViewDidScroll:(UICollectionView *)scrollView
{
    float bigX = (self.bigPhoto.bounds.size.width)*3.0/(self.smallPhoto.bounds.size.width -3.0);
    float littleX = (self.smallPhoto.bounds.size.width -3.0)/(self.bigPhoto.bounds.size.width)/3.0;
    if (scrollView == self.bigPhoto) {
        self.smallPhoto.delegate = nil;
        self.smallPhoto.contentOffset = CGPointMake(scrollView.contentOffset.x * littleX, scrollView.contentOffset.y);
        self.smallPhoto.delegate = self;
        NSLog(@"sdfsdfsd");
    }
    else
    {
        self.bigPhoto.delegate = nil;
        self.bigPhoto.contentOffset = CGPointMake(scrollView.contentOffset.x * bigX, scrollView.contentOffset.y);
        self.bigPhoto.delegate = self;
        NSLog(@"1111sdfsdfsd");
    }
}

#pragma mark cell的大小

#pragma mark cell的点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.smallPhoto){
        if (indexPath.row == 0 || indexPath.row == small.count -1 ) {
            NSLog(@"bu neng dian");
        }else{
            [self.bigPhoto setContentOffset:CGPointMake(([[UIScreen mainScreen] applicationFrame].size.width + 3)*(indexPath.row - 1) , 0.0f) animated:YES];
        }
        
    }else if(collectionView == self.bigPhoto){
        
        if (!self.beSingleTaped) {
            //
            //navigation bar
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
            //
            //cell
            UICollectionViewCell *cell = [self.bigPhoto cellForItemAtIndexPath:indexPath];
            BigCollectionViewCell *bigcell;
            if ([cell isKindOfClass:[BigCollectionViewCell class]]) {
                bigcell =  cell;
            }
            //mybigimage
//            [bigcell setFrame:CGRectMake(bigcell.frame.origin.x, bigcell.frame.origin.y, bigcell.frame.size.width + 200, bigcell.frame.size.height + 201)];
            
            self.myBigImage = [[UIImageView alloc]initWithImage:bigcell.bigImage.image];
            [self.view addSubview:self.myBigImage];
            //show
            self.myBigImage.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width - 10, self.view.frame.size.height - 100);
            self.myBigImage.alpha = 0.0f;
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationCurveEaseInOut| UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                [self.myBigImage setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 65, self.view.frame.size.width, self.view.frame.size.height - 65)];
            } completion:^(BOOL finished) {
            }];
            
            //aspect fit
            [self.myBigImage setContentMode:UIViewContentModeScaleAspectFit];
            UIColor *color = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.85];
            [self.myBigImage setBackgroundColor:color];
            [self.myBigImage setAlpha:1.0f];
            //
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage)];
            [tapGesture setNumberOfTapsRequired:1];
            [tapGesture setNumberOfTouchesRequired:1];
            [self.myBigImage addGestureRecognizer:tapGesture];
            [self.myBigImage setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapImage:)];
            [doubleTapGesture setNumberOfTapsRequired:2];
            [doubleTapGesture setNumberOfTouchesRequired:1];
            [self.myBigImage addGestureRecognizer:doubleTapGesture];
            
            [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
            NSLog(@"bigPhoto pressed");

            self.beSingleTaped = !self.beSingleTaped;
        }else{
            //
            NSLog(@"back");
//            [self.myBigImage removeFromSuperview];
        }
    }else{
        return;
    }
}

-(void)tapImage
{
    //navigation bar
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.myBigImage.alpha = 0.0;
        self.myBigImage.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width - 10, self.view.frame.size.height - 100);
    } completion:^(BOOL finished) {
        [self.myBigImage removeFromSuperview];
    }];
    
    
    NSLog(@"tapping");
    self.beSingleTaped = !self.beSingleTaped;
}

-(void)doubleTapImage:(id)sender{
//    NSLog(@"sender==%@",sender);
    NSLog(@"doubleTapImage");
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == 2) {
//        return CGSizeMake(200, 200);
//    }
//    return CGSizeMake(100, 100);
//}

- (IBAction)backbarButtonPressed:(UIBarButtonItem *)sender {
    
    //    if (self.presentingViewController || !self.navigationController)
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //    else
    //        [self.navigationController popViewControllerAnimated:YES];
    [self.view removeFromSuperview];
}
@end
