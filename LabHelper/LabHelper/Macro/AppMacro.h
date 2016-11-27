//
//  AppMacro.h
//  LabHelper
//
//  Created by ljc on 2016/11/5.
//  Copyright © 2016年 meitu. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

#define KLoginAddress                           @"http://202.115.207.95:8080/login.ashx"
#define KGetSecondPasswordAddress               @"http://202.115.207.95:8080/getpass.ashx"
#define KGetGuestListAddress                    @"http://202.115.207.95:8080/GetClientList.ashx" 
#define KGetGuestInfoAddress                    @"http://202.115.207.95:8080/GetClientInfo.ashx"
#define kUploadImageAddress                     @"http://202.115.207.95:8080/UploadPic.ashx"
#define KuploadGuestInfo                        @"http://202.115.207.95:8080/ClientReg.ashx"
#define KLoginCode                              @"d44fe"
#define KToken                                  @"KToken"
#define KUserID                                 @"KUserID"
#define KCiidList                               @"KCiidList"
#define KDisplayClientImageAddress              @"http://202.115.207.95:8080/image/"

#define kClientImageFolder   [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"imageFolder"]
#define kCollectionViewItemSize                CGSizeMake(180, 150)

#define kScreenSize            [[UIScreen mainScreen] bounds].size
#define kScreenWidth           [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight          [[UIScreen mainScreen] bounds].size.height


#endif /* AppMacro_h */
