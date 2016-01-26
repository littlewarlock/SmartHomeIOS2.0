

#import "AudioViewController.h"
#import "FileTools.h"

@implementation AudioViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(viewInit)];
    [self performSelector:@selector(setTimeLable)];
    //  songIndex= [_songIndexNsNUM intValue];
}

-(void)viewInit
{
    self.picURL = [[NSMutableArray alloc] init];
    for(int i=0;i<self.playerURL.count;i++){
        NSString *url =  [self.playerURL objectAtIndex:i];
        NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:url]];
        UIImage *image = [audioDataDic objectForKey:@"Artwork"];
        if (image) {
            [self.picURL addObject:image];
        }else{
            [self.picURL addObject:[UIImage imageNamed:@"audio_default"]];
        }
    }
    
//    NSEnumerator *enumerator = [self.playerURL keyEnumerator];
//    id key;
//    while ((key = [enumerator nextObject])) {
//        FileInfo *fileinfo = (FileInfo*)[self.tableDataDic objectForKey:key];
//        if([picArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
//            [pics addObject:fileinfo.fileUrl];
//        }else if([audioArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
//            [audiosUrl addObject:fileinfo.fileUrl];
//            NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:fileinfo.fileUrl]];
//            UIImage *image = [audioDataDic objectForKey:@"Artwork"];
//            if (image) {
//                [audioPlayerThumbsArray addObject:image];
//            }else{
//                [audioPlayerThumbsArray addObject:[UIImage imageNamed:@"audio_default"]];
//            }
//        }
//    }

    
    
    CGFloat SCREEN_HEIGHT =  [UIScreen mainScreen].bounds.size.height;
    CGFloat SCREEN_WIDTH  =  [UIScreen mainScreen].bounds.size.width;
    
    self.navigationController.navigationBarHidden = YES;
    rootImageView= [[UIImageView alloc] initWithFrame: self.view.bounds];
    rootImageView.frame = CGRectMake(self.view.bounds.origin.x,self.view.bounds.origin.y,SCREEN_WIDTH,SCREEN_HEIGHT*5/8);
    if([self.picURL objectAtIndex:self.songIndex]!=nil ){
        if(![[self.picURL objectAtIndex:self.songIndex] isKindOfClass:[UIImage class]]){
            NSURL *imgURL = [NSURL fileURLWithPath:[self.picURL objectAtIndex:self.songIndex]];
            NSData * data = [NSData dataWithContentsOfURL:imgURL];
            rootImageView.image =[UIImage imageWithData:data];
        }else{
            rootImageView.image = [self.picURL objectAtIndex:self.songIndex];
        }
    }else{
        
//        NSURL *imgURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sea" ofType:@"png"]];
//        
//        
//        
//        NSData * data = [NSData dataWithContentsOfURL:imgURL];
        rootImageView.image =[UIImage imageNamed:@"sea"];
    }
    
    [self.view addSubview:rootImageView];
    
    
    
    UIButton* button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(10, 30, 32, 32);
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    //[button setTitle:@"返回" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.5]];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:10.0];
//    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(SCREEN_WIDTH/2 -30, SCREEN_HEIGHT*7/8, 60, 50);
    //[button setTitle:@"播放" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    
    button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(SCREEN_WIDTH*2/8 -30, SCREEN_HEIGHT*7/8, 60, 50);
    //[button setTitle:@"上一首" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(prier) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    leftButton=button;
    
    [self.view addSubview:button];
    
    button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(SCREEN_WIDTH*6/8-30,SCREEN_HEIGHT*7/8, 60, 50);
    //[button setTitle:@"下一首" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    rightButton=button;
    [self.view addSubview:button];
    
    button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(10, SCREEN_HEIGHT*11/16, 40, 40);
    //[button setTitle:@"音量" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"labalan"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showVolume) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    nameLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*11/16, SCREEN_WIDTH, 30)];
    nameLabel.font= [UIFont systemFontOfSize:25];
    nameLabel.textAlignment= NSTextAlignmentCenter;
    nameLabel.textColor= [UIColor blueColor];
    nameLabel.numberOfLines=0;
    nameLabel.backgroundColor= [UIColor clearColor];
    nameLabel.text= [self.audioName objectAtIndex:self.songIndex];
    [self.view addSubview:nameLabel];
    
    timeLabel= [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*5/8, SCREEN_HEIGHT*13/16-12, 100, 30)];
    timeLabel.font= [UIFont systemFontOfSize:10];
    timeLabel.textAlignment= NSTextAlignmentCenter;
    timeLabel.textColor= [UIColor blackColor];
    timeLabel.numberOfLines=0;
    timeLabel.backgroundColor= [UIColor clearColor];
    [self.view addSubview:timeLabel];
    
    
    processSlider= [[UISlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT*13/16, SCREEN_WIDTH*4/8, 5)];
    processSlider.maximumValue=100;
    processSlider.minimumValue=0;
    processSlider.value=0;
    processSlider.continuous=NO;
    [processSlider addTarget:self action:@selector(processSet:) forControlEvents:UIControlEventValueChanged];
    [processSlider addTarget:self action:@selector(processTimerStop) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview: processSlider];
    

    volumeView = [[MPVolumeView alloc]initWithFrame:CGRectMake(-82, SCREEN_HEIGHT*3/8, SCREEN_HEIGHT*3/8, 20)];
    
    //volumeSlider= [[UISlider alloc] initWithFrame:CGRectMake(-85, SCREEN_HEIGHT*4/8, SCREEN_HEIGHT*4/8, 5)];
    //volumeSlider.maximumValue=1;
    //volumeSlider.minimumValue=0;
    //volumeSlider.value= 0.5;
    //volumeSlider.hidden=YES;
    volumeView.hidden=YES;
    //[volumeSlider addTarget:self action:@selector(volumeSet:) forControlEvents:UIControlEventValueChanged];
    volumeView.transform= CGAffineTransformMakeRotation(-90* M_PI/180);
    //volumeSlider.transform= CGAffineTransformMakeRotation(-90* M_PI/180);
    //[self.view addSubview:volumeSlider];
    [self.view addSubview:volumeView];
    processTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
    volume = 0.5;
    if([self.netOrLocalFlag isEqualToString:@"2"]){
        [self loadMusic:[self.playerURL objectAtIndex:self.songIndex] netOrLocalFlag:self.netOrLocalFlag netOrLocalArrValue:[self.netOrLocalArray objectAtIndex:self.songIndex] ];
    }else{
        [self loadMusic:[self.playerURL objectAtIndex:self.songIndex] netOrLocalFlag:self.netOrLocalFlag netOrLocalArrValue:@"" ];
    }
    
    if([self.picURL objectAtIndex:self.songIndex]!=nil ){
        if(![[self.picURL objectAtIndex:self.songIndex] isKindOfClass:[UIImage class]]){
            NSURL *imgURL = [NSURL fileURLWithPath:[_picURL objectAtIndex:self.songIndex]];
            NSData * data = [NSData dataWithContentsOfURL:imgURL];
            rootImageView.image =[UIImage imageWithData:data];
        }else{
            rootImageView.image = [self.picURL objectAtIndex:self.songIndex];
        }
    }else{
        
//        NSURL *imgURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sea" ofType:@"png"]];
//        NSData * data = [NSData dataWithContentsOfURL:imgURL];
        rootImageView.image =[UIImage imageNamed:@"sea"];
    }
    
    UILongPressGestureRecognizer* rightLongPress= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rightLongPress:)];
    [rightButton addGestureRecognizer:rightLongPress];
    
    UILongPressGestureRecognizer* leftLongPress= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(leftLongPress:)];
    [leftButton addGestureRecognizer:leftLongPress];
    
    [audioPlayer play];
}
-(void)processSet:(UISlider*)slider
{
    
    processTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(process) userInfo:nil repeats:YES];
    audioPlayer.currentTime=slider.value/100*audioPlayer.duration;
    if(audioPlayer.playing==YES)
        [audioPlayer playAtTime:audioPlayer.currentTime];
    
    [self performSelector:@selector(setTimeLable)];
}

