//
//  QYQRequst.m
//  QiuYouQuan
//
//  Created by QYQ-lyt on 15/8/25.
//  Copyright (c) 2015年 QYQ. All rights reserved.
//

#import "ZXRequest.h"
#import "YTKNetworkConfig.h"
#import "AFSecurityPolicy.h"

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
    //[self configHttps];
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

/*-(void)configHttps{
    
    // 获取证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"baidu" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // 配置安全模式
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    
    //config.baseUrl = Host_Server;
    //    config.cdnUrl = @"http://fen.bi";
    
    // 验证公钥和证书的其他信息
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // 允许自建证书
    securityPolicy.allowInvalidCertificates = YES;
    
    // 校验域名信息
    securityPolicy.validatesDomainName      = NO;
    
    // 添加服务器证书,单向验证;  可采用双证书 双向验证;
    //securityPolicy.pinnedCertificates       = [NSSet setWithObject:certData];
    
    [config setSecurityPolicy:securityPolicy];
    
}*/


@end
