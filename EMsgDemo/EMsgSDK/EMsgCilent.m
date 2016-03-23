//
//  EMsgCilent.m
//  EmsClientDemo
//
//  Created by QYQ-Hawk on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import "EMsgCilent.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "MJExtension.h"
#import "FMDBManger.h"



@interface EMsgCilent(){
    /**
     *  自动重连
     */
    NSTimer *recnnecttimer;
    /**
     *  心跳
     */
    NSTimer *hearttimer;
    /**
     *  Socket单例
     */
    AsyncSocket *asyncSocket;
    /**
     *  网络连接状态
     */
    Reachability *hostReach;
}
@end


@implementation EMsgCilent

//+ (instancetype)sharedInstance {
//    static EMsgCilent *shareEMsgClient = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        shareEMsgClient = [[self alloc] init];
//        shareEMsgClient.isLogOut = YES;
//        [shareEMsgClient registerNetWorkStatus];
//        
//    });
//    return shareEMsgClient;
//}


static EMsgCilent *_instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.isLogOut = YES;
        [_instance registerNetWorkStatus];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        [self closeSocket];
        isNetWorkAvailable = NO;
    } else {
        isNetWorkAvailable = YES;
        [self autoReconnect];
    }
}
- (void)registerNetWorkStatus {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reachabilityChanged:)
     name:kReachabilityChangedNotification
     object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
}
//设置当前代理对象
- (void)setDelegate:(id)thedelegeate {
    _delegate = thedelegeate;
}
//判断当前认证状态
- (BOOL)isAuthed {
    if (asyncSocket != nil) {
        if (asyncSocket.isConnected && hasAuth) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}
//关闭socket通道
- (void)closeSocket {
    
    hasAuth = NO;
    if (asyncSocket != nil) {
        [asyncSocket disconnect];
    }
    if (hearttimer != nil) {
        [hearttimer invalidate];
        hearttimer = nil;
    }
    if (recnnecttimer != nil) {
        [recnnecttimer invalidate];
        recnnecttimer = nil;
    }
}
/*
 关闭消息服务引擎
 */
- (void)logout {
    
    [self closeSocket];
    [self setIsLogOut:YES];
#pragma mark -- 即使退出登录一样调用网络检测,因为,退出依然可以使用APP
    //    [hostReach stopNotifier];
    
    if (self.jid != nil) {
        self.jid = nil;
    }
    if (self.pwd != nil) {
        self.pwd = nil;
    }
    if (packetdata != nil) {
        packetdata = nil;
    }
}
- (BOOL)auth:(NSString *)username
withPassword:(NSString *)password
    withHost:(NSString *)host
    withPort:(NSUInteger)port {
    if (self.jid != nil) {
        self.jid = nil;
    }
    self.jid = username;
    if (self.pwd != nil) {
        self.pwd = nil;
    }
    self.pwd = password;
    self.kHost = host;
    self.kPort = port;
    return [self connectServer:username
                  withPassword:password
                      withHost:host
                      withPort:port];
}
- (BOOL)connectServer:(NSString *)username
         withPassword:(NSString *)password
             withHost:(NSString *)host
             withPort:(NSUInteger)port {
    NSError *err = nil;
    
    if (asyncSocket != nil) {
        asyncSocket.delegate = nil;
        asyncSocket = nil;
    }
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    if (![asyncSocket connectToHost:host
                             onPort:port
                        withTimeout:-1
                              error:&err]) //连接失败
    {
        return NO;
    }
    
    NSMutableDictionary *envelope = [NSMutableDictionary dictionary];
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString *)CFBridgingRelease(
                                                           CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    [envelope setObject:cfuuidString forKey:@"id"];
    [envelope setObject:[NSNumber numberWithInt:MSG_TYPE_OPEN_SESSION]
                 forKey:@"type"];
    [envelope setObject:username forKey:@"jid"];
    [envelope setObject:password forKey:@"pwd"];
    
    NSMutableDictionary *root = [NSMutableDictionary dictionaryWithCapacity:1];
    [root setObject:envelope forKey:@"envelope"];
    
    NSString *logininfo =
    [NSString stringWithFormat:@"%@%@", [root mj_JSONString], END_TAG];
    NSData *data = [logininfo dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data withTimeout:-1 tag:0];
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock
didConnectToHost:(NSString *)host
            port:(UInt16)port {
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock
     didReadData:(NSData *)data
         withTag:(long)tag {
    
    [sock readDataWithTimeout:-1 tag:0];
    PacketType pakcetType = [self isPacketEnd:data];
    if (pakcetType == PACKET_KILL) //服务器强制断开数据流 强制下线
    {
        packetdata = nil;
        
        hasAuth = NO;
        
        if (hearttimer != nil) //  强制下线 关闭心跳包
        {
            [hearttimer invalidate];
            hearttimer = nil;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(didKilledByServer)]) {
            [_delegate didKilledByServer];
            [self logout];
        }
    } else if (pakcetType == PACKET_HEART) //心跳包数据流
    {
        packetdata = nil;
        
    } else if (pakcetType ==
               PACKET_NOTEND) //由于太长的数据无法一次读入所以需要做特殊处理
    {
        
    } else if (pakcetType == PACKET_END) { //普通数据读取完成
        NSString *msg = [[NSString alloc] initWithData:packetdata
                                              encoding:NSUTF8StringEncoding];
        packetdata = nil;
        
        NSRange foundEnd = [msg rangeOfString:END_TAG options:NSBackwardsSearch];
        NSString *msgdictory = [msg substringToIndex:foundEnd.location];
        NSDictionary *dic = [msgdictory mj_JSONObject];
        NSDictionary *envelope = [dic objectForKey:@"envelope"];
        
        int type = [[envelope objectForKey:@"type"] intValue];
        
        
        
        if (type == MSG_TYPE_OPEN_SESSION) //登陆验证返回
        {
            NSDictionary *entity = [dic objectForKey:@"entity"];
            NSString *result = [entity objectForKey:@"result"];
            NSDictionary *envelope = [dic objectForKey:@"envelope"];
            
            if (result != nil && [result isEqual:@"ok"]) //登陆成功
            {
                hasAuth = YES;
                [self setIsLogOut:NO];
                [self sendHeartPacket]; //发送心跳包
                if (_delegate && [_delegate respondsToSelector:@selector(didAuthSuccessed)]) {
                    [_delegate didAuthSuccessed];
                }
                //执行登陆成功的消息回执
                if (envelope != nil) {
                    
                    NSString *mid = [envelope objectForKey:@"id"];
                    int mtype = [[envelope objectForKey:@"type"] intValue];
                    
                    if (mtype == 0 && mid != nil) {
                        
                        [self sendAckMsg:mid];
                    }
                }
                
                NSDictionary *delay = [dic objectForKey:@"delay"];
                NSArray *array = [delay objectForKey:@"packets"];
                if (array != nil) {
                    NSMutableArray *msgArray = [[NSMutableArray alloc] init];
                    for (int i = 0; i < [array count]; i++) {
                        NSDictionary *dic = [array objectAtIndex:i];
                        EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
                        [msgArray addObject:msg];
                        
                        if ([msg.envelope.ack intValue] == 1) {
                            [self sendAckMsg:msg.envelope.uid]; //普通消息需要回执
                        }
                    }
                    if ([msgArray count] > 0) //离线消息
                    {
                        if (_delegate && [_delegate respondsToSelector:@selector(
                                                                                 didReceivedOfflineMessageArray:)]) {
                            [_delegate didReceivedOfflineMessageArray:msgArray];
                        }
                    }
                }
            } else {
                hasAuth = NO;
                if (_delegate && [_delegate respondsToSelector:@selector(didAuthFailed:)]) {
                    NSString *reason = [entity objectForKey:@"reason"];
                    [_delegate didAuthFailed:reason];
                }
            }
        } else if (type == MSG_TYPE_CHAT ||
                   type == MSG_TYPE_GROUP_CHAT) //聊天消息返回
        {
            EMsgMessage *msg = [[EMsgMessage alloc] init];
            msg = [EMsgMessage mj_objectWithKeyValues:dic];
            
            if ([msg.envelope.ack intValue] == 1) {
                [self sendAckMsg:msg.envelope.uid]; //普通消息需要回执
            }
            if (_delegate && [_delegate respondsToSelector:@selector(didReceivedMessage:)]) {
                [_delegate didReceivedMessage:msg];
            }
        }
        
        else if (type == MSG_TYPE_STATE) // ack  返回  暂不处理
        {
        }
        else if (type >= 100 && type <= 111) {
            EMsgMessage *msg = [[EMsgMessage alloc] init];
            msg = [EMsgMessage mj_objectWithKeyValues:dic];
            
            if ([msg.envelope.ack intValue] == 1) {
                [self sendAckMsg:msg.envelope.uid]; //普通消息需要回执
            }
            if (_delegate && [_delegate respondsToSelector:@selector(didReceivedMessage:)]) {
                [_delegate didReceivedMessage:msg];
            }
            
        }
    }
}

- (void)sendMessageWithToId:(NSString *)toId
             withTargetType:(MsgType)mTargetType
                      isAck:(BOOL)ack
                withContent:(NSString *)content
                  withAttrs:(NSDictionary *)attrDictionary
            withMessageMark:(NSInteger)tag {
    
    //存储的fromId
    //  NSString * storeFromeId = toId;
    
    
    int type = mTargetType == SINGLECHAT ? MSG_TYPE_CHAT : MSG_TYPE_GROUP_CHAT;
    
    NSMutableDictionary *envelope = [NSMutableDictionary dictionary];
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString *)CFBridgingRelease(
                                                           CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    [envelope setObject:cfuuidString forKey:@"id"];
    [envelope setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [envelope setObject:self.jid forKey:@"from"];
    [envelope setObject:ack ? @1 :@0 forKey:@"ack"];
    //单聊,需要在信封添加to字段
    if (type == 1) {
        [envelope setObject:toId forKey:@"to"];
    }
    //群聊,需要在信封添加gid字段
    if (type == 2) {
        [envelope setObject:toId forKey:@"gid"];
        [envelope setObject:[NSString stringWithFormat:@"group%@@",toId] forKey:@"from"];
        
    }
    
    
    NSMutableDictionary *root = [NSMutableDictionary dictionaryWithCapacity:1];
    [root setObject:envelope forKey:@"envelope"];
    
    
    
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    [payload setObject:content forKey:@"content"];
    if (attrDictionary) {
        ZXUser *userModel = [ZXCommens fetchUser];
        
        NSMutableDictionary *attDic =
        [[NSMutableDictionary alloc] initWithDictionary:attrDictionary];
        if (userModel.icon) {
            [attDic setObject:userModel.icon forKey:@"messageFromHeaderUrl"];
        }
        if (userModel.nickname) {
            [attDic setObject:userModel.nickname forKey:@"messageFromNickName"];
        }if(userModel.birthday)
        {
            NSString * age = [userModel.birthday substringToIndex:4];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *destDateString = [dateFormatter stringFromDate:[NSDate new]];
            int  nowYear = [[destDateString substringToIndex:4] intValue];
            int  birthYesar = [age intValue];
            age = [NSString stringWithFormat:@"%d",nowYear - birthYesar];
            [attDic setObject:[NSString stringWithFormat:@"%@",age] forKey:@"messageFromAge"];
        }if (userModel.gender) {
            [attDic setObject:userModel.gender forKey:@"messageFromSex"];
        }
        [payload setObject:attDic forKey:@"attrs"];
    }
    [root setObject:payload forKey:@"payload"];
    
    //群组重新拼装envelope
    NSMutableDictionary * reGroupDic = root;
    if (type == 2) {
        NSMutableDictionary * reDic = envelope;
        [reDic setObject:self.jid forKey:@"from"];
        NSMutableDictionary * reGroupDic = root;
        [reGroupDic setObject:reDic forKey:@"envelope"];
    }
    
    //转化成消息实例
    EMsgMessage * storeMessage = [EMsgMessage mj_objectWithKeyValues:root];
    
    
    //把消息存入数据库 begin
    NSRange chechStrRange = [toId rangeOfString:@"@"];
    if (chechStrRange.location != NSNotFound) {
        NSString * chatterId = [toId substringToIndex:chechStrRange.location];
        storeMessage.isReaded = @"yes";
        storeMessage.isSendFail = NO;
        storeMessage.envelope.ct = [ZXCommens creatMSTimastmap];
        storeMessage.isMe = YES;
        [[FMDBManger shareInstance] insertOneMessage:storeMessage withChatter:chatterId];
    }
    if (type == 2) {
        NSString * chatterId = [NSString stringWithFormat:@"group%@",toId];
        storeMessage.envelope.ct = [ZXCommens creatMSTimastmap];
        storeMessage.isMe = YES;
        [[FMDBManger shareInstance] insertOneMessage:storeMessage withChatter:chatterId];
        
        
    }
    //把消息存入数据 end
    
    NSString *sendcontent =
    [NSString stringWithFormat:@"%@%@", [root mj_JSONString], END_TAG];
    if (type == 2) {
        sendcontent = [NSString stringWithFormat:@"%@%@", [reGroupDic mj_JSONString], END_TAG];
    }
    NSData *data = [sendcontent dataUsingEncoding:NSUTF8StringEncoding];
    
    NSInteger messageTag = [storeMessage.envelope.ct integerValue];
    //此处替换tag方便更新消息是否发送成功，更新数据库标识
    @try {
        [asyncSocket writeData:data withTimeout:-1 tag:messageTag];
    } @catch (NSException *exception) {
        if (_delegate && [_delegate respondsToSelector:@selector(didSendMessageFailed:)]) //发送数据失败
        {
            [_delegate didSendMessageFailed:messageTag];
        }
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    if (_delegate && [_delegate respondsToSelector:@selector(
                                                             didSendMessageSuccessed:)]) //发送数据成功
    {
        [_delegate didSendMessageSuccessed:tag];
    }
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    if (_delegate && [_delegate respondsToSelector:@selector(willDisconnectWithError:)]) {
        [_delegate willDisconnectWithError:err];
    }
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"sock = %@", sock);
    if (hasAuth) //开启断线重连
    {
        if (hearttimer != nil) //断线重连过程不发送心跳包
        {
            [hearttimer invalidate];
            hearttimer = nil;
        }
        [self autoReconnect];
    }
    hasAuth = NO;
    
    if ([_delegate respondsToSelector:@selector(reciveAuthTimeOut)]) {
        [_delegate reciveAuthTimeOut];
    }
}

- (int)isPacketEnd:(NSData *)data {
    if (packetdata == nil) {
        packetdata = [[NSMutableData alloc] initWithCapacity:1];
    }
    [packetdata appendData:data];
    NSString *msg =
    [[NSString alloc] initWithData:packetdata encoding:NSUTF8StringEncoding];
    NSRange foundEnd = [msg rangeOfString:END_TAG options:NSBackwardsSearch];
    
    if (foundEnd.location != NSNotFound) {
        NSRange foundkill =
        [msg rangeOfString:SERVER_KILL options:NSBackwardsSearch];
        NSRange foundHeart =
        [msg rangeOfString:HEART_BEAT options:NSBackwardsSearch];
        if (foundkill.location != NSNotFound) {
            
            return PACKET_KILL;
        } else if (foundHeart.location != NSNotFound) {
            return PACKET_HEART;
        }
        NSString *msgdictory = [msg substringToIndex:foundEnd.location];
        NSDictionary *dic = [msgdictory mj_JSONObject];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            return PACKET_END;
        }
    }
    return PACKET_NOTEND;
}
/*发送消息回执*/
- (void)sendAckMsg:(NSString *)msgid {
    NSMutableDictionary *envelope = [NSMutableDictionary dictionary];
    if(msgid)
    {
        [envelope setObject:msgid forKey:@"id"];
    }
    [envelope setObject:[NSNumber numberWithInt:MSG_TYPE_STATE] forKey:@"type"];
    [envelope setObject:SERVER_ACK forKey:@"to"];
    [envelope setObject:self.jid forKey:@"from"];
    
    NSMutableDictionary *root = [NSMutableDictionary dictionaryWithCapacity:1];
    [root setObject:envelope forKey:@"envelope"];
    
    NSString *sendcontent =
    [NSString stringWithFormat:@"%@%@", [root mj_JSONString], END_TAG];
    NSData *data = [sendcontent dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"asyn = %@",asyncSocket);
    @try {
        [asyncSocket writeData:data withTimeout:-1 tag:0];
    } @catch (NSException *exception) {
        
    }
}
/*断线自动重连*/
- (void)autoReconnect {
    
    [self stopReconnect];
    recnnecttimer =
    [NSTimer scheduledTimerWithTimeInterval:RECONNECT_FREQ
                                     target:self
                                   selector:@selector(time_to_connect)
                                   userInfo:nil
                                    repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:recnnecttimer
                                 forMode:NSRunLoopCommonModes];
}
- (void)stopReconnect {
    
    if (recnnecttimer != nil) {
        [recnnecttimer invalidate];
        recnnecttimer = nil;
    }
}
- (void)time_to_connect {
    if ([self isLogOut])
        return;
    
    if ([self connectServer:self.jid
               withPassword:self.pwd
                   withHost:self.kHost
                   withPort:self.kPort]) //连接成功 断开自动重连
    {
        if (recnnecttimer != nil) {
            [recnnecttimer invalidate];
            recnnecttimer = nil;
        }
    }
}
/*心跳包*/
- (void)sendHeartPacket {
    [self stopHeartPacket];
    hearttimer =
    [NSTimer scheduledTimerWithTimeInterval:HEART_BEAT_FREQ
                                     target:self
                                   selector:@selector(sendConnectHeart)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:hearttimer forMode:NSRunLoopCommonModes];
}

- (void)stopHeartPacket {
    if (hearttimer != nil) {
        [hearttimer invalidate];
        hearttimer = nil;
    }
}

- (void)sendConnectHeart {
    if ([self isLogOut])
        return;
    NSData *data = [HEART_BEAT dataUsingEncoding:NSUTF8StringEncoding];
    @try {
        NSLog(@"heart beat ---------");
        [asyncSocket writeData:data withTimeout:-1 tag:0];
    } @catch (NSException *exception) {
        [self closeSocket];
        [self autoReconnect];
    }
}

@end
