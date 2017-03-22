//
//  ZXUser.m
//  ChatDemo-UI3.0
//
//  Created by hawk on 16/3/9.
//  Copyright © 2016年 hawk. All rights reserved.
//

#import "ZXUser.h"

@implementation ZXUser
+(void)initialize
{
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"uid":@"id"
        };
    }];
}
@end
