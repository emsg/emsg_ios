//
//  UIImage+Extension.m
//  网易新闻
//
//  Created by apple on 14-7-25.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGFloat imageW = 100;
    CGFloat imageH = 100;
    // 1.开启基于位图的图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageW, imageH), NO, 0.0);
    
    // 2.画一个color颜色的矩形框
    [color set];
    UIRectFill(CGRectMake(0, 0, imageW, imageH));
    
    // 3.拿到图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4.关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIImage *)imageWithName:(NSString *)name
{
    UIImage *image = nil;
    if (iOS7) { // 处理iOS7的情况
        NSString *newName = [name stringByAppendingString:@"_os7"];
        image = [UIImage imageNamed:newName];
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

+ (UIImage *)resizedImage:(NSString *)name
{
    UIImage *image = [UIImage imageWithName:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
+ (UIImage *)clipImageWithIcon:(NSString *)icon{
    UIImage *image = [UIImage imageNamed:icon];
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGFloat iconW = image.size.width;
    CGFloat iconH = image.size.height;
    CGFloat iconX = 0;
    CGFloat iconY = 0;
    CGContextAddEllipseInRect(ctx, CGRectMake(iconX, iconY, iconW, iconH));
    CGContextClip(ctx);
    [image drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    
    // 6.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}
+ (UIImage *)clipImageWithImage:(UIImage *)image{
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat iconW = image.size.width;
    CGFloat iconH = image.size.height;
    CGFloat iconX = 0;
    CGFloat iconY = 0;
    CGContextAddEllipseInRect(ctx, CGRectMake(iconX, iconY, iconW, iconH));
    CGContextClip(ctx);
    [image drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    
    // 6.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}
+ (UIImage *)clipImageWithColor:(UIColor *)color{
    UIImage *image = [UIImage imageWithColor:color];
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat iconW = image.size.width;
    CGFloat iconH = image.size.height;
    CGFloat iconX = 0;
    CGFloat iconY = 0;
    CGContextAddEllipseInRect(ctx, CGRectMake(iconX, iconY, iconW, iconH));
    CGContextClip(ctx);
    [image drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    
    // 6.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
