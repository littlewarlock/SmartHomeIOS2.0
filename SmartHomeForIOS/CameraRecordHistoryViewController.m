//
//  CameraRecordHistoryViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraRecordHistoryViewController.h"
#import "KxMovieAlarmRecordViewController.h"
#import "DeviceNetworkInterface.h"
#import "CameraRecordHistoryViewCell.h"
#import "CameraRecordHistoryViewHeader.h"
#import "CameraRecodHistoryCanlender.h"
#import "CameraSnapshotHistoryViewController.h"
#import "CameraPhotoViewController.h"
#import "KxMovieView.h"

#define kMainScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kMainScreenWidth  [[UIScreen mainScreen] bounds].size.width


@interface CameraRecordHistoryViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *testArray;
@property NSArray *testSectionHeader;
@property NSMutableArray *doubleArrayUrl;
@property KxMovieAlarmRecordViewController *kxvc;

@property (strong,nonatomic) UIButton *buttonFullScreen;
@property (strong,nonatomic) UIButton *buttonClose;
@property (strong,nonatomic) UIButton *buttonPlay;
@property BOOL isFullScreen;

//20151201
@property (strong, nonatomic) IBOutlet UIToolbar *mytoolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barbuttonVideo;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barbuttonSnapshot;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barbuttonModeVideo;
//20160105
@property (strong, nonatomic) IBOutlet UIButton *buttonModeVideo;
@property (strong, nonatomic) IBOutlet UIButton *buttonVideo;
@property (strong, nonatomic) IBOutlet UIButton *buttonSnapshot;
@property UIView *bottomView;

@property Boolean isSnapshotPressing;
@property Boolean isVideoPressing;
@property Boolean isModeVideoPressing;
@property Boolean isKxvcAppear;
//2016 02 16
@property Boolean isEditCollectionViewCell;
@property UIToolbar *toolbarForDelete;
@property Boolean isCollectionAllSelected;
//
@property UIBarButtonItem *selectAll;
//2016 02 26
@property NSTimer *serverSessionTimer;

@end




static NSString *cellID = @"cameraRecordHistoryCell";
static NSString *headerId = @"headerId";
static NSString *footerId = @"footerId";


