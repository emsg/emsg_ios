//
//  EMsgEnvelope.m
//  EmsClientDemo
//
//  Created by QYQ-Hawk on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import "EMsgEnvelope.h"
#import "MJExtension.h"
@implementation EMsgEnvelope
+(void)initialize
{
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"uid":@"id"
                 };
    }];
}
@end
