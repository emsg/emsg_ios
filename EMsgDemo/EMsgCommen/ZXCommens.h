//
//  ZXCommens.h
//  ChatDemo-UI3.0
//
//  Created by hawk on 16/3/9.
//  Copyright © 2016年 hawk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXUser.h"

@interface ZXCommens : NSObject

+ (NSString *)creatUUID;

+ (BOOL)validateMobile:(NSString *)mobile;

+ (BOOL)validateEmail:(NSString *)email;

+ (void)putLoginState:(BOOL)state;

+ (BOOL)isLogin;

+ (NSDictionary *)factionaryParams:(NSDictionary *)params WithServerAndMethod:(NSDictionary *)task;

+ (void)putUserInfo:(ZXUser *)user;

+ (ZXUser *)fetchUser;

+ (void)deleteUserInfo;

+ (NSString *)creatMSTimastmap;

+ (NSMutableArray *)sortArray:(NSMutableArray *)arr;

+ (NSString *)subQiuYouNo:(NSString *)domainId;

+ (void)putDeviceToken:(NSString *)deviceToken;

+ (NSString *)fetchDeviceToken;


@end
