//
//  EMDEngineManger.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/23.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDEngineManger.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "MJExtension.h"
#import "FMDBManger.h"

@interface EMDEngineManger()<GCDAsyncSocketDelegate>{
    NSMutableData *buffData;
    BOOL hasAuth;
    BOOL isNetWorkAvailable;
    NSTimer *recnnecttimer;
    NSTimer *hearttimer;
    GCDAsyncSocket *asyncSocket;
    Reachability *hostReach;
}
@end

@implementation EMDEngineManger

//socket 通信唯一连接,使用的单例模式

+ (instancetype)sharedInstance {
    static EMDEngineManger *_engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _engine = [[self alloc] init];
        _engine.isLogOut = YES;
        [_engine registerNetWorkStatus];
    });
    return _engine;
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
        if (![[EMDEngineManger sharedInstance] isAuthed] && [EMDEngineManger sharedInstance].isCheckingNetworkingToReConnect) {
            [self autoReconnect];
        }
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
    if (buffData != nil) {
        buffData = nil;
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
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
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


- (void)socket:(GCDAsyncSocket *)sock
didConnectToHost:(NSString *)host
            port:(UInt16)port {
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [sock readDataWithTimeout:-1 tag:0];
   
    [self asyncPreDispatchPacket:data];
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


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    if (_delegate && [_delegate respondsToSelector:@selector(
                                                             didSendMessageSuccessed:)]) //发送数据成功
    {
        [_delegate didSendMessageSuccessed:tag];
    }
}
- (void)socket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    if (_delegate && [_delegate respondsToSelector:@selector(willDisconnectWithError:)]) {
        [_delegate willDisconnectWithError:err];
    }
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
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

// Packet包预处理
- (void)asyncPreDispatchPacket:(NSData *)data{
    if (buffData == nil) {
        buffData = [[NSMutableData alloc] initWithCapacity:1];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t buffDataQueue = dispatch_queue_create("com.qiuyouzone.com", NULL);
    dispatch_async(buffDataQueue, ^{
        [buffData appendData:data];
        NSString *buffMsg = [[NSString alloc] initWithData:buffData encoding:NSUTF8StringEncoding];
        NSArray  *buffArray = [buffMsg componentsSeparatedByString:END_TAG];
        
        // 检测末尾字符串是否含有END_TAG
        BOOL isHasNoEndPacket = NO;
        if (buffMsg.length >= 3) {
            NSString * endString = [buffMsg substringFromIndex:buffMsg.length - 3];
            if ([endString isEqualToString:END_TAG]) {
                isHasNoEndPacket = YES;
            }
        }
        
        @autoreleasepool {
            for (NSString *msgString in buffArray) {
                
                if (msgString == buffArray.lastObject) {
                    [weakSelf packetFactory:msgString hasNoEndPacket:isHasNoEndPacket];
                }
                else{
                    [weakSelf packetFactory:msgString hasNoEndPacket:NO];
                }
            }
        }
    });
}

// 加工packet
- (void)packetFactory:(NSString *)packetString hasNoEndPacket:(BOOL)hasNoEnd{
    
    if (!hasNoEnd) {
        buffData = nil;
        NSRange foundkill =
        [packetString rangeOfString:SERVER_KILL options:NSBackwardsSearch];
        NSRange foundHeart =
        [packetString rangeOfString:HEART_BEAT options:NSBackwardsSearch];
        if (foundkill.location != NSNotFound) {
            [self packetToMssage:PACKET_KILL andPacketString:packetString];
        } else if (foundHeart.location != NSNotFound) {
            [self packetToMssage:PACKET_HEART andPacketString:packetString];
        }
        NSDictionary *dic = [packetString mj_JSONObject];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            [self packetToMssage:PACKET_END andPacketString:packetString];
        }
    }
    else{
        if (buffData == nil) {
            buffData = [[NSMutableData alloc] initWithCapacity:1];
        }
        NSData *jsonData = [packetString dataUsingEncoding:NSUTF8StringEncoding];
        [buffData appendData:jsonData];
    }
}

- (void)packetToMssage:(PacketType)pakcetType andPacketString:(NSString *)packetString{
    
    if (pakcetType == PACKET_KILL) //服务器强制断开数据流 强制下线
    {
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
        
    } else if (pakcetType ==
               PACKET_NOTEND) //由于太长的数据无法一次读入所以需要做特殊处理
    {
        
    } else if (pakcetType == PACKET_END) { //普通数据读取完成
        NSDictionary *dic = [packetString mj_JSONObject];
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
                [EMDEngineManger sharedInstance].isCheckingNetworkingToReConnect = YES;
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
    
    @try {
        [asyncSocket writeData:data withTimeout:-1 tag:0];
    } @catch (NSException *exception) {
        NSLog(@"NSException.name = %@" , exception.name);
        NSLog(@"NSException.reason = %@" , exception.reason);
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
    [NSTimer timerWithTimeInterval:HEART_BEAT_FREQ
                                     target:self
                                   selector:@selector(sendConnectHeart)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:hearttimer forMode:NSRunLoopCommonModes];
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