@implementation CameraRecordHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //2016 02 24 category
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServerSessionOutOfTime) name:@"letuserlogout" object:nil];
    
    NSLog(@"viewDidLoad");
    //fullscreen
    self.isFullScreen = NO;
    //
    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"编辑"
                                 //                                initWithImage:[UIImage imageNamed:@"history-bj"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(editCollectionViewCell)];
    self.navigationItem.rightBarButtonItem = rightBTN;
    
    //2016 01 05 hgc start
    // 添加底部蓝色滑块
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 4, kMainScreenWidth / 3, 4)];
    [self.bottomView setBackgroundColor:[UIColor colorWithRed:0.0 / 255 green:160.0 / 255 blue:226.0 / 255 alpha:1]];
    [self.view addSubview:self.bottomView];
    //2016 01 05 hgc end
    
    
    UIApplication *app = [UIApplication sharedApplication];
    UIInterfaceOrientation currentOrientation = app.statusBarOrientation;
    [self doLayoutForOrientation:currentOrientation];
    
    //2016 02 16
    self.toolbarForDelete = [[UIToolbar alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.toolbarForDelete setAutoresizesSubviews:YES];
    
    self.selectAll = [[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteCell)];
    UIBarButtonItem *fixedSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    UIBarButtonItem *flexibleSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [self.toolbarForDelete setItems:  [NSArray arrayWithObjects:fixedSpace,self.selectAll,flexibleSpace,delete,fixedSpace, nil]];
    //
//    [self.toolbarForDelete setBarStyle:UIBarStyleBlackTranslucent];
    [self.toolbarForDelete setBarTintColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    
    
    [self.view addSubview:self.toolbarForDelete];
    [self.toolbarForDelete setHidden: YES];
    //
    
    //navigationItem
//    self.navigationItem.title = @"历史纪录";
    
// 2015 11 04 hgc 左侧按钮使用系统自带样式 start
//    UIBarButtonItem *leftBTN = [[UIBarButtonItem alloc]
//                                initWithImage:[UIImage imageNamed:@"back"]
//                                style:UIBarButtonItemStylePlain
//                                target:self
//                                action:@selector(cameraRecordCancel)];
//    self.navigationItem.leftBarButtonItem = leftBTN;
// 2015 11 04 hgc 左侧按钮使用系统自带样式 end
    
    //取得当前日期
    if (_titleDate == NULL) {
        _titleDate = [[NSDate alloc]init];
        _titleDate = [NSDate date];
        //取得当前日期前一天的日期
//        NSDate *date = [NSDate date];
//        _titleDate = [NSDate dateWithTimeInterval:-60 * 60 * 24 sinceDate:date];
        NSLog(@"_titleDate==%@",_titleDate);
    }
    //title
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:_titleDate];
 
//    //跳转到日历页面 hgc 2015 11 03
//    CameraRecodHistoryCanlender *cameraRecordHistoryCanlender =
//    [[CameraRecodHistoryCanlender alloc]initWithNibName:@"CameraRecodHistoryCanlender" bundle:nil];
//    
//    [self.navigationController pushViewController:cameraRecordHistoryCanlender animated:YES];
//    
//    //传入inputdate
//    cameraRecordHistoryCanlender.inputDate = _titleDate;
//    cameraRecordHistoryCanlender.deviceID = _deviceID;
//    NSLog(@"去往camera Canlender");
//    //跳转到日历页面 hgc 2015 11 03
    
    
    //getdata for test
//    self.testArray = @[@[@"1",@"2",@"3"],
//                       @[@"5",@"5",@"5"],
//                       @[@"5",@"5",@"5",@"5",@"5"],
//                       @[@"5",@"5",@"5",@"5",@"5"],
//                       @[@"6",@"6",@"6",@"6",@"6"]
//                       ];
//    self.testSectionHeader = @[@"2015年10月14号",
//                               @"2015年10月15号",
//                               @"2015年10月16号",
//                               @"2015年10月17号",
//                               @"2015年10月18号"
//                               ];
    
// 2015 11 03 hgc start
    //设置navigation title
    UIButton *button = [UIButton buttonWithType: UIButtonTypeSystem];
    [button setTitle: strDate forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"System" size:17];
    [button addTarget:self
            action:@selector(selectDate)
            forControlEvents:UIControlEventTouchUpInside
     ];
    [button setImage:[UIImage imageNamed:@"arrow-for-canlendar"] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              button.imageEdgeInsets.top,
                                              110,
                                              button.imageEdgeInsets.bottom,
                                              button.imageView.frame.size.width);

    [button sizeToFit];
    self.navigationItem.titleView = button;
// 2015 11 03 hgc end
// 2015 11 03 hgc start 取消右button
    //设置navigation rightbtn
//    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
//                                 initWithTitle:strDate
//                                style:UIBarButtonItemStylePlain
//                                target:self
//                                action:@selector(selectDate)];
//    self.navigationItem.rightBarButtonItem = rightBTN;
// 2015 11 03 hgc end
    
    NSLog(@"%@",_deviceID);
    
    //构造collectionView
    self.collectionView = (id)[self.view viewWithTag:100];
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.top = 0;
    contentInset.bottom = 40;
    [self.collectionView setContentInset:contentInset];
    
    //collection nib
    UINib *nib = [UINib nibWithNibName:@"CameraRecordHistoryViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:cellID];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    //header nib
    UINib *headerNib = [UINib nibWithNibName:@"CameraRecordHistoryViewHeader" bundle:nil];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
}

- (void)cameraRecordCancel{

    [self.navigationController popViewControllerAnimated:YES];

}


- (void)selectDate{
    NSLog(@"selectDate");
    //remove kxvc
    [self.kxvc.view removeFromSuperview];

    //设置collection contentInset
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.top = 60;
    [self.collectionView setContentInset:contentInset];
    
    //2015 11 03
//    [self.navigationController popViewControllerAnimated:YES];
    
    NSArray *ctrlArray = self.navigationController.viewControllers;
    for (UIViewController *ctrl in ctrlArray){
        if ([ctrl isKindOfClass:[CameraRecodHistoryCanlender class]])
        {
            CameraRecodHistoryCanlender *superVC = ctrl;
                        superVC.deviceID = self.deviceID;
            superVC.inputDate = [NSDate date];
            [self.navigationController popToViewController:superVC animated:YES];
        }
        NSLog(@"ctrl ---- %@", ctrl);
    }
    
    /*hgc 2015 11 03
    CameraRecodHistoryCanlender *cameraRecordHistoryCanlender =
    [[CameraRecodHistoryCanlender alloc]initWithNibName:@"CameraRecodHistoryCanlender" bundle:nil];
    
    [self.navigationController pushViewController:cameraRecordHistoryCanlender animated:YES];
    
    //传入inputdate
    cameraRecordHistoryCanlender.inputDate = _titleDate;
    cameraRecordHistoryCanlender.deviceID = _deviceID;
    NSLog(@"去往camera Canlender");
     *///hgc 2015 11 03
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isVideoPressing = NO;
    self.isSnapshotPressing = NO;
    self.isModeVideoPressing = YES;
    self.isKxvcAppear = NO;
    //2016 02 16
    self.isEditCollectionViewCell = NO;
    self.isCollectionAllSelected = NO;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSLog(@"_titleDate==%@",_deviceID);
    NSLog(@"_titleDate==%@",_titleDate);

    //get data
    if (self.isVideoPressing) {
        [self loadData];
    }else if (self.isSnapshotPressing){
        [self loadDataForSnapshot];
    }else if (self.isModeVideoPressing){
        [self loadDataForModeVideo];
    }
    
    
    if (_titleDate == NULL) {
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *strDate = [dateFormatter stringFromDate:_titleDate];
//        self.navigationItem.rightBarButtonItem.title = strDate;
        self.navigationItem.title = strDate;

    }
    //refresh data 2015 10 21
    NSLog(@"viewDidAppear");
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.serverSessionTimer invalidate];
    
    if (self.isFullScreen) {
        [self closeKXVC];
    }
}


