//
//  EMsgPayload.h
//  EmsClientDemo
//
//  Created by QYQ-Hawk on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMsgAttrs.h"
/**
 *  消息实体类
 */
@interface EMsgPayload : NSObject
/**
 *  消息内容，@"text"消息时候，为消息文本字符串，@"image"消息时候，为缩略图base64加密字符串，@"geo"时为@"geo",语音待定
 */
@property(nonatomic, strong) NSString *content;
/**
 *  消息附加属性
 */
@property(nonatomic, strong) EMsgAttrs *attrs;



@end
