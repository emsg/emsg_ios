//
//  Tools_F.m
//  商多多
//
//  Created by hua on 15/4/9.
//  Copyright (c) 2015年 jofly. All rights reserved.
//

#import "Tools_F.h"

@implementation Tools_F

#pragma mark - 视图加边框、圆角
+ (void)setViewlayer:(UIView *)view cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    
    [view.layer setMasksToBounds:YES];//允许圆角
    [view.layer setCornerRadius:cornerRadius];//圆角幅度
    [view.layer setBorderWidth:borderWidth]; //边框宽度
    [view.layer setBorderColor:borderColor.CGColor];//边框颜色
}

#pragma mark - 画矩形虚线边框
+ (void)setViewlayer:(UIView *)view borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    
    CAShapeLayer *border = [CAShapeLayer layer];
    
    border.frame = view.bounds;
    border.strokeColor = borderColor.CGColor;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    border.lineWidth = borderWidth;
    border.lineCap = @"square";
    border.lineDashPattern = @[@4, @2];
    [view.layer addSublayer:border];
}

#pragma mark - MD5加密
+ (NSString *)Newmd5:(NSString *)inPutText
{
    const char *cStr = [inPutText UTF8String];
    if (cStr == NULL) {
        cStr = "";
    }
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

#pragma mark - 时间戳转换
+ (NSString *)timeTransform:(int)time time:(TimeLevel)timeLevel{
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    
    switch (timeLevel) {
        case years:
        {
            [dateformatter setDateFormat:@"yyyy"];
        }
            break;
        case months:
        {
            [dateformatter setDateFormat:@"yyyy-MM"];
        }
            break;
        case days:
        {
            [dateformatter setDateFormat:@"yyyy-MM-dd"];
        }
            break;
        case hours:
        {
            [dateformatter setDateFormat:@"yyyy-MM-dd HH"];
        }
            break;
        case minutes:
        {
            [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        }
            break;
        case seconds:
        {
            [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
            break;
        default:
        {
            [dateformatter setDateFormat:@"yyyy-MM-dd"];
        }
            break;
    }
    
    NSString *regStr = [dateformatter stringFromDate:date];
    return regStr;
}

#pragma mark - 时间戳倒数天数
+ (NSString *)remainTime:(int)time{
    
    NSDate *datenow = [NSDate date];  // 获取现在时间
    
    if (time <= (int)[datenow timeIntervalSince1970]) {
        
        return @"已过时";
    }
    else {
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
        
        NSDate *today = [NSDate date];//得到当前时间
        
        //用来得到具体的时差
        unsigned int unitFlags =  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *d = [cal components:unitFlags fromDate:today toDate:date options:0];
        
        NSString *countdown = [NSString stringWithFormat:@"%ld",(long)[d day]];
        
        return countdown;
    }
}

+ (NSString *)getCurrentTime{
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a =[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f",a];  //转为字符型
    
    return timeString;
}

#pragma mark - 正则手机表达式判断
+ (BOOL)validateMobile:(NSString *)mobile{
    if (mobile.length <= 0 || !mobile) {
        return NO;
    }
    //手机号正则表达式
    NSString *phoneRegex = @"^1[0-9]{1}[0-9]{9}$";
    
    NSPredicate *phoneAuth =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL auth = [phoneAuth evaluateWithObject:mobile];
    return auth;
}

#pragma mark - 正则密码表达式判断
+ (BOOL)validatePassword:(NSString *)passWord{
    
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,12}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

#pragma mark - 正则邮箱表达式判断
+ (BOOL)validateEmail:(NSString *)email{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - 正则表达式判断是否为中文（1-8）位
+ (BOOL)ValidChineseString:(NSString *)string{
    
    NSString *chineseRegex = @"[\u4e00-\u9fa5]{1,20}$";
    NSPredicate *chineseText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",chineseRegex];
    
    return [chineseText evaluateWithObject:string];
}

#pragma mark - 过滤emoji
+(NSString *)stringContainsEmoji:(NSString *)string{
    
    __block NSString *noEmoji = string;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
             }
         }
     }];
    string = noEmoji;
    return string;
}

#pragma mark - 动态高度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize width:(float)width{
    
    // 高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    // label 可设置的最大高度和宽度
    CGSize size = CGSizeMake(width, MAXFLOAT);
    // 获取当前文本的属性
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName,nil];
    
    CGSize actualsize = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    return actualsize;
}

#pragma mark - 动态宽度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize height:(float)height{
    
    // label 可设置的最大高度和宽度
    CGSize size = CGSizeMake(MAXFLOAT, height);
    // 获取当前文本的属性
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName,nil];
    
    CGSize actualsize = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    return actualsize;
}

#pragma mark - 生成纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *)colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    //    NSLog(@"%u,%u,%u",r, g, b);
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark - 加模糊效果，image是图片，blur是模糊度
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    //模糊度,
    if ((blur < 0.1f) || (blur > 2.0f)) {
        blur = 0.5f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    NSLog(@"boxSize:%i",boxSize);
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入
    /*
     This document describes the Accelerate Framework, which contains C APIs for vector and matrix math, digital signal processing, large number handling, and image processing.
     本文档介绍了Accelerate Framework，其中包含C语言应用程序接口（API）的向量和矩阵数学，数字信号处理，大量处理和图像处理。
     */
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

#pragma mark - 常规按钮
+ (void)commonWithButton:(UIButton *)btn
                    font:(UIFont *)font
                   title:(NSString *)title
           selectedTitle:(NSString *)selectedTitle
              titleColor:(UIColor *)titleColor
      selectedtitleColor:(UIColor *)selectedtitleColor
           backgroundImg:(UIImage *)backgroundImg
   selectedBackgroundImg:(UIImage *)selectedBackgroundImg
                  target:(id)target
                  action:(SEL)action{
    
    if (font) {
        btn.titleLabel.font = font;
    }
    if (title) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (selectedTitle) {
        
        [btn setTitle:selectedTitle forState:UIControlStateSelected];
    }
    if (titleColor) {
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
    }
    if (selectedtitleColor) {
        [btn setTitleColor:selectedtitleColor forState:UIControlStateSelected];
    }
    if (backgroundImg) {
        [btn setBackgroundImage:backgroundImg
                       forState:UIControlStateNormal];
    }
    if (selectedBackgroundImg) {
        [btn setBackgroundImage:selectedBackgroundImg
                       forState:UIControlStateSelected];
    }
    if (target && action) {
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
