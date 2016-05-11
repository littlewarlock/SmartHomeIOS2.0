//
//  RequestConstant.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/9.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#ifndef RequestConstant_h
#define RequestConstant_h
#define REQUEST_URL                     @"smarty_storage/phone"
#define REQUEST_HTTPS_URL               @"https://172.16.10.110/smarty_storage/phone"
#define Server_URL                      @"123.57.223.91"
//special cloud folder dir

#define REQUEST_LOGIN_URL               [NSString stringWithFormat:@"%@%@", REQUEST_HTTPS_URL, @"/login.php"]

#define REQUEST_COPY_URL                [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/copyFile.php"]
#define REQUEST_MOVE_URL                [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/moveFile.php"]
#define REQUEST_RENAME_URL                [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/renameFile.php"]
#define REQUEST_REGISTER_URL            [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/addUser.php"]
#define REQUEST_FETCH_URL               [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/fetchFile.php"]
#define REQUEST_NEWFOLDER_URL           [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/newFolder.php"]
#define REQUEST_DELETE_URL              [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/delete.php"]
#define REQUEST_SHARE_URL              [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/share.php"]
#define REQUEST_GETSHARE_URL              [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/getShareFile.php"]
#define REQUEST_DOWNLOADSHARE_URL              [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/downShare.php"]


#define REQUEST_DOWN_URL                [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/down.php"]
#define REQUEST_UPLOAD_URL              @"172.16.10.110"
#define REQUEST_DOWNLOAD_URL            @"http://172.16.10.110/sda2/ftp/root/"
#define FTP_USERNAME                    @"coopury"
#define FTP_PASSWORD                    @"coopury_*"
//#define FTP_USERNAME                    @"storage"
//#define FTP_PASSWORD                    @"123.com"
#define REQUEST_FILESIZE_URL            [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/getFileSize.php"]
#define REQUEST_DOWNBLOCK_URL           [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/downByBlocking.php"]
#define REQUEST_CHANGEPWD_URL           [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/ChangePWD.php"]

#define REQUEST_GETUSERS_URL [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/getUsers.php"]
#define REQUEST_DELUSER_URL [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/delUser.php"]

#define REQUEST_VIDEO_URL            [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/remoteVideo.php"]
#define REQUEST_PIC_URL            [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/remoteGetPic.php"]
#define REQUEST_GLOBAL_URL           [NSString stringWithFormat:@"%@", @"/global.php"]

#define kDocument_Folder [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/SmartHome"]
#define REQUEST_UPLOADBLOCK_URL           [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/uploadByBlocking.php"]
#define REQUEST_PORT @"8080"

#define DOWNLOAD_FILE_SIZE          32768
#define DOWNLOAD_STREAM_SIZE        (1024 * 1024)

#define REQUEST_THUNDER_ON_URL [NSString stringWithFormat:@"%@",@"/smarthome/lib/thunder/L1.php"]
#define REQUEST_THUNDER_OFF_URL [NSString stringWithFormat:@"%@",@"/smarthome/lib/thunder/L9.php"]
#define REQUEST_THUNDER_KEY_URL [NSString stringWithFormat:@"%@",@"/smarthome/lib/thunder/N2.php"]
#define REQUEST_THUNDER_ISON_URL [NSString stringWithFormat:@"%@",@"/smarthome/lib/thunder/L10.php"]

#define REQUEST_ROUTER_SETROUTER_URL [NSString stringWithFormat:@"%@",@"/smarthome/lib/router/SetRouter.php"]
#define REQUEST_ROUTER_GEROUTER_URL [NSString stringWithFormat:@"%@",@"/smarthome/lib/router/getSetting.php"]
#define REQUEST_SESSIONCHECK_URL [NSString stringWithFormat:@"%@%@", REQUEST_URL, @"/uploadSessionCheck.php"]
#endif /* RequestConstant_h */
