//
//  DataManager.h
//  CoopuryFTP
//
//  Created by clq  on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Singleton.h"


#define g_sDataManager [DataManager sharedInstance]


typedef enum _RequestType {
    RequestNoneType = 0,
    RequestSeatchType = 1,
    RequestDeleteFileType = 2,
    RequestDeleteFolderType = 3,
    RequestDownloadType = 4,
} RequestType;

@interface DataManager : Singleton
{
    BOOL net;
    NSString *mUserName;
    NSString *mPassword;
    NSString *mCId;
}

@property (nonatomic) BOOL net;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *requestHost;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *cId;
@property (nonatomic, retain) NSString *userType;

+(DataManager*)sharedInstance;

- (NSInteger)checkNetWork;
- (NSString *)getFileType:(NSString *)name;
- (NSString *)getFileSize:(NSInteger)size;
- (CGFloat)divideSize:(CGFloat)size;

@end
