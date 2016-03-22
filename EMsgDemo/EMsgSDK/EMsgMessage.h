//
//  EMsgMessage.h
//  EmsClientDemo
//
//  Created by QYQ-Hawk on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMsgEnvelope.h"
#import "EMsgPayload.h"

/**
 *    ================================================
 *    此处为了兼容数据库，对系统消息进行前端的区分处理，修改 from属性和ct是否显示的属性
 */

@interface EMsgMessage : NSObject
/**
 *  EMsg IM 版本号
 */
@property(nonatomic, strong) NSString *vsn;
/**
 *  消息信封
 */
@property(nonatomic, strong) EMsgEnvelope *envelope;
/**
 *  消息包
 */
@property(nonatomic, strong) EMsgPayload *payload;
/**
 *  是否是自己发送的
 */
@property(nonatomic, assign) BOOL isMe;
/**
 *  显示消息日期
 */
@property(nonatomic, assign) BOOL showDateLabel;
/**
 *  消息发送状态是否失败:YES为发送失败
 */
@property(nonatomic, assign) BOOL isSendFail;
/**
 *  自己是否点击查看了这条消息
 */
@property(nonatomic, copy) NSString * isReaded;
/**
 *  会话的id,方便临时会话列表进行校验是否有新的会话产生
 */
@property(nonatomic, copy) NSString * chatId;
/**
 *  临时会话列表未读得数量
 */
@property(nonatomic,copy) NSString * unReadCountStr;

/**
 *  存储id唯一
 */
@property(nonatomic,copy) NSString * storeId;

/**
 *  主题消息体
 */
@property(nonatomic,copy) NSString * messageSpecialEntity;
/**
 *
 */

@end