- (void)loadData{
    
    //param
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd"];
    NSString *paramDate = [df stringFromDate:_titleDate];
    
    //getdata
    [DeviceNetworkInterface getCameraRecordHistoryWithDeviceId:_deviceID andDay:paramDate withBlock:^(NSString *result, NSString *message, NSArray *times, NSArray *videos, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
            NSLog(@"times===%@",times);
//            NSLog(@"videos===%@",videos);
            NSLog(@"++++++++++++++++getCameraRecordHistoryWithDeviceId++++++++++++++++");
            self.doubleArrayUrl = [[NSMutableArray alloc]init];
            self.testArray = [[NSMutableArray alloc]init];
            for (NSArray *i in videos ) {
                NSMutableArray *arrayTimes = [[NSMutableArray alloc]init];
                NSMutableArray *arrayUrls = [[NSMutableArray alloc]init];
                for (NSArray *j in i) {
                    NSLog(@"videos==%@",j);
                    NSLog(@"videos==%@",j[0]);
                    [arrayTimes addObject:j[0]];
                    [arrayUrls addObject:j[1]];
                }
                
                [self.testArray addObject:arrayTimes];
                [self.doubleArrayUrl addObject:arrayUrls];
//                NSLog(@"videos==%@",i);
            }
            NSLog(@"self.doubleArrayUrl==%@",self.doubleArrayUrl);
            NSLog(@"self.testArray==%@",self.testArray);
            
            self.testSectionHeader = times;
            [self.collectionView reloadData];
            
            //warning 2015 10 23
//            if (self.testArray.count == 0 ) {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"历史记录" message:@"您所选择的日期没有历史记录" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            }
        }
        else{
            NSLog(@"cameraControlStopwithDeviceId error");
        }
    }];
}

