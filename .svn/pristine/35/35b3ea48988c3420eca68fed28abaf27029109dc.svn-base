//
//  DataManager.m
//  CoopuryFTP
//
//  Created by clq  on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"


@implementation DataManager

static DataManager *sharedInstance = nil;

+ (DataManager*)sharedInstance
{
	@synchronized(self)
	{
		if (sharedInstance == nil)
			sharedInstance = [[DataManager alloc] init];
	}
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self)
	{
		if (sharedInstance == nil)
		{
			sharedInstance = [super allocWithZone:zone];
			return sharedInstance; // assignment and return on first allocation
		}
	}
	return nil; // on subsequent allocation attempts return nil
}

@synthesize net;
@synthesize userName = mUserName;
@synthesize password = mPassword;
@synthesize userId = mUserId;
@synthesize cId = mCId;
@synthesize userType = mUserType;
-(id)init
{
    self = [super init];
    if( self )
    {
        net = 0;
        mUserName = @"";
        mPassword = @"";
        mUserId =@"";
        mCId =@"";
        mUserType =@"";
    }
    return self;
}

- (NSInteger)checkNetWork
{
    //取得当前网络状态
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            return 1;
        case ReachableViaWiFi:
            return 1;
        case ReachableViaWWAN:
            return 2;
        default:
            break;
    }
    return -1;
}

-(NSString *)getFileType:(NSString *)name{
    NSString *type = [[name componentsSeparatedByString:@"."] lastObject];
    return [type lowercaseString];
}

- (NSString *)getFileSize:(NSInteger)size{
    CGFloat d_size = size;
    NSInteger count = 0;
    while (d_size>1024) {
        count++;
        d_size = [self divideSize:d_size];
    }
    NSString *unit;
    switch (count) {
        case 0:
            unit = @"Byte";
            break;
        case 1:
            unit = @"KB";
            break;
        case 2:
            unit = @"MB";
            break;
        case 3:
            unit = @"GB";
            break;
        case 4:
            unit = @"TB";
            break;
        default:
            unit = @"Byte";
            break;
    }
    return [NSString stringWithFormat:@"%.2f %@",d_size,unit];
}

- (CGFloat)divideSize:(CGFloat)size{
    return size/1024;
}

@end
