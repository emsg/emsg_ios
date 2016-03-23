//
//  FMDBManger.m
//  FriendShop
//
//  Created by hawk on 15/8/16.
//  Copyright (c) 2015年 Sirius. All rights reserved.
//

#import "FMDBManger.h"
#import "MJExtension.h"

#define DBNAME @"QiuYouQuan201.db"
#define ID @"id"


/**聊天记录*/
#define CHAT_HISTORY @"emsg_talk_history"
#define CHAT_ID @"chat_id"
#define CHAT_LAST_MESSAGE @"message"
#define CHAT_TIMESTMAP @"timestmap"
#define CHAT_IS_READ @"is_read"
#define CHAT_IS_CLICKED @"is_clicked"


/**临时会话列表*/
#define CHAT_LIST_HISTORY @"emsg_talk_list_history"
#define CHAT_LIST_ID @"chat_id"
#define CHAT_LIST_LAST_MESSAGE @"last_message"
#define CHAT_LIST_TYPE @"chat_list_type"
#define CHAT_LIST_TIMESTMAP @"timestmap"

@implementation FMDBManger
static FMDBManger *_sharedFMDBManger = nil;

+ (instancetype)shareInstance {
    
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        _sharedFMDBManger = [[FMDBManger alloc] init];
        return _sharedFMDBManger;
    }
    _sharedFMDBManger = [[FMDBManger alloc] init];
    [_sharedFMDBManger createChatHistoryTable];
    [_sharedFMDBManger createChatListTable];
    
    return _sharedFMDBManger;
}


#pragma mark--
#pragma 聊天记录的数据库操作API

- (void)createChatHistoryTable {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    self.database_path = [documents stringByAppendingPathComponent:DBNAME];
    self.db = [FMDatabase databaseWithPath:self.database_path];
    
    [self.db open];
    if ([self.db open]) {
        NSString *tableName = [NSString
                               stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
        NSString *sqlCreateTable = [NSString
                                    stringWithFormat:
                                    @"CREATE TABLE IF NOT EXISTS '%@' ('%@' VARCHAR(36) PRIMARY "
                                    @"KEY , '%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT ,'%@' TEXT)",
                                    tableName, ID, CHAT_ID, CHAT_LAST_MESSAGE, CHAT_TIMESTMAP,CHAT_IS_READ,CHAT_IS_CLICKED];
        BOOL res = [self.db executeUpdate:sqlCreateTable];
        if (!res) {
//            NSLog(@"error when creating db table 1");
        } else {
//            NSLog(@"success to creating db table");
        }
    }
    [self.db close];
}

- (BOOL)insertOneMessage:(EMsgMessage *)message
             withChatter:(NSString *)chatter {
    
    message.storeId = [ZXCommens creatMSTimastmap];
    
    //添加消息主键,服务器发送过来的消息自带uid,自己发送的不带,给其构造一个
    if (!message.envelope.uid) {
        message.envelope.uid = [ZXCommens creatUUID];
    }
    
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return NO;
    }
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
    //将对象转成字典，字典转字符串存入本地
    //务必把对话chatId传入
    message.chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,chatter];
    NSDictionary *messageDic = [message mj_keyValues];
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:messageDic options:0 error:nil];
    NSString *myString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.db open];
    if ([self.db open]) {
        NSString *insertSql = [NSString
                               stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@') ",
                               tableName,ID, CHAT_ID, CHAT_LAST_MESSAGE, CHAT_TIMESTMAP,CHAT_IS_READ,message.envelope.uid ,chatId,
                               myString, message.storeId ,message.isReaded];
        BOOL res = [self.db executeUpdate:insertSql];
        
        if (!res) {
//            NSLog(@"error when insert db table 2");
            [self.db close];
            return NO;
        } else {
//            NSLog(@"success to insert db table");
            [self.db close];
            return YES;
        }
    }
    return NO;
}

