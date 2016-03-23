//
//  ZXCommens.m
//  ChatDemo-UI3.0
//
//  Created by hawk on 16/3/9.
//  Copyright © 2016年 hawk. All rights reserved.
//

#import "ZXCommens.h"

@implementation ZXCommens

+ (NSString *)creatUUID {
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (__bridge NSString *)CFStringCreateCopy(NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

#pragma mark - 正则手机表达式判断
+ (BOOL)validateMobile:(NSString *)mobile{
    if (mobile.length <= 0 || !mobile) {
        return NO;
    }
    //手机号正则表达式
    NSString *phoneRegex = @"^1[0-9]{1}[0-9]{9}$";
    
    NSPredicate *phoneAuth =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL auth = [phoneAuth evaluateWithObject:mobile];
    return auth;
}

#pragma mark - 正则邮箱表达式判断
+ (BOOL)validateEmail:(NSString *)email{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (void)putLoginState:(BOOL)state{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    [df setObject:@(state) forKey:@"LOGIN_STATE"];
    [df synchronize];
}

+ (BOOL)isLogin{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    BOOL state = [[df valueForKey:@"LOGIN_STATE"] boolValue];
    return  state;
}

+ (NSDictionary *)factionaryParams:(NSDictionary *)params WithServerAndMethod:(NSDictionary *)task{
    NSMutableDictionary * rDic = [[NSMutableDictionary alloc] initWithDictionary:task];
    rDic[@"sn"] = [ZXCommens creatUUID];
    ZXUser * user = [ZXCommens fetchUser];
    if (user) {
        rDic[@"token"] = user.token; 
    }
    if (params) {
        rDic[@"params"] = params;
    }
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:rDic options:0 error:nil];
    NSString *myString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *pDic =
    [[NSDictionary alloc] initWithObjectsAndKeys:myString, @"body", nil];
    return pDic;
}

+ (void)putUserInfo:(ZXUser *)user{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    [df setObject:[user mj_keyValues] forKey:@"userInfo"];
    [df synchronize];
}

+ (ZXUser *)fetchUser{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSDictionary * dic = [df valueForKey:@"userInfo"];
    if (dic) {
        return [ZXUser mj_objectWithKeyValues:dic];
    }
    return nil;
}

+ (void)putLastLogin:(NSString *)username{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    [df synchronize];
}
+ (void)deleteUserInfo{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    [df removeObjectForKey:@"userInfo"];
    [df synchronize];
}

+ (NSString *)creatMSTimastmap{
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%lld",recordTime];
}

+ (NSMutableArray *)sortArray:(NSMutableArray *)arr{
    NSMutableArray * sortArray = [[NSMutableArray alloc] init];
    for (NSInteger i = arr.count - 1; i >= 0; i--) {
        [sortArray addObject:[arr objectAtIndex:i]];
    }
    return sortArray;
}

+ (NSString *)subQiuYouNo:(NSString *)domainId{
    NSRange checkStrRange = [domainId rangeOfString:@"@"];
    if (checkStrRange.location != NSNotFound) {
        NSString * qiuYouNo = [domainId substringToIndex:checkStrRange.location];
        return qiuYouNo;
    }
    return nil;
}

+ (void)putDeviceToken:(NSString *)deviceToken{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    [df setObject:deviceToken forKey:@"deviceToken"];
    [df synchronize];
}

+ (NSString *)fetchDeviceToken{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSString * devictToken = [df valueForKey:@"deviceToken"];
    return devictToken;
}

@end
