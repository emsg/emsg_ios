//
//  UIColor+UIColor.m
//  HomeLife
//
//  Created by HTGT on 14/11/24.
//  Copyright (c) 2014年 zhgt. All rights reserved.
//

#import "UIColor+UIColor.h"

@implementation UIColor (UIColor)
+(UIColor *)colorWithHexValue:(NSUInteger)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((hexValue >> 16) & 0x000000FF)/255.0f
                           green:((hexValue >> 8) & 0x000000FF)/255.0f
                            blue:((hexValue) & 0x000000FF)/255.0
                           alpha:alpha];
}
@end