- (void)updateOneMessage:(EMsgMessage *)message withChatter:(NSString *)chatter{
    ZXUser * userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
    //将对象转成字典，字典转字符串存入本地
    NSDictionary *messageDic = [message mj_keyValues];
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:messageDic options:0 error:nil];
    NSString *myString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self.db open];
    if ([self.db open]) {
        NSString *updateSql = [NSString
                               stringWithFormat:
                               @"UPDATE '%@' SET message = '%@' WHERE chat_id = '%@' AND timestmap = '%@'",
                               tableName,myString,chatId,message.storeId];
        BOOL res = [self.db executeUpdate:updateSql];
        if (!res) {
//            NSLog(@"error to update data: %@", @"error");
        } else {
//            NSLog(@"succ to update data: %@", @"success");
        }
    }
    [self.db close];
}


- (void)deleteOneMessage:(EMsgMessage *)message
             withChatter:(NSString *)chatter {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delSql = [NSString
                            stringWithFormat:@"DELETE FROM '%@' WHERE chat_id='%@' AND timestmap ='%@' ",
                            tableName, chatId,
                            message.storeId];
        BOOL res = [self.db executeUpdate:delSql];
        
        if (!res) {
//            NSLog(@"error when delete db table 3");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}

- (void)deleteOneChatAllMessageWithChatter:(NSString *)chatter {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id ='%@'",
         tableName, chatId];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table 4");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}
- (NSMutableArray *)fetchOneChatMessage:(NSString *)index
                            withChatter:(NSString *)chatter{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return [[NSMutableArray alloc] init];
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    
    [self.db open];
    if ([self.db open]) {
        NSString *sql = [NSString
                         stringWithFormat:
                         //                             @"SELECT * FROM '%@' where chat_id ='%@'",
                         //                             tableName,chatId];
                         
                         @"SELECT * FROM '%@' WHERE chat_id ='%@' AND timestmap >= '%@' order by timestmap DESC",
                         tableName, chatId,index];
        FMResultSet *rs = [self.db executeQuery:sql];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while ([rs next]) {
            // int Id = [rs intForColumn:ID];
            //            NSString * name = [rs stringForColumn:NAME];
            //            NSString * age = [rs stringForColumn:AGE];
            NSString *jsonString = [rs stringForColumn:CHAT_LAST_MESSAGE];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:NSJSONReadingMutableContainers
                                 error:&err];
            EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
            [arr addObject:msg];
        }
        NSMutableArray * sortArray = [[NSMutableArray alloc] init];
        for (NSInteger i = arr.count - 1; i >= 0; i--) {
            [sortArray addObject:[arr objectAtIndex:i]];
        }
        [self.db close];
        return sortArray;
    }
    return [[NSMutableArray alloc] init];
}

- (NSMutableArray *)loadOneChatMessage:(NSString *)tm withChatter:(NSString *)chatter limite:(int)limite{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return [[NSMutableArray alloc] init];
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    [self.db open];
    if ([self.db open]) {
        NSString *sql = [NSString
                         stringWithFormat:
                         //                             @"SELECT * FROM '%@' where chat_id ='%@'",
                         //                             tableName,chatId];
                         
                         @"SELECT * FROM '%@' WHERE chat_id ='%@' and timestmap < '%@' order by timestmap DESC Limit '%d' ",
                         tableName, chatId,tm,limite];
        FMResultSet *rs = [self.db executeQuery:sql];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while ([rs next]) {
            // int Id = [rs intForColumn:ID];
            //            NSString * name = [rs stringForColumn:NAME];
            //            NSString * age = [rs stringForColumn:AGE];
            NSString *jsonString = [rs stringForColumn:CHAT_LAST_MESSAGE];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:NSJSONReadingMutableContainers
                                 error:&err];
            EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
            [arr addObject:msg];
        }
        NSMutableArray * sortArray = [[NSMutableArray alloc] init];
        for (NSInteger i = arr.count - 1; i >= 0; i--) {
            [sortArray addObject:[arr objectAtIndex:i]];
        }
        [self.db close];
        return sortArray;
    }
    return [[NSMutableArray alloc] init];
    
}

