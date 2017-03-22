//
//  ZXContactListRequest.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/22.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "ZXContactListRequest.h"

@implementation ZXContactListRequest

- (NSInteger)cacheTimeInSeconds {
    //3分钟的缓存时间,3分钟内不重复发出请求
    return 1;
}
@end
