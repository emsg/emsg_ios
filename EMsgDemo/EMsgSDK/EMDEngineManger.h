//
//  EMDEngineManger.h
//  EMsgDemo
//
//  Created by Hawk on 16/3/23.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "EMsgMessage.h"
#import "EMsgDefine.h"

@protocol EMDEngineMangerDelegate<NSObject>

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

@interface EMDEngineManger : NSObject

@property(nonatomic,assign)id<EMDEngineMangerDelegate>delegate;

@property(nonatomic, strong) NSString *kHost;

@property(nonatomic, assign) NSUInteger kPort;

@property(nonatomic, strong) NSString *jid;

@property(nonatomic, retain) NSString *pwd;

@property(nonatomic, assign) BOOL isLogOut;

+ (instancetype)sharedInstance;

- (void)autoReconnect;

- (BOOL)auth:(NSString *)username
withPassword:(NSString *)password
    withHost:(NSString *)host
    withPort:(NSUInteger)port;

- (void)sendMessageWithToId:(NSString *)toId
             withTargetType:(MsgType)mTargetType
                      isAck:(BOOL)ack
                withContent:(NSString *)content
                  withAttrs:(NSDictionary *)attrDictionary
            withMessageMark:(NSInteger)tag;

- (BOOL)isAuthed;

- (void)logout;

@end
