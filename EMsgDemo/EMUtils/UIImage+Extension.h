//
//  UIImage+Extension.h
//  网易新闻
//
//  Created by apple on 14-7-25.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color;
/**
 *  根据图片名自动加载适配iOS6\7的图片
 */
+ (UIImage *)imageWithName:(NSString *)name;

/**
 *  根据图片名返回一张能够自由拉伸的图片
 */
+ (UIImage *)resizedImage:(NSString *)name;
/**
 *  根据图片名返回一张剪切（园）的图片
 */
+ (UIImage *)clipImageWithIcon:(NSString *)icon;
/**
 *  根据颜色返回一张剪切（园）的图片
 */
+ (UIImage *)clipImageWithColor:(UIColor *)color;
/**
 *  根据图片返回一张剪切（园）的图片
 */
+ (UIImage *)clipImageWithImage:(UIImage *)image;
/**
 *  根据图片和size返回一张剪切（园）的图片
 */

+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
