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

//初始化FMDatabaseQueue
-(id)init
{
    self = [super init];
    if(self){
        //NSString *dbFilePath = [PathResolver databaseFilePath];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documents = [paths objectAtIndex:0];
        NSString *dbFilePath = [documents stringByAppendingPathComponent:DBNAME];
        _queue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
        
        [self createChatHistoryTable];
        [self createChatListTable];
    }
    return self;
}

/*+ (instancetype)shareInstance {
    
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        _sharedFMDBManger = [[FMDBManger alloc] init];
        return _sharedFMDBManger;
    }
    _sharedFMDBManger = [[FMDBManger alloc] init];
    [_sharedFMDBManger createChatHistoryTable];
    [_sharedFMDBManger createChatListTable];
    
    return _sharedFMDBManger;
}*/

//获得Instance（创建 FMDatabaseQueue 单例）
+(FMDBManger *) shareInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

/*
-(void) inDatabase:(void(^)(FMDatabase*))block
{
    [_queue inDatabase:^(FMDatabase *db){
        block(db);
    }];
}*/


+(void) refreshDatabaseFile
{
    FMDBManger *instance = [self shareInstance];
    [instance doRefresh];
}

-(void) doRefresh
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *dbFilePath = [documents stringByAppendingPathComponent:DBNAME];
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
}

#pragma mark--
#pragma 聊天记录的数据库操作API

- (void)createChatHistoryTable {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
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
    [self.db close];*/
    //NSLog(@"%@", self.database_path);
    //self.queue=[FMDatabaseQueue databaseQueueWithPath:self.database_path];
    //取出数据库，这里的db就是数据库，在数据库中创建表
    [self.queue inDatabase:^(FMDatabase *db) {
        //创建表
        NSString *tableName = [NSString
                               stringWithFormat:@"%@%@", userModel.uid, CHAT_HISTORY];
        NSString *sqlCreateTable = [NSString
                                    stringWithFormat:
                                    @"CREATE TABLE IF NOT EXISTS '%@' ('%@' VARCHAR(36) PRIMARY "
                                    @"KEY , '%@' TEXT,'%@' TEXT,'%@' TEXT,'%@' TEXT ,'%@' TEXT)",
                                    tableName, ID, CHAT_ID, CHAT_LAST_MESSAGE, CHAT_TIMESTMAP,CHAT_IS_READ,CHAT_IS_CLICKED];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            //            NSLog(@"error when creating db table 1");
        } else {
            //            NSLog(@"success to creating db table");
        }
    }];
}