-(void)setTimeLable{
    NSInteger currTime=round(audioPlayer.currentTime);
    int value_h= currTime%(60*60)/60/60;
    int value_m= currTime%(60*60)/60%60;
    int value_s= currTime%(60*60)%60%60;
    
    
    NSString *hourString;
    NSString *minString;
    NSString *secString;
    
    if (value_h<10){
        hourString=[NSString stringWithFormat:@"0%d:",value_h];
    }
    else {
        hourString=[NSString stringWithFormat:@"%d:",value_h];
    }
    
    if (value_m<10){
        minString=[NSString stringWithFormat:@"0%d:",value_m];
    }
    else {
        minString=[NSString stringWithFormat:@"%d:",value_m];
    }
    
    if (value_s<10){
        secString=[NSString stringWithFormat:@"0%d",value_s];
    }
    else {
        secString=[NSString stringWithFormat:@"%d",value_s];
    }
    
    //当前播放时间字符串MM:SS
    NSString *nowCurrTime=[hourString stringByAppendingString:minString];
    nowCurrTime=[nowCurrTime stringByAppendingString:secString];
    
    
    NSInteger totalSecond = audioPlayer.duration;
    int total_value_h= totalSecond%(60*60)/60/60;
    int total_value_m= totalSecond%(60*60)/60%60;
    int total_value_s= totalSecond%(60*60)%60%60;
    NSString *totalHourString;
    NSString *totalMinString;
    NSString *totalSecString;
    
    if (total_value_h<10){
        totalHourString=[NSString stringWithFormat:@"0%d:",total_value_h];
    }
    else {
        totalHourString=[NSString stringWithFormat:@"%d:",total_value_h];
    }
    
    if (total_value_m<10){
        totalMinString=[NSString stringWithFormat:@"0%d:",total_value_m];
    }
    else {
        totalMinString=[NSString stringWithFormat:@"%d:",total_value_m];
    }
    
    if (total_value_s<10){
        totalSecString=[NSString stringWithFormat:@"0%d",total_value_s];
    }
    else {
        totalSecString=[NSString stringWithFormat:@"%d",total_value_s];
    }
    
    //当前播放时间字符串MM:SS
    NSString *totalTimeStr=[totalHourString stringByAppendingString:totalMinString];
    totalTimeStr=[totalTimeStr stringByAppendingString:totalSecString];
    
    
    timeLabel.text = [NSString stringWithFormat:@"%@/%@",nowCurrTime,totalTimeStr];
}



