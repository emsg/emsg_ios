//
//  ZXNotiViewController.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/21.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "ZXNotiViewController.h"
#import "EMDAddFriendTableViewCell.h"
#import "ZXDetailMessageViewController.h"

@interface ZXNotiViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *listTable;
@property (nonatomic,strong)NSMutableArray * listArray;
@property (nonatomic,strong)UIView * bgview;


@end

@implementation ZXNotiViewController


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self cleanServerNoti];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"通知";
    
    self.listArray = [[NSMutableArray alloc] init];
    
    [self setupVies];
    
    [self creatNoMessageView];
    
    [self fetchUnReadServerMessageCountFromDB];
    // Do any additional setup after loading the view.
    //如果收到消息，刷新临时会话列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchUnReadServerMessageCountFromDB) name:NEW_SERVER_MESSAGE
     object:nil];
    
    [self setUpNav];
}

- (void)setUpNav{
    
    UIButton * sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(0, 0,50,30);
    [sureButton setTitle:@"清空" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [sureButton addTarget:self
                   action:@selector(rightButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btm =[[UIBarButtonItem alloc] initWithCustomView:sureButton];
    self.navigationItem.rightBarButtonItem = btm;
    
}

- (void)creatNoMessageView{
    _bgview = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, self.view.center.y-80, self.view.frame.size.width, 60)];
    _bgview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgview];
    UILabel *deslabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, 0, self.view.frame.size.width, 30)];
    deslabel.textAlignment = NSTextAlignmentCenter;
    deslabel.text = @"通知";
    deslabel.font = [UIFont systemFontOfSize:30];
    deslabel.textColor = [UIColor grayColor];
    [_bgview addSubview:deslabel];
    
    UILabel *deslabelbom = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, 35, self.view.frame.size.width, 20)];
    deslabelbom.textAlignment = NSTextAlignmentCenter;
    deslabelbom.text = @"所有通知信息都会显示在这里。";
    deslabelbom.font = [UIFont systemFontOfSize:16];
    deslabelbom.textColor = [UIColor grayColor];
    [_bgview addSubview:deslabelbom];
    _bgview.hidden = YES;
}

- (void)fetchUnReadServerMessageCountFromDB{
    [[FMDBManger shareInstance] fetchallServerMessage:^(NSArray *serverMessageArray) {
        dispatch_async(dispatch_get_main_queue(), ^{

        _listArray = [NSMutableArray arrayWithArray:serverMessageArray];
        if (_listArray.count == 0) {
            _bgview.hidden = NO;
        }else{
            _bgview.hidden = YES;
        }
        
            [self.listTable reloadData];
        });
    }];
}

- (void)setupVies{
    
    self.listTable = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),
                                               SCREEN_HEIGHT)
                      style:UITableViewStylePlain];
    self.listTable.backgroundColor = BASE_VC_COLOR;
    self.listTable.delegate = self;
    self.listTable.dataSource = self;
    self.listTable.sectionFooterHeight = 0;
    [self.view addSubview:_listTable];
    self.listTable.tableFooterView = [[UIView alloc] init];
}

#pragma mark --
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return _listArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"friendCell";
    EMDAddFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[EMDAddFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                reuseIdentifier:ident];
    }
    EMsgMessage * message = [_listArray objectAtIndex:indexPath.row];
    cell.kMessage = message;
    cell.kAcceptBlock = ^(EMsgMessage * message){
        [self blockAction:message withType:1];
    };
    cell.kRejectBlock = ^(EMsgMessage * message){
        [self blockAction:message withType:2];
    };
    return cell;
}

- (void)blockAction:(EMsgMessage *)message withType:(int)type{
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSString * action = @"reject";
    if (type == 1) {
        action = @"accept";
    }
    else{
        action = @"reject";
    }
    dic = [ZXCommens factionaryParams:@{@"action":action,@"contact_id":message.payload.attrs.contact_id} WithServerAndMethod:@{@"service":@"user",@"method":@"contact"}];
    
    [self showHudInView:self.view hint:@""];
    
    ZXRequest *request = [[ZXRequest alloc] initWithRUrl:Host_Server
                                              andRMethod:YTKRequestMethodPOST
                                            andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self hideHud];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            [[FMDBManger shareInstance] delONeApplyServerMessage:message];
            [self fetchUnReadServerMessageCountFromDB];
        }
        else{
            [self showHint:request.responseJSONObject[@"entity"][@"reason"]];
        }
    } failure:^(YTKBaseRequest *request) {
        [self showHint:@"请求失败"];
    }];
}

- (void)cleanServerNoti{
    [[FMDBManger shareInstance] updateAllServerMessageRead];
    NSNotification *notification = [NSNotification notificationWithName:UPDATE_BADGE object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}

- (void)rightButtonClicked{
    [[FMDBManger shareInstance] delAllNotiMessages];
    [self.listArray removeAllObjects];
    [self.listTable reloadData];
    self.bgview.hidden = NO;
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
