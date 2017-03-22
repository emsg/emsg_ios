//
//  NSString+SizeFont.h
//  QiuYouQuan
//
//  Created by 123 on 15/6/4.
//  Copyright (c) 2015年 QYQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SizeFont)
/**
 *  返回字符串所占用的尺寸
 *
 *  @param font    字体
 *  @param maxSize 最大尺寸
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;


- (CGSize)sizeWithFont:(UIFont *)font andLineSpacing:(CGFloat)spacing maxSize:(CGSize)maxSize;

@end
