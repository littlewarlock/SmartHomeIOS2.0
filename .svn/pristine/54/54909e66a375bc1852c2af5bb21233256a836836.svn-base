//
//  IdLoginHandler.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/30.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "LoginHandlerDelegate.h"
@interface LoginHandler : NSObject
@property (strong, nonatomic) AsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSMutableArray* ipArray;
@property (strong, nonatomic) NSString *postLoginIp;//提交的ip
@property (strong, nonatomic) id<LoginHandlerDelegate> loginHandlerDelegate;

-(void)sendSearchBroadcast: (NSString *) localHost;
@end