- (BOOL)insertOneMessage:(EMsgMessage *)message
             withChatter:(NSString *)chatter {
    
    message.storeId = [ZXCommens creatMSTimastmap];
    __block BOOL request = NO;
    
    //添加消息主键,服务器发送过来的消息自带uid,自己发送的不带,给其构造一个
    if (!message.envelope.uid) {
        message.envelope.uid = [ZXCommens creatUUID];
    }
    
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return request;
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
    /*[self.db open];
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
    }*/
    
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *insertSql = [NSString
                               stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@') ",
                               tableName,ID, CHAT_ID, CHAT_LAST_MESSAGE, CHAT_TIMESTMAP,CHAT_IS_READ,message.envelope.uid ,chatId,
                               myString, message.storeId ,message.isReaded];
        BOOL res = [db2 executeUpdate:insertSql];
        
        if (!res) {
            //            NSLog(@"error when insert db table 2");
            //return NO;
        } else {
            //            NSLog(@"success to insert db table");
            //return YES;
            request = YES;
        }
    }];
    return request;
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
    
    /*[self.db open];
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
    [self.db close];*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *updateSql = [NSString
                               stringWithFormat:
                               @"UPDATE '%@' SET message = '%@' WHERE chat_id = '%@' AND timestmap = '%@'",
                               tableName,myString,chatId,message.storeId];
        BOOL res = [db2 executeUpdate:updateSql];
        if (!res) {
            //            NSLog(@"error to update data: %@", @"error");
        } else {
            //            NSLog(@"succ to update data: %@", @"success");
        }
    }];
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
    
    /*[self.db open];
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
    }*/
    
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delSql = [NSString
                            stringWithFormat:@"DELETE FROM '%@' WHERE chat_id='%@' AND timestmap ='%@' ",
                            tableName, chatId,
                            message.storeId];
        BOOL res = [db2 executeUpdate:delSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table 3");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
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
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id ='%@'",
         tableName, chatId];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table 4");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
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
    
    /*[self.db open];
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
     }*/
    __block NSMutableArray * sortArray = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *sql = [NSString
                         stringWithFormat:
                         //                             @"SELECT * FROM '%@' where chat_id ='%@'",
                         //                             tableName,chatId];
                         
                         @"SELECT * FROM '%@' WHERE chat_id ='%@' AND timestmap >= '%@' order by timestmap DESC",
                         tableName, chatId,index];
        FMResultSet *rs = [db2 executeQuery:sql];
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
        for (NSInteger i = arr.count - 1; i >= 0; i--) {
            [sortArray addObject:[arr objectAtIndex:i]];
        }
    }];
    return sortArray;
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
    /*[self.db open];
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
    }*/
    __block NSMutableArray * sortArray = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *sql = [NSString
                         stringWithFormat:
                         //                             @"SELECT * FROM '%@' where chat_id ='%@'",
                         //                             tableName,chatId];
                         
                         @"SELECT * FROM '%@' WHERE chat_id ='%@' and timestmap < '%@' order by timestmap DESC Limit '%d' ",
                         tableName, chatId,tm,limite];
        FMResultSet *rs = [db2 executeQuery:sql];
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
    }];
    return sortArray;
    
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
    //self.database_path = [documents stringByAppendingPathComponent:DBNAME];
    /*self.db = [FMDatabase databaseWithPath:self.database_path];
    
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
    [self.db close];*/
    //self.queue=[FMDatabaseQueue databaseQueueWithPath:self.database_path];
    //取出数据库，这里的db就是数据库，在数据库中创建表
    [self.queue inDatabase:^(FMDatabase *db) {
        //创建表
        NSString *tableName = [NSString
                               stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
        NSString *sqlCreateTable =
                            [NSString stringWithFormat:
                             @"CREATE TABLE IF NOT EXISTS '%@' ('%@' VARCHAR(36) PRIMARY "
                             @"KEY, '%@' TEXT,'%@' TEXT,'%@' TEXT , '%@' TEXT)",
                             tableName, ID, CHAT_ID, CHAT_LIST_LAST_MESSAGE,CHAT_LIST_TYPE,CHAT_LIST_TIMESTMAP];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating db table 1");
        } else {
            //            NSLog(@"success to creating db table");
        }
    }];
}

- (BOOL)insertOneChatList:(EMsgMessage *)message
              withChatter:(NSString *)chatter {
    
    __block BOOL request = NO;
    message.storeId = [ZXCommens creatMSTimastmap];
    //添加消息主键,服务器发送过来的消息自带uid,自己发送的不带,给其构造一个
    if (!message.envelope.uid) {
        message.envelope.uid = [ZXCommens creatUUID];
    }
    
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return request;
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
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *insertSql = [NSString
                               stringWithFormat:@"INSERT INTO '%@' ('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@') ",
                               tableName,ID, CHAT_LIST_ID, CHAT_LIST_LAST_MESSAGE,CHAT_LIST_TYPE,CHAT_LIST_TIMESTMAP,message.envelope.uid,chatId,
                               myString,message.envelope.type,message.storeId];
        BOOL res = [db2 executeUpdate:insertSql];
        if (!res) {
            
        } else {
            //            NSLog(@"succ to inster data: %@", @"success");
            request = YES;
        }
    }];
    return request;
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
    
    /*[self.db open];
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
    [self.db close];*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *insertSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id ='%@' AND (chat_list_type = '1' or chat_list_type = '2')",
         tableName, chatId];
        BOOL res = [db2 executeUpdate:insertSql];
        if (!res) {
            //            NSLog(@"error to del data: %@", @"error");
        } else {
            //            NSLog(@"succ to del data: %@", @"success");
        }
    }];
    
}

- (void)fetchallServerMessage:(void (^)(NSArray *))block {
    
    ZXUser *userModel = [ZXCommens fetchUser];
    
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    /*FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.database_path];
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
    });*/
    [self.queue inDatabase:^(FMDatabase *db2) {
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
}

- (NSMutableArray *)fetchAllSelReslult {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return [[NSMutableArray alloc] init];
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    /*[self.db open];
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
    [self.db close];*/
    [self.queue inDatabase:^(FMDatabase *db)   {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' where chat_list_type = '1' or chat_list_type = '2' order by timestmap DESC", tableName];
        FMResultSet *rs = [db executeQuery:sql];
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
    }];
    return arr;
}

- (NSInteger)fetchAllUnreadMessageCount {
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return 0;
    }
    
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    __block NSInteger arr = 0;
    
    /*[self.db open];
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
    [self.db close];*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *sql =
        [NSString stringWithFormat:@"SELECT * FROM '%@' ", tableName];
        FMResultSet *rs = [db2 executeQuery:sql];
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
    }];
    return arr;
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
    
    /*[self.db open];
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
    [self.db close];*/
    [self.queue inDatabase:^(FMDatabase *db)   {
        NSString *updateSql = [NSString
                               stringWithFormat:
                               @"UPDATE '%@' SET last_message = '%@' WHERE chat_id = '%@' AND (chat_list_type = '1' or chat_list_type = '2')",
                               tableName,myString,chatId];
        BOOL res = [db executeUpdate:updateSql];
        if (!res) {
            //            NSLog(@"error to update data: %@", @"error");
        } else {
            //            NSLog(@"succ to update data: %@", @"success");
        }
    }];
}

