//
//  ZBMessageShareMenuItem.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageShareMenuItem.h"


@implementation ZBMessageShareMenuItem

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title{
    if (self) {
        self.normalIconImage = normalIconImage;
        self.title = title;
    }
    return self;
}

- (void)dealloc{
    self.normalIconImage = nil;
    self.title = nil;
}



@end
