//
//  IdLoginHandlerDelegate.h
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/30.
//  Copyright © 2015年 riqiao. All rights reserved.
//

@protocol LoginHandlerDelegate <NSObject>
- (void)handlerDidReceiveData:(NSString *) handlerReturnIP;
- (void)handlerDidNotSendDataWithTag;
- (void)handlerDidNotReceiveDataWithTag;
- (void)handlerDidSendDataWithTag;
- (void)handlerOnUdpSocketDidClose;
@end