#pragma mark---
#pragma 临时会话列表的数据库操作

- (void)createChatListTable {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    self.database_path = [documents stringByAppendingPathComponent:DBNAME];
    self.db = [FMDatabase databaseWithPath:self.database_path];
    
    [self.db open];
    if ([self.db open]) {
        NSString *tableName = [NSString
                               stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
        NSString *sqlCreateTable =
        [NSString stringWithFormat:
         @"CREATE TABLE IF NOT EXISTS '%@' ('%@' VARCHAR(36) PRIMARY "
         @"KEY, '%@' TEXT,'%@' TEXT,'%@' TEXT , '%@' TEXT)",
         tableName, ID, CHAT_ID, CHAT_LIST_LAST_MESSAGE,CHAT_LIST_TYPE,CHAT_LIST_TIMESTMAP];
        BOOL res = [self.db executeUpdate:sqlCreateTable];
        if (!res) {
//            NSLog(@"error when creating list db table");
        } else {
//            NSLog(@"success to creating list db table");
        }
    }
    [self.db close];
}

- (BOOL)insertOneChatList:(EMsgMessage *)message
              withChatter:(NSString *)chatter {
    
    message.storeId = [ZXCommens creatMSTimastmap];
    //添加消息主键,服务器发送过来的消息自带uid,自己发送的不带,给其构造一个
    if (!message.envelope.uid) {
        message.envelope.uid = [ZXCommens creatUUID];
    }
    
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return NO;
    }
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    //将对象转成字典，字典转字符串存入本地
    NSDictionary *messageDic = [message mj_keyValues];
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:messageDic options:0 error:nil];
    NSString *myString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self.db open];
    if ([self.db open]) {
        NSString *insertSql = [NSString
                               stringWithFormat:@"INSERT INTO '%@' ('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@') ",
                               tableName,ID, CHAT_LIST_ID, CHAT_LIST_LAST_MESSAGE,CHAT_LIST_TYPE,CHAT_LIST_TIMESTMAP,message.envelope.uid,chatId,
                               myString,message.envelope.type,message.storeId];
        BOOL res = [self.db executeUpdate:insertSql];
        if (!res) {
//            NSLog(@"error to inster data: %@", @"error");
            [self.db close];
            return NO;
        } else {
//            NSLog(@"succ to inster data: %@", @"success");
            [self.db close];
            return YES;
        }
    }
    return NO;
}

- (void)deleteOneChatList:(EMsgMessage *)message
              withChatter:(NSString *)chatter {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    NSString *tableName =
    [NSString stringWithFormat:@"%@%@", userModel.uid,
     CHAT_LIST_HISTORY];
    
    [self.db open];
    if ([self.db open]) {
        NSString *insertSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id ='%@' AND (chat_list_type = '1' or chat_list_type = '2')",
         tableName, chatId];
        BOOL res = [self.db executeUpdate:insertSql];
        if (!res) {
//            NSLog(@"error to del data: %@", @"error");
        } else {
//            NSLog(@"succ to del data: %@", @"success");
        }
    }
    [self.db close];
    
}

- (void)fetchallServerMessage:(void (^)(NSArray *))block {
    
    ZXUser *userModel = [ZXCommens fetchUser];
    
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.database_path];
    dispatch_queue_t q1 = dispatch_queue_create("queue2", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(FMDatabase *db2) {
            
            NSString *selSql =
            [NSString stringWithFormat:@"SELECT * FROM '%@' where chat_list_type = '100' or chat_list_type = '101' or chat_list_type = '102' or chat_list_type = '103' or chat_list_type = '109' or chat_list_type = '108' or chat_list_type = '111' or chat_list_type = '110' order by timestmap DESC", tableName];
            FMResultSet *rs = [db2 executeQuery:selSql];
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            while ([rs next]) {
                NSString *jsonString = [rs stringForColumn:CHAT_LIST_LAST_MESSAGE];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization
                                     JSONObjectWithData:jsonData
                                     options:NSJSONReadingMutableContainers
                                     error:&err];
                EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
                [arr addObject:msg];
            }
            block(arr);
        }];
    });
    
}

