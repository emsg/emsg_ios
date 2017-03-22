//
//  EMDConversationViewController.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDConversationViewController.h"

#import "QYQChatController.h"
#import "FMDBManger.h"
#import "QYQMessageCell.h"
@interface EMDConversationViewController () <UITableViewDelegate,
UITableViewDataSource>
@property(nonatomic, weak) UILabel *tipsLabel;
@property(nonatomic, strong) UIView *tabBarView;
@property(nonatomic, strong) UITableView *listTable;
@property(nonatomic, strong) NSMutableArray *listArray;

@property (nonatomic,strong)UIView * networkStateView;
@property (nonatomic,strong)UILabel *networkStateLabel;
@property (nonatomic,strong)UIView  * bgview;

@end

@implementation EMDConversationViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //每次进入这个界面都刷新临时会话列表
    [self reloadChatListDataSource];
    
}
- (void)reachabilityChanged:(NSNotification*)note {
    NSDictionary * dic = note.userInfo;
    int state = [dic[@"state"] intValue];
    if (state == 1) {
        [self connectEnd];
    }
    else if(state == 2 || state == 3 || state == 4 ){
        [self connecting];
    }
    else if(state == 5){
        [self connecting];
    }
}

- (void)cutConnecting{
    _networkStateLabel.text = @"无网络连接";
    _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:63 / 255.0 blue:52 / 255.0 alpha:1];
    self.listTable.tableHeaderView = _networkStateView;
}

- (void)connecting{
    _networkStateView.backgroundColor = QYQCOLOR(255,156,52);
    _networkStateLabel.text = @"正在连接";
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(connecting) userInfo:nil repeats:NO];
}

- (void)connectEnd{
    _networkStateView.backgroundColor = QYQCOLOR(78,206,35);
    _networkStateLabel.text = @"已连接";
    [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(connectSuccess) userInfo:nil repeats:NO];
}

- (void)connectSuccess{
    self.listTable.tableHeaderView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"消息";
    //如果收到消息，刷新临时会话列表
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadChatListDataSource)
     name:NEW_MESSAGE
     object:nil];
    [self getDataSource];
    
    
    // Do any additional setup after loading the view.
}

- (void)creatNoMessageView{
    _bgview = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, self.view.center.y-80, self.view.frame.size.width, 60)];
    _bgview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgview];
    UILabel *deslabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, 0, self.view.frame.size.width, 30)];
    deslabel.textAlignment = NSTextAlignmentCenter;
    deslabel.text = @"最近";
    deslabel.font = [UIFont systemFontOfSize:30];
    deslabel.textColor = [UIColor grayColor];
    [_bgview addSubview:deslabel];
    
    UILabel *deslabelbom = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, 35, self.view.frame.size.width, 20)];
    deslabelbom.textAlignment = NSTextAlignmentCenter;
    deslabelbom.text = @"所有聊天信息都会显示在这里。";
    deslabelbom.font = [UIFont systemFontOfSize:16];
    deslabelbom.textColor = [UIColor grayColor];
    [_bgview addSubview:deslabelbom];
    _bgview.hidden = YES;
}


- (void)getDataSource {
    
    [self createUI];
    
}

- (void)reloadChatListDataSource{
    NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    resultArray = [[FMDBManger shareInstance] fetchAllSelReslult];
    if (resultArray && resultArray.count > 0) {
        
        _bgview.hidden = YES;
    }
    else{
        _bgview.hidden = NO;
    }
    _listArray = [NSMutableArray arrayWithArray:resultArray];
    [self.listTable reloadData];
}

