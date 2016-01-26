//
//  CGUpnpAvServer.m
//  CyberLink for C
//
//  Created by Satoshi Konno on 08/07/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#include <cybergarage/upnp/std/av/cmediarenderer.h>

#import "CGUpnpAvRenderer.h"
#import "CGUpnpAVPositionInfo.h"

@interface CGUpnpAvRenderer()
@property (assign) int currentPlayMode;
@end

enum {
    CGUpnpAvRendererPlayModePlay,
    CGUpnpAvRendererPlayModePause,
    CGUpnpAvRendererPlayModeStop,
};

@implementation CGUpnpAvRenderer

@synthesize cAvObject;
@synthesize currentPlayMode;

- (id)init
{
    if ((self = [super init]) == nil)
        return nil;
    
    cAvObject = cg_upnpav_dmr_new();
    [self setCObject:cg_upnpav_dmr_getdevice(cAvObject)];
    
    [self setCurrentPlayMode:CGUpnpAvRendererPlayModeStop];
    
    return self;
}

- (id) initWithCObject:(CgUpnpDevice *)cobj
{
    if ((self = [super initWithCObject:cobj]) == nil)
        return nil;
    
    cAvObject = NULL;
    
    return self;
}

- (CGUpnpAction *)actionOfTransportServiceForName:(NSString *)serviceName
{
    CGUpnpService *avTransService = [self getServiceForType:@"urn:schemas-upnp-org:service:AVTransport:1"];
    if (!avTransService)
        return nil;
    
    return [avTransService getActionForName:serviceName];
}

- (CGUpnpAction *)actionOfRenderServiceForName:(NSString *)serviceName
{
    CGUpnpService *avTransService = [self getServiceForType:@"urn:schemas-upnp-org:service:RenderingControl:1"];
    if (!avTransService)
        return nil;
    return [avTransService getActionForName:serviceName];
}




- (BOOL)setAVTransportURI:(NSString *)aURL;
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"SetAVTransportURI"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:aURL forName:@"CurrentURI"];
    [action setArgumentValue:@"" forName:@"CurrentURIMetaData"];
    
    if (![action post])
        return NO;
    
    return YES;
}

- (BOOL)play;
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"Play"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"1" forName:@"Speed"];
    
    if (![action post])
        return NO;
    
    [self setCurrentPlayMode:CGUpnpAvRendererPlayModePlay];
    
    return YES;
}

- (BOOL)stop;
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"Stop"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    
    if (![action post])
        return NO;
    
    [self setCurrentPlayMode:CGUpnpAvRendererPlayModeStop];
    return YES;
}

- (BOOL)pause
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"Pause"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    
    if (![action post])
        return NO;
    
    [self setCurrentPlayMode:CGUpnpAvRendererPlayModePause];
    
    return YES;
}

- (BOOL)next
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"Next"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    
    if (![action post])
        return NO;
    
    
    return YES;
    
    
}

- (BOOL)previous
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"Previous"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    
    if (![action post])
        return NO;
    
    return YES;
}
- (BOOL)seek:(float)absTime
{
   
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"Seek"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"REL_TIME" forName:@"Unit"];
    [action setArgumentValue:[NSString stringWithDurationTime:absTime] forName:@"Target"];
    
    if (![action post])
        return NO;
    
    return YES;
}

- (BOOL)setVolume:(float)vol
{
    //    CGUpnpAction *action = [self actionOfRenderServiceForName:@"SetVolume"];
    //    if (!action)
    //        return NO;
    //
    //    [action setArgumentValue:@"0" forName:@"InstanceID"];
    //    [action setArgumentValue:@"Master" forName:@"Channel"];
    //    [action setArgumentValue:[NSString stringWithDurationTime:vol] forName:@"DesiredVolume"];
    //
    //    if (![action post])
    //        return NO;
    
    //    CGUpnpAction *action1 = [self actionOfRenderServiceForName:@"GetVolume"];
    //    if (!action1)
    //        return NO;
    //    [action1 setArgumentValue:@"0" forName:@"InstanceID"];
    //        [action1 setArgumentValue:@"Master" forName:@"Channel"];
    //
    //    if (![action1 post])
    //        return NO;
    //    argumentValueForName(CG_UPNPAV_DMR_RENDERINGCONTROL_CURRENTVOLUME);
    //
    //    CGUpnpAction *getVolumeAction = [self actionOfRenderServiceForName:@"GetVolume"];
    //    if (!getVolumeAction)
    //                return NO;
    //    [getVolumeAction setArgumentValue:@"0" forName:@"InstanceID"];
    //    [getVolumeAction setArgumentValue:@"Master" forName:@"Channel"];
    //    if (![getVolumeAction post])
    //        return NO;
    //    NSString *resultStr = [getVolumeAction argumentValueForName:@"CurrentVolume"];
    
    //没有用到
    //    CGUpnpAction *getVolumeAction = [self actionOfRenderServiceForName:@"GetVolume"];
    //    if (!getVolumeAction)
    //        return NO;
    //    [getVolumeAction setArgumentValue:@"0" forName:@"InstanceID"];
    //    [getVolumeAction setArgumentValue:@"Master" forName:@"Channel"];
    //    if (![getVolumeAction post])
    //        return NO;
    //    NSString *resultStr = [getVolumeAction argumentValueForName:@"CurrentVolume"];
    //
    
    
    CGUpnpAction *action = [self actionOfRenderServiceForName:@"SetVolume"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [action setArgumentValue:[NSString stringWithFormat:@"%f",vol] forName:@"DesiredVolume"];
    
    if (![action post])
        return NO;
    
    
    
    
    
    return YES;
}

- (BOOL)isPlayingDlna
{
    if ([self currentPlayMode] == CGUpnpAvRendererPlayModePlay)
        return YES;
    return NO;
}

- (CGUpnpAVPositionInfo *)getPositionInfo
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"GetPositionInfo"];
    if (!action)
        return NO;
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    
}


- (CGUpnpAVPositionInfo *)positionInfo
{
    CGUpnpAction *action = [self actionOfTransportServiceForName:@"GetPositionInfo"];
    if (!action)
        return NO;
    
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    NSString *currentTrack = [action argumentValueForName:@"CurrentTrack"];
    NSString *trackMetaData = [action argumentValueForName:@"TrackMetaData"];
    NSString *trackURI = [action argumentValueForName:@"TrackURI"];
    NSString *relTime = [action argumentValueForName:@"RelTime"];
    NSString *absTime = [action argumentValueForName:@"AbsTime"];
    NSString *relCount = [action argumentValueForName:@"RelCount"];
    NSString *absCount = [action argumentValueForName:@"AbsCount"];
    
    
    if (![action post])
        return nil;
    
    return [[[CGUpnpAVPositionInfo alloc] initWithAction:action] autorelease];
}

/*
 - (BOOL)start
 {
	if (!cAvObject)
 return NO;
	return cg_upnpav_dms_start(cAvObject);
 }
 
 - (BOOL)stop
 {
	if (!cAvObject)
 return NO;
	return cg_upnpav_dms_stop(cAvObject);
 }
 */

@end
