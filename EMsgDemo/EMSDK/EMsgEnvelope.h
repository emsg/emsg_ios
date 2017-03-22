//
//  EMsgEnvelope.h
//  EmsClientDemo
//
//  Created by QYQ-Hawk on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  消息外层的信封
 */
@interface EMsgEnvelope : NSObject
/**
 *  服务器消息过来的唯一id,如果未收到回执,服务器会重复发送消息,但此id不变
 */
@property(nonatomic, strong) NSString *uid;
/**
 *  消息业务类型0：打开会话，1：普通聊天（1对1），2：群聊（一对多），3：状态同步（实现消息的事件同步，例如：已送达、已读
 * 等），4：系统消息（服务端返回给客户端的通知），5：语音拨号（P2P服务拨号），6：视频（P2P服务拨号）7：订阅：（发布订阅）
 *  //本地拓展 type 类型, type = 100,101,102 加好友通知, 拒绝好友通知,接受好友通知*/
@property(nonatomic, strong) NSString *type;
/**
 *  发送消息者
 */
@property(nonatomic, strong) NSString *from;
/**
 *  消息接收者
 */
@property(nonatomic, strong) NSString *to;
/**
 *  ack是否做校验：0：不确保对方是否收到消息，1：对方必然收到消息
 */
@property(nonatomic, strong) NSString *ack;

/**
 *  消息时间戳，由服务器返回
 */
@property(nonatomic, strong) NSString *ct;
/**
 *  登录聊天服务器的密码
 */
@property(nonatomic, strong) NSString *pwd;
/**
 *  群组id
 */
@property(nonatomic, strong) NSString *gid;

@end