- (NSMutableArray *)fetchAllSelReslult {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return [[NSMutableArray alloc] init];
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    [self.db open];
    if ([self.db open]) {
        NSString *sql =
        [NSString stringWithFormat:@"SELECT * FROM '%@' where chat_list_type = '1' or chat_list_type = '2' order by timestmap DESC", tableName];
        FMResultSet *rs = [self.db executeQuery:sql];
        while ([rs next]) {
            NSString *jsonString = [rs stringForColumn:CHAT_LIST_LAST_MESSAGE];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:NSJSONReadingMutableContainers
                                 error:&err];
            EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
            
            [arr addObject:msg];
        }
        return arr;
    }
    [self.db close];
    return [[NSMutableArray alloc] init];
}

- (NSInteger)fetchAllUnreadMessageCount {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return 0;
    }
    
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    NSInteger arr = 0;
    
    [self.db open];
    if ([self.db open]) {
        NSString *sql =
        [NSString stringWithFormat:@"SELECT * FROM '%@' ", tableName];
        FMResultSet *rs = [self.db executeQuery:sql];
        while ([rs next]) {
            NSString *jsonString = [rs stringForColumn:CHAT_LIST_LAST_MESSAGE];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:NSJSONReadingMutableContainers
                                 error:&err];
            EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
            arr += [msg.unReadCountStr integerValue];
        }
        return arr;
    }
    [self.db close];
    return 0;
}



- (void)updateOneChatListMessageWithChatter:(NSString *)chatter andMessage:(EMsgMessage *)message{
    ZXUser * userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    //将对象转成字典，字典转字符串存入本地
    NSDictionary *messageDic = [message mj_keyValues];
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:messageDic options:0 error:nil];
    NSString *myString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self.db open];
    if ([self.db open]) {
        NSString *updateSql = [NSString
                               stringWithFormat:
                               @"UPDATE '%@' SET last_message = '%@' WHERE chat_id = '%@' AND (chat_list_type = '1' or chat_list_type = '2')",
                               tableName,myString,chatId];
        BOOL res = [self.db executeUpdate:updateSql];
        if (!res) {
//            NSLog(@"error to update data: %@", @"error");
        } else {
//            NSLog(@"succ to update data: %@", @"success");
        }
    }
    [self.db close];
}

- (void)updateAllServerMessageRead{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return ;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    [self.db open];
    if ([self.db open]) {
        NSString *sql =
        [NSString stringWithFormat:@"SELECT * FROM '%@' where chat_list_type = '100' or chat_list_type = '101' or chat_list_type = '102' or chat_list_type = '103' or chat_list_type = '109' or chat_list_type = '108' or chat_list_type = '111' or chat_list_type = '110' ", tableName];
        FMResultSet *rs = [self.db executeQuery:sql];
        while ([rs next]) {
            NSString *jsonString = [rs stringForColumn:CHAT_LIST_LAST_MESSAGE];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:NSJSONReadingMutableContainers
                                 error:&err];
            EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
            msg.unReadCountStr = @"0";
            [arr addObject:msg];
        }
        
        for (EMsgMessage * upMessage in arr) {
            //将对象转成字典，字典转字符串存入本地
            NSDictionary *messageDic = [upMessage mj_keyValues];
            NSData *jsonData =
            [NSJSONSerialization dataWithJSONObject:messageDic options:0 error:nil];
            NSString *myString =
            [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *updateSql = [NSString
                                   stringWithFormat:
                                   @"UPDATE '%@' SET last_message = '%@' WHERE timestmap = '%@'",
                                   tableName,myString,upMessage.storeId];
            BOOL res = [self.db executeUpdate:updateSql];
            if (!res) {
//                NSLog(@"error to update data: %@", @"error");
            } else {
//                NSLog(@"succ to update data: %@", @"success");
            }
        }
    }
    [self.db close];
    
}

