

#import <UIKit/UIKit.h>
#import<AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>  
@interface AudioViewController : UIViewController


<AVAudioPlayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImageView* rootImageView;
   
    AVAudioPlayer* audioPlayer;

    UIButton* leftButton;
    UIButton* rightButton;
    UIButton* playButton;
    double      volume;
    UILabel*    nameLabel;
    UILabel*    timeLabel;
    UISlider*   processSlider;
    //UISlider*   volumeSlider;
    MPVolumeView        *volumeView;
    NSTimer*    processTimer;
    NSTimer*    volumeHideTimer;
    id playbackTimeObserver;
}
     ;
@property (nonatomic,assign) NSInteger songIndex;
@property (nonatomic, strong) NSMutableArray *playerURL;
@property (nonatomic, strong) NSMutableArray *audioName;
@property (nonatomic, strong) NSMutableArray *netOrLocalArray;
@property (nonatomic, strong) NSString       *netOrLocalFlag;
@property (nonatomic, strong) NSMutableArray *picURL;
@property  BOOL isOpenFromAppList; // 从首页进入为no 从app列表进入为yes

-(void)loadMusic:(NSString*) filePath netOrLocalFlag:(NSString *) netOrLocalFlag netOrLocalArrValue:(NSString*) netOrLocalArrValue;

@end