- (void)loadDataForSnapshot{
    
    //param
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd"];
    NSString *paramDate = [df stringFromDate:_titleDate];
    
    //getdata
    [DeviceNetworkInterface getCameraSnapshotHistoryWithDeviceId:_deviceID andDay:paramDate withBlock:^(NSString *result, NSString *message, NSArray *times, NSArray *videos, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
            NSLog(@"times===%@",times);
            //            NSLog(@"videos===%@",videos);
            NSLog(@"++++++++++++++++getCameraRecordHistoryWithDeviceId++++++++++++++++");
            self.doubleArrayUrl = [[NSMutableArray alloc]init];
            self.testArray = [[NSMutableArray alloc]init];
            for (NSArray *i in videos ) {
                NSMutableArray *arrayTimes = [[NSMutableArray alloc]init];
                NSMutableArray *arrayUrls = [[NSMutableArray alloc]init];
                for (NSArray *j in i) {
                    NSLog(@"videos==%@",j);
                    NSLog(@"videos==%@",j[0]);
                    [arrayTimes addObject:j[0]];
//hgc 2015 12 02 photo
                    [arrayUrls addObject:j[1]];
//                    [arrayUrls addObject:@"hello world"];
//hgc 2015 12 02 photo
                }
                
                [self.testArray addObject:arrayTimes];
                [self.doubleArrayUrl addObject:arrayUrls];
                //                NSLog(@"videos==%@",i);
            }
            NSLog(@"self.doubleArrayUrl==%@",self.doubleArrayUrl);
            NSLog(@"self.testArray==%@",self.testArray);
            
            self.testSectionHeader = times;
            [self.collectionView reloadData];
            
            //warning 2015 10 23
//            if (self.testArray.count == 0 ) {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"历史记录" message:@"您所选择的日期没有历史记录" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            }
        }
        else{
            NSLog(@"cameraControlStopwithDeviceId error");
        }
    }];
}
//2015 12 30
- (void)loadDataForModeVideo{
    
    //param
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd"];
    NSString *paramDate = [df stringFromDate:_titleDate];
    
    //getdata
    [DeviceNetworkInterface getCameraModeRecordHistoryWithDeviceId:_deviceID andDay:paramDate withBlock:^(NSString *result, NSString *message, NSArray *times, NSArray *videos, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
            NSLog(@"times===%@",times);
            //            NSLog(@"videos===%@",videos);
            NSLog(@"++++++++++++++++getCameraRecordHistoryWithDeviceId++++++++++++++++");
            self.doubleArrayUrl = [[NSMutableArray alloc]init];
            self.testArray = [[NSMutableArray alloc]init];
            for (NSArray *i in videos ) {
                NSMutableArray *arrayTimes = [[NSMutableArray alloc]init];
                NSMutableArray *arrayUrls = [[NSMutableArray alloc]init];
                for (NSArray *j in i) {
                    NSLog(@"videos==%@",j);
                    NSLog(@"videos==%@",j[0]);
                    [arrayTimes addObject:j[0]];
                    [arrayUrls addObject:j[1]];
                }
                
                [self.testArray addObject:arrayTimes];
                [self.doubleArrayUrl addObject:arrayUrls];
                //                NSLog(@"videos==%@",i);
            }
            NSLog(@"self.doubleArrayUrl==%@",self.doubleArrayUrl);
            NSLog(@"self.testArray==%@",self.testArray);
            
            self.testSectionHeader = times;
            [self.collectionView reloadData];
            
            //warning 2015 10 23
            //            if (self.testArray.count == 0 ) {
            //                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"历史记录" message:@"您所选择的日期没有历史记录" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            //                [alert show];
            //            }
        }
        else{
            NSLog(@"cameraControlStopwithDeviceId error");
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//collection
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CameraRecordHistoryViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    //设置圆角
    cell.layer.cornerRadius = 0.8;
    cell.layer.masksToBounds = YES;
    //取得正在处理的section和row
    NSInteger rowNo = indexPath.row;
    NSInteger sectionNo = indexPath.section;
    
    cell.label.text = self.testArray[sectionNo][rowNo];
//    UIImage *image = [UIImage imageNamed:@"cameraaddtest.jpeg"];
    UIImage *image = [UIImage imageNamed:@"video"];
    UIImage *highlightedImage = [UIImage imageNamed:@"video-down"];
//    cell.image.image = image;
    [cell.image setImage:image];
    [cell.image setHighlightedImage:highlightedImage];
    
    // 2015 12 16 hgc added
    if (self.isSnapshotPressing) {
        
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        // hgc 替换getimageFromURL start
//        [cell.image setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.doubleArrayUrl[section][row]]]]];
        //hgc test 2016 01 20
        MKNetworkEngine *engine = [[MKNetworkEngine alloc]init];
        MKNetworkOperation *operation = [engine operationWithURLString:self.doubleArrayUrl[section][row] params:nil httpMethod:@"GET"];
        //添加完成处理程序
        [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            //请求成功,为_imgView添加图片
            UIImage * testImageMK = [UIImage imageWithData:[completedOperation responseData]];
            //
            [cell.image setImage:testImageMK];
            //
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            //请求出错
            NSLog(@"%@",completedOperation.error);
        }];
        //发起网络请求
        [engine enqueueOperation:operation];
        //hgc test 2016 01 20
        //hgc 替换getimageFromURL end

        [cell.image setHighlightedImage:[UIImage new]];
        
//        NSLog(@"sdfsdfsdfsdimag==%@",self.doubleArrayUrl[section][row]);
    }
    // 2015 12 16 hgc end
    
    //2016 02 16
    if (self.isEditCollectionViewCell) {
        [cell.imageForMulSelect setImage:[UIImage new]];
        NSLog(@"cell notx selected");
        for (NSIndexPath *tempIndexPath in [self.collectionView indexPathsForSelectedItems]) {
            NSLog(@"indexPath====%ld===%ld",(long)indexPath.row,(long)indexPath.section);
            NSLog(@"del == %@",self.doubleArrayUrl[indexPath.section][indexPath.row]);
            if ([tempIndexPath isEqual:indexPath]) {
                NSLog(@"cell selected");
                [cell.imageForMulSelect setImage:[UIImage imageNamed:@"choose"]];
            }
        }
    }else{
        NSLog(@"cell not edit");
        [cell.imageForMulSelect setImage:[UIImage new]];
    }
//    NSLog(@"del array==%@",array);
    //2016 02 16
    return cell;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.testArray[section];
    return array.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.testArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionNo = indexPath.section;
    
    CameraRecordHistoryViewHeader *view;
    //header
    if (kind == UICollectionElementKindSectionHeader) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
//        view.headerLabel.text =self.testSectionHeader[sectionNo];
//        view.headerLabel.text = [NSString stringWithFormat:@"%@日%@时",self.navigationItem.rightBarButtonItem.title,self.testSectionHeader[sectionNo]];
        view.headerLabel.text = [NSString stringWithFormat:@"%@日%@时",self.navigationItem.title,self.testSectionHeader[sectionNo]];
        view.headerLabel.backgroundColor = [UIColor whiteColor];

    }else{
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerId forIndexPath:indexPath];
        view.headerLabel.text = @"FooterView";
    }
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditCollectionViewCell) {
        NSLog(@"select while sortedByMegId");
        CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
        [cell.imageForMulSelect setImage:[UIImage imageNamed:@"choose"]];
        return;
    }
    
    if (self.isSnapshotPressing) {
        NSLog(@"in the photo");
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        NSLog(@"url==%@",self.doubleArrayUrl[section][row]);
        NSLog(@"time==%@",self.testArray[section][row]);
        
        CameraPhotoViewController *vc = [[CameraPhotoViewController alloc]initWithNibName:@"CameraPhotoViewController" bundle:nil];
        
        //2015 12 16 added
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        for (NSArray* single in self.doubleArrayUrl ) {
            [array addObjectsFromArray:single];
        }
        NSLog(@"array==%@",array);
        vc.arrayPhotos = array;
        //2015 12 16 end
        
//        CameraSnapshotHistoryViewController *vc = [[CameraSnapshotHistoryViewController alloc]initWithNibName:@"CameraSnapshotHistoryViewController" bundle:nil];
//        [self.navigationController pushViewController:vc animated:YES];
        [self addChildViewController:vc];
        vc.view.frame = self.view.frame;
        [vc.view setAlpha:0.0f];
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.view addSubview:vc.view];
            [vc.view setAlpha:1.0f];
            [vc.view setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:0.90]];
        } completion:^(BOOL finished) {
            
        }];

        return;
    }
    
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSLog(@"section=====%ld",(long)section);
    NSLog(@"row=====%ld",(long)row);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    //local test start
    NSString *stream = @"/Users/apple2/Desktop/makeup/advertise.mp4";