- (void)updateAllServerMessageRead{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return ;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    /*[self.db open];
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
    [self.db close];*/
    
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *sql =
        [NSString stringWithFormat:@"SELECT * FROM '%@' where chat_list_type = '100' or chat_list_type = '101' or chat_list_type = '102' or chat_list_type = '103' or chat_list_type = '109' or chat_list_type = '108' or chat_list_type = '111' or chat_list_type = '110' ", tableName];
        FMResultSet *rs = [db2 executeQuery:sql];
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
            BOOL res = [db2 executeUpdate:updateSql];
            if (!res) {
                //                NSLog(@"error to update data: %@", @"error");
            } else {
                //                NSLog(@"succ to update data: %@", @"success");
            }
        }
    }];
}

- (void)delOneServerMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE timestmap ='%@'",
         tableName, message.storeId];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
}

- (void)delONeApplyServerMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '100'",
         tableName, chatId];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
}

- (void)delONeApplyTeamApplicationMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '109'",
         tableName, chatId];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
}

- (void)delONeApplyGroupApplicationMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '108'",
         tableName, chatId];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
}
- (void)delONeInviteGroupApplicationMessage:(EMsgMessage *)message{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,[ZXCommens subQiuYouNo:message.envelope.from]];
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id = '%@' and chat_list_type = '110'",
         tableName, chatId];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
}

- (void)delOneChatIdAllMessage:(NSString *)chatter{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    NSString * chatId = [NSString stringWithFormat:@"%@%@",userModel.uid,chatter];
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@' WHERE chat_id ='%@' ",
         tableName, chatId];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
}

- (void)delAllChatListMessage{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@'",
         tableName];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];
}

- (void)fetchAllNoReadMessage:(void (^)(NSInteger))noCC andChatterCount:(void (^)(NSInteger))noCCC andServerCount:(void (^)(NSInteger))noSCC{
    ZXUser *userModel = [ZXCommens fetchUser];
    
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    
    /*FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.database_path];
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
    });*/
    [self.queue inDatabase:^(FMDatabase *db2) {
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
    
    /*FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.database_path];
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
    });*/
    [self.queue inDatabase:^(FMDatabase *db2) {
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
}

- (void)delAllNotiMessages{
    ZXUser *userModel = [ZXCommens fetchUser];
    if (!userModel.token) {
        return;
    }
    NSString *tableName = [NSString
                           stringWithFormat:@"%@%@", userModel.uid, CHAT_LIST_HISTORY];
    /*[self.db open];
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
    }*/
    [self.queue inDatabase:^(FMDatabase *db2) {
        NSString *delAllChatSql =
        [NSString stringWithFormat:@"DELETE FROM '%@'",tableName];
        BOOL res = [db2 executeUpdate:delAllChatSql];
        if (!res) {
            //            NSLog(@"error when delete db table");
        } else {
            //            NSLog(@"success to delete db table");
        }
    }];

}


@end
