//
//  EMsgCilent.h
//  EmsClientDemo
//
//  Created by QYQ-Hawk on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "EMsgMessage.h"
#import "EMsgDefine.h"

@protocol EMsgClientProtocol<NSObject>

@optional

/**重连服务器*/
- (void)autoReconnect;
/*登陆服务器成功*/
- (void)didAuthSuccessed;
/*登陆服务器失败*/
- (void)didAuthFailed:(NSString *)error;
/*发送信息成功*/
- (void)didSendMessageSuccessed:(long)tag;
/*发送信息失败*/
- (void)didSendMessageFailed:(long)tag;
/*登录超时的回调*/
- (void)reciveAuthTimeOut;
/*收到消息*/
- (void)didReceivedMessage:(EMsgMessage *)msg;
/*收到离线消息*/
- (void)didReceivedOfflineMessageArray:(NSArray *)array;
/*将要断开连接*/
- (void)willDisconnectWithError:(NSError *)err;
/*收到强制下线消息*/
- (void)didKilledByServer;

@end

@interface EMsgCilent : NSObject {
  NSMutableData *packetdata;
  BOOL hasAuth;
  BOOL isNetWorkAvailable;
}
@property(nonatomic,assign)id<EMsgClientProtocol>delegate;
@property(nonatomic, strong) NSString *kHost;
@property(nonatomic, assign) NSUInteger kPort;
/**
 *  登录账号
 */
@property(nonatomic, strong) NSString *jid;
/**
 *  登录密码
 */
@property(nonatomic, retain) NSString *pwd;
/**
 *  是否退出断开Socket通信
 */
@property(nonatomic, assign) BOOL isLogOut;
/**
 *  创建单例
 */
+ (instancetype)sharedInstance;
/**
 @method
 @brief 发起重新连接的请求
 @discussion
 */
- (void)autoReconnect;

/**
 @method
 @brief 登陆认证
 @discussion
 @param jid 登录账户
 @param password 登录密码
 */
- (BOOL)auth:(NSString *)username
withPassword:(NSString *)password
    withHost:(NSString *)host
    withPort:(NSUInteger)port;
/**
 *  发送所有消息入口
 *
 *  @param fromId         发送消息者
 *  @param toId           接收消息者
 *  @param mTargetType
 *消息类型:0：打开会话，1：普通聊天（1对1），2：群聊（一对多），3：状态同步（实现消息的事件同步，例如：已送达、已读
 *等），4：系统消息（服务端返回给客户端的通知），5：语音拨号（P2P服务拨号），6：视频（P2P服务拨号）7：订阅：（发布订阅）
 *  @param ack ack是否做校验：0：不确保对方是否收到消息，1：对方必然收到消息
 *  @param content        消息内容
 *  @param attrDictionary 消息的附加属性
 *  @param tag            消息的附加标记
 */
- (void)sendMessageWithToId:(NSString *)toId
             withTargetType:(MsgType)mTargetType
                      isAck:(BOOL)ack
                withContent:(NSString *)content
                  withAttrs:(NSDictionary *)attrDictionary
            withMessageMark:(NSInteger)tag;

/*!
 @method
 @brief 判断消息服务引擎状态
 @discussion
 @return YES 消息服务运行正常  NO 消息服务异常需要重新建立连接
 */

- (BOOL)isAuthed;

/*!
 @method
 @brief 登出消息服务
 @discussion 使用在不需要消息服务时关闭消息服务以节省内存占用
 */

- (void)logout;


@end