//    KxMovieViewController *test = [KxMovieViewController movieViewControllerWithContentPath:stream parameters:parameters];
////    KxMovieView *test1 = [KxMovieView movieViewControllerWithContentPath:stream parameters:parameters];
//    [self presentViewController:test animated:YES completion:nil];
    // test end
    //http
//        NSString *stream = @"http://172.16.9.95:82/smarthome/video/8-1video-H264-1";
    //
    
    
    if (self.kxvc != NULL) {
        [self.kxvc.view removeFromSuperview ];
        // 2015 12 23 hgc start
        [self.kxvc removeFromParentViewController];
        // 2015 12 23 hgc ended
    }
    //2016 02 26
    self.serverSessionTimer = [NSTimer scheduledTimerWithTimeInterval:600.0f target:self selector:@selector(serverSessionRefresh) userInfo:nil repeats:YES];
    [self.serverSessionTimer fire];
    //
    self.kxvc = [KxMovieAlarmRecordViewController movieViewControllerWithContentPath:_doubleArrayUrl[section][row] parameters:parameters];
//    self.kxvc = [KxMovieViewController movieViewControllerWithContentPath:stream parameters:parameters];
//    kxvc set
//    [self presentViewController:self.kxvc animated:YES completion:nil];
    [self addChildViewController:self.kxvc];
    self.kxvc.view.frame = CGRectMake(8, 68, self.view.bounds.size.width - 16, 202);
    [self.kxvc toolBarHidden];
    [self.kxvc setAllControlHidden];
    [self.kxvc fullscreenMode:YES];
    [self.kxvc bottomBarAppears];
    [self.view addSubview:self.kxvc.view];
    
//20151202
    self.isKxvcAppear = YES;

    //为kxvc添加一个新view
    if (self.buttonFullScreen == NULL) {
        NSLog(@"self.toolBarView == NUL");
//            self.toolBarView = [[UIView alloc]initWithFrame:CGRectMake(8, self.kxvc.view.frame.size.height + 68 - 50, self.kxvc.view.frame.size.width, 50)];
//        self.toolBarView.backgroundColor = [UIColor colorWithRed:95/255.0 green:95/255.0 blue:95/255.0 alpha:0.5];
        
    //view add button
        self.buttonFullScreen = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30)];
        [self.buttonFullScreen addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonFullScreen setImage:[UIImage imageNamed:@"full-screen"] forState:UIControlStateNormal];
        [self.kxvc.view addSubview:self.buttonFullScreen];

// 2015 11 06 hgc start
// 视频播放按钮
//        self.buttonPlay = [[UIButton alloc]initWithFrame:CGRectMake(10 + 40, self.kxvc.view.frame.size.height - 40, 30, 30)];
//        //        self.buttonFullScreen.backgroundColor = [UIColor redColor];
//        [self.buttonPlay addTarget:self action:@selector(moviePlay) forControlEvents:UIControlEventTouchUpInside];
//        [self.buttonPlay setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
// 2015 11 06 hgc end

    }else{
        NSLog(@"toolBarView setHidden:NO");
        [self.kxvc.view addSubview:self.buttonFullScreen];
    }
// 2015 11 10 hgc start
    self.buttonClose = [[UIButton alloc]initWithFrame:CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30)];
    [self.buttonClose setImage:[UIImage imageNamed:@"close-record"] forState:UIControlStateNormal];
    [self.buttonClose addTarget:self action:@selector(closeKXVC) forControlEvents:UIControlEventTouchUpInside];
    [self.kxvc.view addSubview:self.buttonClose];
// 2015 11 10 hgc end
    
    
//设置collectionView的位置
    [self.collectionView setNeedsLayout];

    [UIView animateWithDuration:0.5f animations:^{
        UIEdgeInsets contentInset = self.collectionView.contentInset;
        contentInset.top = roundf(self.kxvc.view.frame.size.height) + 60;
        [self.collectionView setContentInset:contentInset];
    } completion:^(BOOL finished) {
        [self.collectionView setScrollsToTop:YES];
    }];
    
    //hgc 2015 1026
//    self.collectionView.bounds =CGRectMake(self.collectionView.bounds.origin.x,
//                                          [UIScreen mainScreen].bounds.origin.y - roundf(self.kxvc.view.frame.size.height) - 60,
//                                          self.collectionView.bounds.size.width,
//                                           self.collectionView.bounds.size.height
//                                           );
    NSLog(@"roundf(self.kxvc.view.frame.size.height)==%f",[UIScreen mainScreen].bounds.size.height - roundf(self.kxvc.view.frame.size.height) - 60);

