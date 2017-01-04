//
//  AppMacro.h
//  LabHelper
//
//  Created by ljc on 2016/11/5.
//  Copyright © 2016年 meitu. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

#define KLoginAddress                           @"http://139.224.135.130/login.ashx"
#define KGetSecondPasswordAddress               @"http://139.224.135.130/getpass.ashx"
#define KGetGuestListAddress                    @"http://139.224.135.130/GetClientList.ashx"
#define KGetGuestInfoAddress                    @"http://139.224.135.130/GetClientInfo.ashx"
#define kUploadImageAddress                     @"http://139.224.135.130/UploadPic.ashx"
#define KUploadGuestInfo                        @"http://139.224.135.130/ClientReg.ashx"
#define kDeleteImageAddress                     @"http://139.224.135.130/deletepic.ashx"
#define KLoginCode                              @"d44fe"
#define KToken                                  @"KAppToken"
#define KUserID                                 @"KUserID"
#define KCiidList                               @"KCiidList"
#define KDisplayClientImageAddress              @"http://139.224.135.130/image/"

#define kClientImageFolder   [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"imageFolder"]


// 定义颜色简便方法
#define RGB(r,g,b)        [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:1.f]
#define RGBA(r,g,b,a)     [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:a]
#define RGBAHEX(hex,a)    RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),a)


#define kScreenSize            [[UIScreen mainScreen] bounds].size
#define kScreenWidth           [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight          [[UIScreen mainScreen] bounds].size.height


#endif /* AppMacro_h */
