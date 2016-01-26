//
//  DeviceNetworkInterface.h
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/25.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceCurrentVariable.h"
#import "DeviceInfo.h"

@interface DeviceNetworkInterface : NSObject

+ (void)login:(id)sender;
+ (void)getDeviceList:(id)sender;
+ (void)getDeviceList:(id)sender withBlock:(void (^)(NSArray *deviceList,NSError *error))block;
+ (void)cameraDiscovery:(id)sender withBlock:(void (^)(NSArray *deviceList,NSError *error))block;
+ (void)realTimeCameraStreamWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message, NSString *stream, NSString *ptz, NSString *monitoring, NSString *recording, NSString *mode, NSString *onlining, NSError *error))block;
+ (void)realTimeCameraSnapshotWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message, NSString *image,NSError *error))block;
+(void)cameraControlWithDirection:(NSString *)direction withDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message,NSError *error))block;
+ (void)cameraControlStopwithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message, NSError *error))block;
+ (void)cameraRecordwithDeviceId:(NSString *)deviceId withSwitchParam:(NSString *)switchParam withBlock:(void (^)(NSString *, NSString *, NSError *))block;
+ (void)cameraAlarmingwithDeviceId:(NSString *)deviceId withAlarmParam:(NSString *)alarmParam withBlock:(void (^)(NSString *, NSString *, NSError *))block;
+ (void)getDeviceAllSetting:(id)sender withBlock:(void (^)(NSString *result, NSString *message, NSString *recVolume, NSString *recLoop, NSString *alarmVolume, NSString *alarmLoop, NSError *error))block;
+ (void)saveDeviceAllSettingWithSetArray:(NSArray*)setArray withBlock:(void (^)(NSString *result, NSString *message, NSError *error))block;
+ (void)getDeviceSettingWithBrand:(NSString*)brand andModel:(NSString *)model withBlock:(void (^)(NSString *result, NSString *message, NSArray *brands, NSError *error))block;
+ (void)addDeviceAutomaticWithDeviceInfo:(DeviceInfo *)deviceInfo withBlock:(void (^)(NSString *result, NSString *message, NSError *error))block;
//0 删除但不删除文件
+ (void)deleleFromDeviceListWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message,NSError *error))block;
//2 删除并删除文件
+ (void)deleteFromDeviceListAndFileWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message,NSError *error))block;
//摄像头设置取得
+ (void)getCameraSettingWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message, NSArray *devices,NSError *error))block;
//摄像头设置保存
+ (void)updateCameraSettingWithDeviceInfo:(DeviceInfo *)deviceInfo withBlock:(void (^)(NSString *result, NSString *message,NSError *error))block;
//取得摄像头历史录像记录
+ (void)getCameraRecordHistoryWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *result, NSString *message, NSArray *times,NSArray *videos, NSError *error))block;
//取得存在摄像头历史录像的日期
+ (void)getCameraRecordHistoryDatesWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *result, NSString *message, NSArray *times, NSError *error))block;
//手动添加摄像头请求数据
+ (void)getDeviceSettingForManualAdd:(id)sender withBlock:(void (^)(NSString *result, NSString *message, NSArray *brands, NSError *error))block;
//设备添加连接测试
+ (void)networkTestForDeviceAddWithAddition:(NSString *)addition andUserid:(NSString *)userid andPasswd:(NSString *)passwd andBrand:(NSString *)brand andModel:(NSString *)model withBlock:(void (^)(NSString *result, NSString *message, NSString *code, NSString *sensitivity, NSString *wifi, NSString *version, NSError *error))block;
//new
+ (void)newNetworkTestForDeviceAddWithAddition:(NSString *)addition andUserid:(NSString *)userid andPasswd:(NSString *)passwd withBlock:(void (^)(NSString *result, NSString *message, NSString *code, NSString *sensitivity, NSString *wifi, NSString *brand, NSString *model, NSString *version, NSError *error))block;

//摄像头画面翻转
+ (void)setCameraPictureRolloverWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message, NSError *error))block;
//摄像头重新启动
+ (void)setCameraRebootWithDeviceId:(NSString *)deviceId withBlock:(void (^)(NSString *result, NSString *message, NSError *error))block;

//alarm
//取得报警列表数据
+ (void)getAlarmListWithMsgId:(NSString *)msgId andMsgCnt:(NSString *)msgCnt withBlock:(void (^)(NSString *result, NSString *message, NSArray *alarms, NSError *error))block;
//del alarm
+ (void)delAlarmMsgWithMsgIds:(NSArray *)msgIds withBlock:(void (^)(NSString *result, NSString *message, NSError *error))block;
//set readed
+ (void)setAlarmMsgReadedWithMsgIds:(NSArray *)msgIds withBlock:(void (^)(NSString *result, NSString *message, NSError *error))block;
//取得摄像头截图历史录像记录
+ (void)getCameraSnapshotHistoryWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *result, NSString *message, NSArray *times,NSArray *videos, NSError *error))block;
//取得摄像头mode历史录像记录
+ (void)getCameraModeRecordHistoryWithDeviceId:(NSString *)deviceId andDay:(NSString *)day withBlock:(void (^)(NSString *result, NSString *message, NSArray *times,NSArray *videos, NSError *error))block;

//check by server
+ (void)checkAlarmTransferServerwithBlock:(void (^)(NSString *result, NSString *message, NSDictionary *cidinfo, NSError *error))block;

//
+ (Boolean)isObjectNULLwith:(NSObject *)obj;

@property (strong,nonatomic) NSMutableDictionary *dic;
@property(strong,nonatomic) NSArray *deviceList;

@end