//    [self.collectionView setScrollsToTop:YES];
//    [self.collectionView setScrollEnabled:YES];
//        self.collectionView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    [self.view layoutIfNeeded];
    
//    [self.collectionView reloadData];

}

- (void)moviePlay{
    NSLog(@"play");
    if ([self.kxvc isEndOfFile]) {
        self.kxvc = [self.kxvc movieReplay];
    }
    if ([self.kxvc playing]) {
        [self.kxvc pause];
        [self.buttonPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [self.kxvc play];
        [self.buttonPlay setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    
}

- (void)closeKXVC{
    NSLog(@"closeKXVC");
    //2016 02 26
    [self.serverSessionTimer invalidate];
    
    if (self.isFullScreen){
        //status bar
        self.isFullScreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = NO;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        //
        self.kxvc.view.frame = CGRectMake(8, 68, self.view.bounds.size.width - 16, 202);
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30);
    }
    
    if (self.kxvc != NULL) {
        [self.kxvc.view removeFromSuperview ];
        //2015 12 22 hgc
        // 2015 12 23 hgc start
        [self.kxvc removeFromParentViewController];
        // 2015 12 23 hgc ended
        
        [self.kxvc testClose];
        self.isKxvcAppear = NO;
    }
    [self.collectionView setNeedsLayout];
    [UIView animateWithDuration:0.5f animations:^{
        UIEdgeInsets contentInset = self.collectionView.contentInset;
        contentInset.top = self.collectionView.contentInset.top -  roundf(self.kxvc.view.frame.size.height);
        [self.collectionView setContentInset:contentInset];
    }completion:^(BOOL finished) {
        [self.collectionView setScrollsToTop:YES];
    }];

    [self.view layoutIfNeeded];
}


- (void)fullScreen
{
    NSLog(@"setfullScreen");
    if (self.isFullScreen) {
        //status bar
        self.isFullScreen = NO;
        //2016 03 02
        [self.kxvc setfullScreenOff];
        
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = NO;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        //
        self.kxvc.view.frame = CGRectMake(8, 68, self.view.bounds.size.width - 16, 202);
        //
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);
        //2016 03 01 start hgc
        [self.buttonFullScreen setImage:[UIImage imageNamed:@"full-screen"] forState:UIControlStateNormal];
        //2016 03 01 end hgc
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.width - 40, 10, 30, 30);
        
        
    }else{
        //status bar
        self.isFullScreen = YES;
        
        //2016 03 02
        [self.kxvc setfullScreenOn];
        
        [self setNeedsStatusBarAppearanceUpdate];
        //
        self.navigationController.navigationBarHidden = YES;
        //
        self.kxvc.view.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
        //
        self.kxvc.view.frame = self.view.frame;
//        self.toolBarView.frame = CGRectMake(0, self.kxvc.view.frame.size.height - 50, self.kxvc.view.frame.size.width, 50);
        self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.height - 40 ,self.kxvc.view.frame.size.width - 40, 30, 30);
        //2016 03 01 start hgc
        [self.buttonFullScreen setImage:[UIImage imageNamed:@"expand-icon"] forState:UIControlStateNormal];
        //2016 03 01 end hgc
        NSLog(@"self.kxvc.view.frame.size.width==%f",self.kxvc.view.frame.size.width);
        NSLog(@"self.kxvc.view.frame.size.height==%f",self.kxvc.view.frame.size.height);
        self.buttonClose.frame =CGRectMake(self.kxvc.view.frame.size.height - 40, 10, 30, 30);
    }
}

- (BOOL)prefersStatusBarHidden{
    if (self.isFullScreen) {
        return YES;
    }else{
        return NO;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self doLayoutForOrientation:toInterfaceOrientation];
}

- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self layoutPortrait];
    } else {
        [self layoutLandscape];
    }
}

- (void)layoutPortrait {
    NSLog(@"layoutPortrait");
    self.navigationController.navigationBarHidden = NO;
    self.kxvc.view.frame = CGRectMake(8, 68, self.view.bounds.size.width - 16, 202);
    
    //view add button
    self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);
}

- (void)layoutLandscape {
    NSLog(@"layoutLandscape");
    
    self.navigationController.navigationBarHidden = YES;
    self.kxvc.view.frame = self.view.frame;
    
    //
    self.buttonFullScreen.frame = CGRectMake(self.kxvc.view.frame.size.width - 40 , self.kxvc.view.frame.size.height - 40, 30, 30);

}