-(void)processTimerStop
{
    [processTimer invalidate];
}
-(void)rightLongPress:(UILongPressGestureRecognizer*)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan)
        return;
    
    
    if(audioPlayer.playing)
    {
        if(audioPlayer.currentTime>audioPlayer.duration-5)
            audioPlayer.currentTime=audioPlayer.currentTime;
        else
            audioPlayer.currentTime+=5;
        
        [audioPlayer playAtTime:audioPlayer.currentTime];
        
        
    }
}

-(void)leftLongPress:(UILongPressGestureRecognizer*)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan)
        return;
    
    
    if(audioPlayer.playing)
    {
        if(audioPlayer.currentTime<5)
            audioPlayer.currentTime=0;
        else
            audioPlayer.currentTime-=5;
        
        [audioPlayer playAtTime:audioPlayer.currentTime];
    }
    
}

- (void)backAction:(id)sender {
    [audioPlayer stop];
    self.navigationController.navigationBarHidden = NO;
    if (self.isOpenFromAppList){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    
    
}
//封装系统加载函数

-(void)loadMusic:(NSString*)filePath netOrLocalFlag:(NSString*)netOrLocalFlag netOrLocalArrValue:(NSString*) netOrLocalArrValue{
    
    if([netOrLocalFlag isEqualToString:@"1"]){
        NSURL* url = [NSURL fileURLWithPath:filePath];
        audioPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    }else if([netOrLocalFlag isEqualToString:@"0"]){
        NSURL* url=[NSURL URLWithString:filePath];
        NSData *nsdata=[[NSData alloc]initWithContentsOfURL:url];
        audioPlayer=[[AVAudioPlayer alloc]initWithData:nsdata error:nil];
    }else if([netOrLocalFlag isEqualToString:@"2"]){
        if([netOrLocalArrValue isEqualToString:@"1"]){
            NSURL* url = [NSURL fileURLWithPath:filePath];
            audioPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        }else if([netOrLocalArrValue isEqualToString:@"0"]){
            
            NSURL* url=[NSURL URLWithString:filePath];
            NSData *nsdata=[[NSData alloc]initWithContentsOfURL:url];
            audioPlayer=[[AVAudioPlayer alloc]initWithData:nsdata error:nil];
        }
    }
    
    
    audioPlayer.delegate=self;
    audioPlayer.volume= volume;
    
    [audioPlayer prepareToPlay];
    
    
}
//播放完成自动切换
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self next];
}
//音量设置
-(void)volumeSet:(UISlider*)slider
{
    audioPlayer.volume= slider.value;
}
-(void)showVolume
{
    volumeView.hidden=NO;
    //volumeSlider.hidden=NO;
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideVolume) userInfo:nil repeats:NO];
}
-(void)hideVolume
{
    volumeView.hidden=YES;
    //volumeSlider.hidden=YES;
}
//歌曲进度
-(void)process
{
    processSlider.value= 100*audioPlayer.currentTime/audioPlayer.duration;
    [self performSelector:@selector(setTimeLable)];
    
}
//播放
-(void)play:(UIButton*)button
{
    
    if(audioPlayer.playing)
    {
        [button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [audioPlayer pause];
    }
    
    else
    {
        [button setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
        [audioPlayer play];
    }
    
}
//上一首
-(void)prier
{
    BOOL playFlag;
    if(audioPlayer.playing)
    {
        playFlag=YES;
        [audioPlayer stop];
    }
    else
    {
        playFlag=NO;
    }
    _songIndex--;
    if(_songIndex<0){
        _songIndex= _playerURL.count-1;
    }
    
    if([_netOrLocalFlag isEqualToString:@"2"]){
        [self loadMusic:[_playerURL objectAtIndex:_songIndex] netOrLocalFlag:_netOrLocalFlag netOrLocalArrValue:[_netOrLocalArray objectAtIndex:_songIndex] ];
    }else{
        [self loadMusic:[_playerURL objectAtIndex:_songIndex] netOrLocalFlag:_netOrLocalFlag netOrLocalArrValue:@"" ];
    }
    
    nameLabel.text= [_audioName objectAtIndex:_songIndex];
    
    if([_picURL objectAtIndex:_songIndex]!=nil ){
        if(![[_picURL objectAtIndex:_songIndex] isKindOfClass:[UIImage class]]){
            NSURL *imgURL = [NSURL fileURLWithPath:[_picURL objectAtIndex:_songIndex]];
            NSData * data = [NSData dataWithContentsOfURL:imgURL];
            rootImageView.image =[UIImage imageWithData:data];
        }else{
            rootImageView.image = [_picURL objectAtIndex:_songIndex];
        }
    }else{
        
//        NSURL *imgURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sea" ofType:@"png"]];
//        NSData * data = [NSData dataWithContentsOfURL:imgURL];
        rootImageView.image =[UIImage imageNamed:@"sea"];
    }
    
    if(playFlag==YES)
    {
        [audioPlayer play];
    }
    
}
//下一首
-(void)next
{
    BOOL playFlag;
    if(audioPlayer.playing)
    {
        playFlag=YES;
        [audioPlayer stop];
    }
    else{
        playFlag=NO;
    }
    _songIndex++;
    if(_songIndex==_playerURL.count){
        _songIndex= 0;
    }
    
    if([_netOrLocalFlag isEqualToString:@"2"]){
        [self loadMusic:[_playerURL objectAtIndex:_songIndex] netOrLocalFlag:_netOrLocalFlag netOrLocalArrValue:[_netOrLocalArray objectAtIndex:_songIndex] ];
    }else{
        [self loadMusic:[_playerURL objectAtIndex:_songIndex] netOrLocalFlag:_netOrLocalFlag netOrLocalArrValue:@"" ];
    }
    nameLabel.text= [_audioName objectAtIndex:_songIndex];
    
    if([_picURL objectAtIndex:_songIndex]!=nil ){
        if(![[_picURL objectAtIndex:_songIndex] isKindOfClass:[UIImage class]]){
            NSURL *imgURL = [NSURL fileURLWithPath:[_picURL objectAtIndex:_songIndex]];
            NSData * data = [NSData dataWithContentsOfURL:imgURL];
            rootImageView.image =[UIImage imageWithData:data];
        }else{
            rootImageView.image = [_picURL objectAtIndex:_songIndex];
        }
    }else{
        
//        NSURL *imgURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sea" ofType:@"png"]];
//        NSData * data = [NSData dataWithContentsOfURL:imgURL];
        rootImageView.image =[UIImage imageNamed:@"sea"];
    }
    if(playFlag==YES)
    {
        [audioPlayer play];
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate {
    return NO;
}



@end
