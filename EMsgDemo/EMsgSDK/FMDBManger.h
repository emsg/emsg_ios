//
//  FMDBManger.h
//  FriendShop
//
//  Created by hawk on 15/8/16.
//  Copyright (c) 2015年 Sirius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "EMsgMessage.h"

typedef void (^selResultArray)(NSArray *resultArray);
typedef void(^resultCount)(NSInteger count);

@interface FMDBManger : NSObject
+ (instancetype)shareInstance;
@property(nonatomic, strong) FMDatabase *db;
@property(nonatomic, strong) NSString *database_path;


/**聊天记录 表*/
/**插入一条聊天消息*/
- (BOOL)insertOneMessage:(EMsgMessage *)message withChatter:(NSString *)chatter;
/**更新一条消息*/
- (void)updateOneMessage:(EMsgMessage *)message withChatter:(NSString *)chatter;
/**删除一条聊天消息*/
- (void)deleteOneMessage:(EMsgMessage *)message withChatter:(NSString *)chatter;
/**删除一个对话的所有聊天消息*/
- (void)deleteOneChatAllMessageWithChatter:(NSString *)chatter;
/**获取一个对话的聊天历史通过索引*/
- (NSMutableArray *)fetchOneChatMessage:(NSString *)index
                            withChatter:(NSString *)chatter;

- (NSMutableArray *)loadOneChatMessage:(NSString *)tm withChatter:(NSString *)chatter limite:(int)limite;

/**临时会话列表 表*/
/**插入一条临时会话列表*/
- (BOOL)insertOneChatList:(EMsgMessage *)message
              withChatter:(NSString *)chatter;
/**删除一条临时会话列表*/
- (void)deleteOneChatList:(EMsgMessage *)message
              withChatter:(NSString *)chatter;
/**获取临时会话列表*/
- (NSMutableArray *)fetchAllSelReslult;
/**更新一个会话的最后一条消息/更新一个临时会话列表为已点击*/
- (void)updateOneChatListMessageWithChatter:(NSString *)chatter andMessage:(EMsgMessage *)message;
/**获取所有的系统消息*/
- (void)fetchallServerMessage:(void(^)(NSArray * serverMessageArray))block;
/**获取所有未读消息数量*/
- (NSInteger)fetchAllUnreadMessageCount;
/**刷新所有未读系统消息为已读*/
- (void)updateAllServerMessageRead;
/**删除一个chatid对应的一条的系统消息*/
- (void)delOneServerMessage:(EMsgMessage *)message;
/**删除一条好友请求系统消息*/
- (void)delONeApplyServerMessage:(EMsgMessage *)message;
/**删除一条战队邀请*/
- (void)delONeApplyTeamApplicationMessage:(EMsgMessage *)message;
/**删除一调群申请*/
- (void)delONeApplyGroupApplicationMessage:(EMsgMessage *)message;
/**删除一条群邀请*/
- (void)delONeInviteGroupApplicationMessage:(EMsgMessage *)message;
/**删除所有同志消息*/
- (void)delAllNotiMessages;


/**删除一个chatid的临时会话列表*/
- (void)delOneChatIdAllMessage:(NSString *)chatter;
/**
 *  删除所有临时会话消息
 */
- (void)delAllChatListMessage;
/** 检索是否有删除好友消息，则删除*/


/** NSOporation */

/**
 *  查询未读消息数
 *
 *  @param noCC  所有未读消息回调,为了刷新tabbar显示
 *  @param noCCC 聊天消息未读回调,刷新消息button提示红点是否显示
 *  @param noSCC 系统消息未读回调,刷新通知button提示红点是否显示
 */
- (void)fetchAllNoReadMessage:(void(^)(NSInteger noCount))noCC andChatterCount:(void(^)(NSInteger noChatterCount))noCCC andServerCount:(void(^)(NSInteger noServerCount))noSCC;

- (void)loadOneChatMessage:(NSString *)tm withChatter:(NSString *)chatter limite:(int)limite withResult:(void(^)(NSMutableArray * resultArray))result;



@end