//20151201 hgc
- (IBAction)barbuttonVideoPressed:(id)sender {
    //
    self.isModeVideoPressing = NO;
    self.isSnapshotPressing = NO;
    //
    if (self.isVideoPressing) {
        NSLog(@"do nothing");
    }else{
        NSLog(@"refresh data for video");
        [self.buttonSnapshot setImage:[UIImage imageNamed:@"camera_history_photo_prohibt"] forState:UIControlStateNormal];
        [self.buttonSnapshot setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //
        [self.buttonVideo setImage:[UIImage imageNamed:@"camera_history_video_down"] forState:UIControlStateNormal];
        [self.buttonVideo setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
        //
        [self.buttonModeVideo setImage:[UIImage imageNamed:@"camera_history_video_prohibt"] forState:UIControlStateNormal];
        [self.buttonModeVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //2016 01 13 zhushi
//        if (self.isKxvcAppear) {
//            [self closeKXVC];
//        }
        //
        self.isVideoPressing = !self.isVideoPressing;
        //
        [self loadData];
        [self.collectionView reloadData];
        //
        // 设置底部滑动条 2016 01 05
        CGRect frame = CGRectMake(kMainScreenWidth / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
        self.bottomView.frame = frame;
    }
    
    
}
- (IBAction)barbuttonSnapshotPressed:(id)sender {
    //
    self.isModeVideoPressing = NO;
    self.isVideoPressing = NO;
    //
    if (!self.isSnapshotPressing) {
        NSLog(@"refresh data for photo");
        [self.buttonSnapshot setImage:[UIImage imageNamed:@"camera_history_photo_down"] forState:UIControlStateNormal];
        [self.buttonSnapshot setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
        //
        [self.buttonVideo setImage:[UIImage imageNamed:@"camera_history_video_prohibt"] forState:UIControlStateNormal];
        [self.buttonVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

        //
        [self.buttonModeVideo setImage:[UIImage imageNamed:@"camera_history_video_prohibt"] forState:UIControlStateNormal];
        [self.buttonModeVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //
        if (self.isKxvcAppear) {
            [self closeKXVC];
        }
        NSLog(@"self.kxvc isBeingPresented===%d",self.kxvc.isBeingPresented);
        NSLog(@"self.kxvc isBeingPresented===%d",self.kxvc.isBeingDismissed);
        //
        [self loadDataForSnapshot];
        //
        self.isSnapshotPressing = !self.isSnapshotPressing;
        //
        // 设置底部滑动条 2016 01 05
        CGRect frame = CGRectMake(kMainScreenWidth * 2 / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
        self.bottomView.frame = frame;
        
    }else{
        NSLog(@"do nothing");
    }
}
//2015 12 30
- (IBAction)barbuttonModeVideoPressed:(id)sender {
    //
    self.isVideoPressing = NO;
    self.isSnapshotPressing = NO;
    //
    NSLog(@"mode");
    if (self.isModeVideoPressing) {
        NSLog(@"do nothing");
    }else{
        NSLog(@"refresh data for video");
        [self.buttonSnapshot setImage:[UIImage imageNamed:@"camera_history_photo_prohibt"] forState:UIControlStateNormal];
        [self.buttonSnapshot setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //
        [self.buttonVideo setImage:[UIImage imageNamed:@"camera_history_video_prohibt"] forState:UIControlStateNormal];
        [self.buttonVideo setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //
        [self.buttonModeVideo setImage:[UIImage imageNamed:@"camera_history_video_down"] forState:UIControlStateNormal];
        [self.buttonModeVideo setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
        //2016 01 13 zhushi
//        if (self.isKxvcAppear) {
//            [self closeKXVC];
//        }
        //
        self.isModeVideoPressing = !self.isModeVideoPressing;
        //
        [self loadDataForModeVideo];

        // 设置底部滑动条 2016 01 05
        CGRect frame = CGRectMake(0, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
        self.bottomView.frame = frame;
    }
    
}



- (IBAction)switchViews:(id)sender {
    [UIView beginAnimations:@"View Flip" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    if (!self.yellowViewController.view.superview) {
//        if (!self.yellowViewController) {
//            self.yellowViewController = [self.storyboard
//                                         instantiateViewControllerWithIdentifier:@"Yellow"];
//        }
//        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
//                               forView:self.view cache:YES];
//        [self.blueViewController.view removeFromSuperview];
//        [self.view insertSubview:self.yellowViewController.view atIndex:0];
//    } else {
//        if (!self.blueViewController) {
//            self.blueViewController = [self.storyboard
//                                       instantiateViewControllerWithIdentifier:@"Blue"];
//        }
//        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
//                               forView:self.view cache:YES];
//        [self.yellowViewController.view removeFromSuperview];
//        [self.view insertSubview:self.blueViewController.view atIndex:0];
//    }
    [UIView commitAnimations];
}

- (void)tabButtonHidden{
    [self.buttonModeVideo setHidden:YES];
    [self.buttonVideo setHidden:YES];
    [self.buttonSnapshot setHidden:YES];
    [self.bottomView setHidden:YES];
    [self.toolbarForDelete setHidden:NO];
}

- (void)tabButtonAppear{
    [self.buttonModeVideo setHidden:NO];
    [self.buttonVideo setHidden:NO];
    [self.buttonSnapshot setHidden:NO];
    [self.bottomView setHidden:NO];
    [self.toolbarForDelete setHidden:YES];
    self.isCollectionAllSelected = NO;
    [self.selectAll setTitle:@"全选"];
}

- (void)editCollectionViewCell{
    NSLog(@"editCollectionViewCell");
    if (self.isEditCollectionViewCell) {
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
        [self tabButtonAppear];
        self.collectionView.allowsMultipleSelection = NO;
        //
        for (int i = 0; i< self.collectionView.numberOfSections; i++) {
            NSLog(@"section===%d",i);
            NSLog(@"rows count==%ld",(long)[self.collectionView numberOfItemsInSection:i]);
            for (int j = 0 ; j < [self.collectionView numberOfItemsInSection:i]; j++) {
                NSLog(@"row==%d",j);
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.imageForMulSelect setImage:[UIImage new]];
            }
        }
    }else{
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        [self tabButtonHidden];
        self.collectionView.allowsMultipleSelection = YES;
//deselect
        //2016 02 22
        for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
            NSLog(@"deselect indexPath====%ld===%ld",(long)indexPath.row,(long)indexPath.section);
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }

        //
        for (int i = 0; i< self.collectionView.numberOfSections; i++) {
            NSLog(@"section===%d",i);
            NSLog(@"rows==%ld",(long)[self.collectionView numberOfItemsInSection:i]);
            for (int j = 0 ; j < [self.collectionView numberOfItemsInSection:i]; j++) {
                NSLog(@"row==%d",j);
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.imageForMulSelect setImage:[UIImage new]];
            }
        }
    }
    self.isEditCollectionViewCell = !self.isEditCollectionViewCell;
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isEditCollectionViewCell) {
        CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
        [cell.imageForMulSelect setImage:[UIImage new]];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"se indexPath==%d",indexPath.row);
    
    if (self.isEditCollectionViewCell) {
//        CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
//        [cell.imageForMulSelect setImage:[UIImage imageNamed:@"check-down"]];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"de indexPath==%d",indexPath.row);
//    CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
//    [cell.imageForMulSelect setImage:[UIImage imageNamed:@"check"]];
    return YES;
}

- (void)selectAllCell:(id)sender {
    NSLog(@"selelct all cell");
    NSIndexPath *indexPath;
    if (self.isCollectionAllSelected) {
        //取消全选
        self.isCollectionAllSelected = !self.isCollectionAllSelected;
//        [sender setTitle:@"全选"];
        [self.selectAll setTitle:@"全选"];
        for (int i = 0; i< self.collectionView.numberOfSections; i++) {
            NSLog(@"section===%d",i);
            NSLog(@"rows==%ld",(long)[self.collectionView numberOfItemsInSection:i]);
            for (int j = 0 ; j < [self.collectionView numberOfItemsInSection:i]; j++) {
                NSLog(@"row==%d",j);
                indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                //                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
                CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.imageForMulSelect setImage:[UIImage new]];
            }
        }
    }else{
        //全选
        self.isCollectionAllSelected = !self.isCollectionAllSelected;
//        [sender setTitle:@"取消"];
        [self.selectAll setTitle:@"取消全选"];
        for (int i = 0; i< self.collectionView.numberOfSections; i++) {
            NSLog(@"section===%d",i);
            NSLog(@"rows==%ld",(long)[self.collectionView numberOfItemsInSection:i]);
            for (int j = 0 ; j < [self.collectionView numberOfItemsInSection:i]; j++) {
                NSLog(@"row==%d",j);
                indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                CameraRecordHistoryViewCell *cell =  [self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.imageForMulSelect setImage:[UIImage imageNamed:@"choose"]];
            }
        }
    }
    NSLog(@"over");
}

- (void)deleteCell{
    NSLog(@"deleteCell");
    NSLog(@"del.....");
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"文件删除"
                                 message:@"文件删除后将不可恢复。确定要进行删除吗？"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                      handler:^(UIAlertAction * action) {
                                          return;
                                      }];
    UIAlertAction* commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        NSIndexPath *indexPath;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (indexPath in [self.collectionView indexPathsForSelectedItems]) {
            NSLog(@"indexPath====%ld===%ld",(long)indexPath.row,(long)indexPath.section);
            NSLog(@"del == %@",self.doubleArrayUrl[indexPath.section][indexPath.row]);
            [array addObject:self.doubleArrayUrl[indexPath.section][indexPath.row]];
            
            //        NSMutableArray *temp = self.doubleArrayUrl[indexPath.section];
            //        [temp removeObject:temp[indexPath.row]];
            //        //
            //        NSMutableArray *temp1 = self.testArray[indexPath.section];
            //        [temp1 removeObject:temp1[indexPath.row]];
        }
        //tableview delete
        //    [self.collectionView deleteItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
        
        NSLog(@"del array==%@",array);
        //
        //server delete
        //
        [DeviceNetworkInterface delHistoryRecordSnapshotWithPaths:array withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                if ([result isEqualToString:@"success"]) {
                    NSLog(@"success");
                    
                    //get data
                    if (self.isVideoPressing) {
                        [self loadData];
                    }else if (self.isSnapshotPressing){
                        [self loadDataForSnapshot];
                    }else if (self.isModeVideoPressing){
                        [self loadDataForModeVideo];
                    }
                    
                }else{
                    NSLog(@"false");
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"删除文件失败" message:message delegate:self
                                                         cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            }
            else{
                NSLog(@"delAlarmMsgWithMsgIds error");
            }
        }];
    }];
    [alert addAction:defaultAction];
    [alert addAction:commitAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    //
}

@end
