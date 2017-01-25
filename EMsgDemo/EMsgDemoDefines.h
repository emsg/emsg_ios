//
//  EMsgDemoDefines.h
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#ifndef EMsgDemoDefines_h
#define EMsgDemoDefines_h

#import "ZXRequest.h"
#import "MJExtension.h"
#import "ZXCommens.h"
#import "Tools_F.h"
#import "UIColor+UIColor.h"
#import "UIViewController+HUD.h"
#import "UIImageView+WebCache.h"
#import "FMDBManger.h"
#import "UIView+LayoutMethods.h"

#define Host_Server @"https://202.85.214.98/request/"
#define Server_File_Host @"http://fileserver.lczybj.com/fileserver/get/"
#define File_Host @"http://fileserver.lczybj.com/fileserver/upload/"

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define QYQCOLOR(r,g,b) RGBACOLOR(r,g,b,1)
#define BASE_COLOR RGBACOLOR(30, 30, 30, 1)
#define QYQHEXCOLOR_ALPHA(c, a) [UIColor colorWithHexValue:c alpha:a]
#define QYQHEXCOLOR(c) QYQHEXCOLOR_ALPHA(c,1)
#define BASE_GREEN_COLOR QYQHEXCOLOR_ALPHA(0x33db61, 1)
#define BASE_FONT_COLOR RGBACOLOR(128, 128, 128, 1)
#define BASE_VC_COLOR QYQHEXCOLOR_ALPHA(0xefeef4, 1)
#define BASE_6_COLOR QYQHEXCOLOR(0x666666)
#define BASE_3_COLOR QYQHEXCOLOR(0x333333)
#define BASE_9_COLOR QYQHEXCOLOR(0x999999)
#define BASE_CELL_LINE_COLOR QYQHEXCOLOR(0xdddddd)

//两次铃声提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

//登录状态通知
#define LOGIN_STATE @"LOGIN_STATE"
/** 刷新角标*/
#define UPDATE_BADGE @"UPDATE_BADGE"
/** 有新消息 */
#define NEW_MESSAGE @"NEW_MESSAGE"
/** 新的系统消息*/
#define NEW_SERVER_MESSAGE @"NEW_SERVER_MESSAGE"
/** 退出是刷新系统消息 */
#define LOGOUT_SERVER_MESSAGE @"LOGOUT_SERVER_MESSAGE"
/** 登入和登出 */
#define QYQ_LOGIN_IN @"QYQ_LOGIN_IN"
#define QYQ_LOGIN_OUT @"QYQ_LOGIN_OUT"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define ZXWeak(var, weakVar) __weak __typeof(&*var) weakVar = var
#define ZXWeakSelf ZXWeak(self,__weakSelf);

#endif /* EMsgDemoDefines_h */
