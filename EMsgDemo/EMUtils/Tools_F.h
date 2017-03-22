//
//  Tools_F.h
//  商多多
//
//  Created by hua on 15/4/9.
//  Copyright (c) 2015年 jofly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface Tools_F : NSObject

// 设置边框&圆角
+ (void)setViewlayer:(UIView *)view cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
// 设置虚线边框（需先设定size）
+ (void)setViewlayer:(UIView *)view borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
// MD5加密
+ (NSString *)Newmd5:(NSString *)inPutText;

// 时间戳解析
typedef NS_ENUM(NSInteger, TimeLevel){
    years = 0,
    months = 1,
    days = 2,
    hours = 3,
    minutes = 4,
    seconds = 5
};

+ (NSString *)timeTransform:(int)time time:(TimeLevel)timeLevel;

// date转时间戳
//+ (NSInteger)timeTransformTimestamp:(NSDate *)date;

// 时间戳倒数天数
+ (NSString *)remainTime:(int)time;

+ (NSString *)getCurrentTime;

// 手机正则判断
+ (BOOL)validateMobile:(NSString *)mobile;

// 密码正则判断
+ (BOOL)validatePassword:(NSString *)passWord;

// 邮箱
+ (BOOL)validateEmail:(NSString *)email;

// 中文正则判断
+ (BOOL)ValidChineseString:(NSString *)string;

// 过滤emoji表情
+ (NSString *)stringContainsEmoji:(NSString *)string;

// 动态高度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize width:(float)width;

// 动态宽度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize height:(float)height;

// 生成纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

// 毛玻璃效果
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

// 十六进制颜色
+ (UIColor *)colorWithHexString: (NSString *)color;

// 常规按钮
+ (void)commonWithButton:(UIButton *)btn
                    font:(UIFont *)font
                   title:(NSString *)title
           selectedTitle:(NSString *)selectedTitle
              titleColor:(UIColor *)titleColor
      selectedtitleColor:(UIColor *)selectedtitleColor
           backgroundImg:(UIImage *)backgroundImg
   selectedBackgroundImg:(UIImage *)selectedBackgroundImg
                  target:(id)target
                  action:(SEL)action;

@end
