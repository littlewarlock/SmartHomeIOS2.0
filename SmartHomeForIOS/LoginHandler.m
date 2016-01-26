//
//  IdLoginHandler.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/30.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "LoginHandler.h"
#import "GTMBase64.h"


@implementation LoginHandler

-(void)sendSearchBroadcast: (NSString *) localHost{
    //发广播查询输入id是否有匹配ip
    [self sendToUDPServer:@"SMARTHOMEv1.0" address:localHost port:9999];
}

-(void)sendToUDPServer:(NSString*) msg address:(NSString*)address port:(int)port{
    self.udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self]; //得到udp util
    [self.udpSocket enableBroadcast:YES error:nil];
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    //[udpSocket sendData:data toHost:address port:port withTimeout:0 tag:1]; //发送udp
    [self.udpSocket sendData :data toHost:@"224.0.0.1" port:port withTimeout:5 tag:0];
    [self.udpSocket receiveWithTimeout:5 tag:0];
    
}

//下面是发送的相关回调函数
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag
          fromHost:(NSString *)host port:(UInt16)port{
    NSString* rData= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"onUdpSocket:didReceiveData:---%@",rData);
    //base 64
    NSData *dataDecodeBefore=[rData dataUsingEncoding:NSUTF8StringEncoding];
    //dataDecodeBefore=  [GTMBase64 decodeData:dataDecodeBefore];
    NSString *dataDecodeAfter=[[NSString alloc] initWithData:dataDecodeBefore encoding:NSUTF8StringEncoding] ;
    NSLog(@"onUdpSocket:decode ip:---%@",dataDecodeAfter);
    if(![dataDecodeAfter isEqualToString: @""] ){
        if(![self.ipArray containsObject:dataDecodeAfter]){
            NSRange range  = [dataDecodeAfter rangeOfString:@"="];
            if([[dataDecodeAfter  substringFromIndex:range.location+1]  isEqualToString:self.postLoginIp]){
                [self.ipArray addObject:dataDecodeAfter];
                self.postLoginIp =[dataDecodeAfter  substringToIndex:range.location];
                
                if ([self.loginHandlerDelegate respondsToSelector:@selector(handlerDidReceiveData:) ]) {
                    [self.loginHandlerDelegate handlerDidReceiveData:self.postLoginIp];//调用委托方法
                }
            }
        }
    }
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    return NO;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    if ([self.loginHandlerDelegate respondsToSelector:@selector(handlerDidNotSendDataWithTag)]) {
        [self.loginHandlerDelegate handlerDidNotSendDataWithTag];//调用委托方法
    }
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    if (!self.ipArray || self.ipArray.count<=0) {
        if ([self.loginHandlerDelegate respondsToSelector:@selector(handlerDidNotReceiveDataWithTag)]) {
            [self.loginHandlerDelegate handlerDidNotReceiveDataWithTag];//调用委托方法
        }
    }
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    if ([self.loginHandlerDelegate respondsToSelector:@selector(handlerDidSendDataWithTag)]) {
        [self.loginHandlerDelegate handlerDidSendDataWithTag];//调用委托方法
    }
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    if ([self.loginHandlerDelegate respondsToSelector:@selector(handlerOnUdpSocketDidClose)]) {
        [self.loginHandlerDelegate handlerOnUdpSocketDidClose];//调用委托方法
    }
}




@end
