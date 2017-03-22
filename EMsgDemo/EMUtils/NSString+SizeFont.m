//
//  NSString+SizeFont.m
//  QiuYouQuan
//
//  Created by 123 on 15/6/4.
//  Copyright (c) 2015年 QYQ. All rights reserved.
//

#import "NSString+SizeFont.h"

@implementation NSString (SizeFont)
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    
    NSDictionary *attrs = @{NSFontAttributeName : font};
    
    maxSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
    
    maxSize = CGSizeMake(maxSize.width, maxSize.height );
    
    return maxSize;
}

- (CGSize)sizeWithFont:(UIFont *)font andLineSpacing:(CGFloat)spacing maxSize:(CGSize)maxSize{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = spacing;// 字体的行间距
    
    NSDictionary *attrs = @{
                            NSFontAttributeName:font,
                            NSParagraphStyleAttributeName:paragraphStyle
                            };
    if (spacing == 0.0) {
        attrs = @{
                  NSFontAttributeName:font,
                  };
    }
    
    maxSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
    
    maxSize = CGSizeMake(maxSize.width, maxSize.height );
    
    return maxSize;
}



@end