- (void)delOneServerMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE timestmap ='%@'",
         tableName, message.storeId];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}

- (void)delONeApplyServerMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '100'",
         tableName, chatId];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}

- (void)delONeApplyTeamApplicationMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '109'",
         tableName, chatId];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}

- (void)delONeApplyGroupApplicationMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '108'",
         tableName, chatId];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}
- (void)delONeInviteGroupApplicationMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '110'",
         tableName, chatId];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}

- (void)delOneChatIdAllMessage:(NSString *)chatter{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,chatter];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id ='%@' ",
         tableName, chatId];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}

- (void)delAllChatListMessage{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@'",
         tableName];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }
}

- (void)fetchAllNoReadMessage:(void (^)(NSInteger))noCC andChatterCount:(void (^)(NSInteger))noCCC andServerCount:(void (^)(NSInteger))noSCC{
    ZXUser *userModel = [ZXCommens fetchUser];
    
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.database_path];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(FMDatabase *db2) {
            
            NSString *insertSql1= [NSString stringWithFormat:@"SELECT * FROM '%@' ", tableName];
            FMResultSet *rs = [db2 executeQuery:insertSql1];
            int cCount = 0;
            int sCount = 0;
            while ([rs next]) {
                NSString *jsonString = [rs stringForColumn:CHAT_LIST_LAST_MESSAGE];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization
                                     JSONObjectWithData:jsonData
                                     options:NSJSONReadingMutableContainers
                                     error:&err];
                EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
                //统计单聊/群聊的未读消息数量
                if ([msg.envelope.type isEqualToString:@"1"] || [msg.envelope.type isEqualToString:@"2"] ) {
                    cCount += [msg.unReadCountStr integerValue];
                }
                //统计系统消息的数量
                else{
                    sCount += [msg.unReadCountStr integerValue];
                }
            }
            noCC(cCount + sCount);
            noCCC(cCount);
            noSCC(sCount);
        }];
    });
}

- (void)loadOneChatMessage:(NSString *)tm withChatter:(NSString *)chatter limite:(int)limite withResult:(void(^)(NSMutableArray * resultArray))result{
    ZXUser *userModel = [ZXCommens fetchUser];
    
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
    NSString *chatId =
    [NSString stringWithFormat:@"%@%@", userModel.uid, chatter];
    
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.database_path];
    dispatch_queue_t q1 = dispatch_queue_create("queue2", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(FMDatabase *db2) {
            
            NSString *insertSql1= [NSString
                                   stringWithFormat:
                                   @"SELECT * FROM '%@' WHERE chat_id ='%@' and timestmap < '%@' order by timestmap DESC Limit '%d' ",
                                   tableName, chatId,tm,limite];
            FMResultSet *rs = [db2 executeQuery:insertSql1];
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            while ([rs next]) {
                NSString *jsonString = [rs stringForColumn:CHAT_LAST_MESSAGE];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization
                                     JSONObjectWithData:jsonData
                                     options:NSJSONReadingMutableContainers
                                     error:&err];
                EMsgMessage *msg = [EMsgMessage mj_objectWithKeyValues:dic];
                [arr addObject:msg];
            }
            NSMutableArray * sortArray = [[NSMutableArray alloc] init];
            for (NSInteger i = arr.count - 1; i >= 0; i--) {
                [sortArray addObject:[arr objectAtIndex:i]];
            }
            result(sortArray);
        }];
    });
}

- (void)delAllNotiMessages{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    [self.db open];
    if ([self.db open]) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@'",tableName];
        BOOL res = [self.db executeUpdate:delAllChatSql];
        if (!res) {
//            NSLog(@"error when delete db table");
        } else {
//            NSLog(@"success to delete db table");
        }
        [self.db close];
    }

}


@end
