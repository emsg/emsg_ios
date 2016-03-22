//
//  QYQRequst.m
//  QiuYouQuan
//
//  Created by QYQ-lyt on 15/8/25.
//  Copyright (c) 2015年 QYQ. All rights reserved.
//

#import "ZXRequest.h"

@interface ZXRequest ()

@property(nonatomic, strong) NSString *rURl;
@property YTKRequestMethod rMethod;
@property(nonatomic, strong) id rArgument;
@end

@implementation ZXRequest

- (instancetype)initWithRUrl:(NSString *)url
                  andRMethod:(YTKRequestMethod)method
                andRArgument:(id)argument {
    if (self = [super init]) {
        self.rURl = url;
        self.rMethod = method;
        self.rArgument = argument;
    }
    return self;
}

#pragma mark--- 重载YTKRequest的一些设置方法

- (NSString *)requestUrl {
    return self.rURl;
}

- (YTKRequestMethod)requestMethod {
    return self.rMethod;
}

- (id)requestArgument {
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    dic[@"service"] = self.rArgument[@"service"];
//    dic[@"method"] = self.rArgument[@"method"];
//    dic[@"sn"] = [ZXCommens creatUUID];
//    dic[@"params"] = rArgument;
//    NSData *jsonData =
//    [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
//    NSString *myString =
//    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSDictionary *pDic =
//    [[NSDictionary alloc] initWithObjectsAndKeys:myString, @"body", nil];

    return self.rArgument;
}

//- (NSDictionary *)requestHeaderFieldValueDictionary {
//    ZXUser * user = [ZXCommens fetchUser];
//    if (user.token) {
//        return @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",user.token]};
//    }
//    return nil;
//}
//- (NSArray *)requestAuthorizationHeaderFieldArray {
//    ZXUser * user = [ZXCommens fetchUser];
//    if (user.token) {
//        return @[user.token];
//    }
//    return nil;
//}




@end
