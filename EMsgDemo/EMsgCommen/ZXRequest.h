//
//  QYQRequest.h
//  QiuYouQuan
//
//  Created by QYQ-lyt on 15/8/25.
//  Copyright (c) 2015年 QYQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKRequest.h"

@interface ZXRequest : YTKRequest

- (instancetype)initWithRUrl:(NSString *)url
                  andRMethod:(YTKRequestMethod)method
                andRArgument:(id)argument;
@end