- (void)createUI {
    
    UIView * networkStateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 33)];
    UILabel * networkStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 33)];
    networkStateLabel.textAlignment = NSTextAlignmentCenter;
    networkStateLabel.textColor = [UIColor whiteColor];
    _networkStateLabel = networkStateLabel;
    _networkStateView = networkStateView;
    [_networkStateView addSubview:_networkStateLabel];
    self.listTable.tableHeaderView = _networkStateView;
    
    //表
    self.listTable = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),
                                               SCREEN_HEIGHT - 49)
                      style:UITableViewStylePlain];
    self.listTable.delegate = self;
    self.listTable.dataSource = self;
    self.listTable.sectionFooterHeight = 0;
    [self.view addSubview:_listTable];
    self.listTable.tableFooterView = [[UIView alloc] init];
    [self creatNoMessageView];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return _listArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"friendCell";
    QYQMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[QYQMessageCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:ident];
    }
    EMsgMessage * msg = [_listArray objectAtIndex:indexPath.row];
    cell.message = msg;
    return cell;
}
//在对应样式下进行操作
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        EMsgMessage * msg = [_listArray objectAtIndex:indexPath.row];
        NSRange checkStrRange = [msg.envelope.from rangeOfString:@"@"];
        if (checkStrRange.location != NSNotFound) {
            [[FMDBManger shareInstance] deleteOneChatList:msg withChatter:[msg.envelope.from substringToIndex:checkStrRange.location]];
            [[FMDBManger shareInstance] deleteOneChatAllMessageWithChatter:[msg.envelope.from substringToIndex:checkStrRange.location]];
        }
        [_listArray removeObjectAtIndex:indexPath.row];
        if (_listArray.count == 0) {
            _bgview.hidden = NO;
        }
        [self.listTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        //通知刷新tabbar刷新消息
        NSNotification *notification1 =
        [NSNotification notificationWithName:UPDATE_BADGE
                                      object:nil
                                    userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification1];
    }
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMsgMessage * message = [_listArray objectAtIndex:indexPath.row];
    
    ZXUser * user = [ZXCommens fetchUser];
    
    NSRange checkStrRange = [message.envelope.from rangeOfString:@"@"];
    if (checkStrRange.location != NSNotFound) {
        
        //默认为单聊
        BOOL isGroup = NO;
        //判断是否是群聊
        if ([message.envelope.type isEqualToString:@"2"]) {
            isGroup = YES;
        }
        
        QYQChatController *chatVc = [[QYQChatController alloc] init];
        NSString * chatterId = [message.envelope.from substringToIndex:checkStrRange.location];
        if (isGroup == NO) {
            if (!chatterId) {
                return;
            }
        }
        //如果是单聊
        chatVc.kChatter = chatterId;
        //如果是群聊
        if (isGroup == YES) {
            
            NSRange checkStrRange = [message.chatId rangeOfString:user.uid];
            if (checkStrRange.location != NSNotFound) {
                NSString * groupChatterId = [message.chatId substringFromIndex:checkStrRange.length];
                chatVc.kChatter = groupChatterId;
            }
        }
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        
        if(message.payload.attrs.messageFromAge)
        {
            dic[@"toAge"] = message.payload.attrs.messageFromAge;
        }if (message.payload.attrs.messageFromSex) {
            dic[@"toSex"] = message.payload.attrs.messageFromSex;
        }if (message.payload.attrs.messageFromHeaderUrl) {
            dic[@"toPhoto"] = message.payload.attrs.messageFromHeaderUrl;
        }
        
        if (message.payload.attrs.messageFromNickName) {
            dic[@"toName"] = message.payload.attrs.messageFromNickName;
            chatVc.navigationItem.title = message.payload.attrs.messageFromNickName;
        }
        else{
            chatVc.navigationItem.title = @"";
            
        }
        
        if (isGroup == YES) {
            chatVc.navigationItem.title = message.payload.attrs.messageGroupName;
            if (message.payload.attrs.messageGroupUrl) {
                dic[@"groupUrl"] = message.payload.attrs.messageGroupUrl;
            }
            if(message.payload.attrs.messageGroupName){
                dic[@"groupNickName"] = message.payload.attrs.messageGroupName;
            }
        }
        
        
        
        
        chatVc.infoDic = dic;
        //如果是群组
        if ([message.envelope.type isEqualToString:@"2"]) {
            chatVc.isGroup = YES;
        }
        
        chatVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatVc animated:YES];
    }
    
    
}

- (void)removeTableViewDelegate{
    self.listTable.delegate = nil;
    self.listTable.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
