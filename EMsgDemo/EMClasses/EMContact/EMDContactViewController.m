//
//  EMDContactViewController.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDContactViewController.h"
#import "MySortingVC.h"
#import "QYQMessageCell.h"
#import "ZXDetailMessageViewController.h"
#import "EMDAddFriendViewController.h"
#import "ZXNotiViewController.h"
#import "ZXContactListRequest.h"
#import "ZXNearbyPeopleViewController.h"

@interface EMDContactViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic, strong) UITableView *listTable;
@property (nonatomic,strong)NSArray * indexArray;//索引数组
@property (nonatomic,strong)NSMutableArray * listDatas;
@property (nonatomic,strong)UIView * bgview;
@end

@implementation EMDContactViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self apiRequestContactList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"通讯录";
    
    [self creatNoMessageView];
    
    [self setupViews];
    
    [self createHeaderView];
    
    [self setUpNav];
    
    [self showNoRead];
    
    // Do any additional setup after loading the view.
}


- (void)apiRequestContactList{
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSString * action = @"list";
    dic = [ZXCommens factionaryParams:@{@"action":action} WithServerAndMethod:@{@"service":@"user",@"method":@"contact"}];
    ZXContactListRequest *request = [[ZXContactListRequest alloc] initWithRUrl:Host_Server
                                                                    andRMethod:YTKRequestMethodPost
                                                                  andRArgument:dic];
    if ([request cacheJson]){
        //NSDictionary *json = [request cacheJson];
        NSDictionary *json = [request responseJSONObject];
        if ([json[@"success"] integerValue] == 1) {
            NSArray * jsonArray = json[@"entity"][@"contacts"];
            [_listDatas removeAllObjects];
            NSArray * arr = [MySortingVC sortingChineseWithDicArray:jsonArray andAttributeKey:@"nickname"];
            _listDatas = [NSMutableArray arrayWithArray:arr];
            _indexArray = [MySortingVC returnIndexArrayDataWithGroupArray:_listDatas];
            [self.listTable reloadData];
            if (_listDatas.count < 1) {
                self.bgview.hidden = NO;
            }
            else{
                self.bgview.hidden= YES;
            }
            
        }
        
    }
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            NSArray * jsonArray = request.responseJSONObject[@"entity"][@"contacts"];
            _listDatas = [MySortingVC sortingChineseWithDicArray:jsonArray andAttributeKey:@"nickname"];
            _indexArray = [MySortingVC returnIndexArrayDataWithGroupArray:_listDatas];
            [self.listTable reloadData];
            if (_listDatas.count < 1) {
                self.bgview.hidden = NO;
            }
            else{
                self.bgview.hidden= YES;
            }
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

- (void)creatNoMessageView{
    _bgview = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, self.view.center.y-80, self.view.frame.size.width, 60)];
    _bgview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgview];
    UILabel *deslabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, 0, self.view.frame.size.width, 30)];
    deslabel.textAlignment = NSTextAlignmentCenter;
    deslabel.text = @"通讯录";
    deslabel.font = [UIFont systemFontOfSize:30];
    deslabel.textColor = [UIColor grayColor];
    [_bgview addSubview:deslabel];
    
    UILabel *deslabelbom = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-self.view.frame.size.width/2, 35, self.view.frame.size.width, 20)];
    deslabelbom.textAlignment = NSTextAlignmentCenter;
    deslabelbom.text = @"所有好友都会显示在这里。";
    deslabelbom.font = [UIFont systemFontOfSize:16];
    deslabelbom.textColor = [UIColor grayColor];
    [_bgview addSubview:deslabelbom];
    _bgview.hidden = YES;
}

- (void)setUpNav{
    
    UIButton * sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(0, 0,50,30);
    [sureButton setTitle:@"添加" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [sureButton addTarget:self
                   action:@selector(rightButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btm =[[UIBarButtonItem alloc] initWithCustomView:sureButton];
    self.navigationItem.rightBarButtonItem = btm;
    
}

- (void)setupViews{
    
    self.listTable = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame),
                                               SCREEN_HEIGHT - 64 - 49)
                      style:UITableViewStyleGrouped];
    self.listTable.delegate = self;
    self.listTable.dataSource = self;
    [self.view addSubview:_listTable];
    self.listTable.tableFooterView = [[UIView alloc] init];
    self.listTable.sectionIndexBackgroundColor = [UIColor clearColor];
    self.listTable.sectionIndexColor = QYQHEXCOLOR(0x333333);
    self.listTable.backgroundColor = [UIColor clearColor];
    _listTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    _listDatas = [[NSMutableArray alloc] init];
    _indexArray = [[NSMutableArray alloc] init];
    
}



- (void)createHeaderView{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 115)];
    headerView.backgroundColor = [UIColor colorWithRed:242./255. green:242./255.  blue:242./255.  alpha:1.0];
    
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 60)];
    topView.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView * iconNew = [[UIImageView alloc]initWithFrame:CGRectMake(7.5,
                                                                         7.5,
                                                                         45,
                                                                         45)];
    iconNew.image = [UIImage imageNamed:@"120"];
    [Tools_F setViewlayer:iconNew cornerRadius:3 borderWidth:0 borderColor:[UIColor clearColor]];
    [topView addSubview:iconNew];
    
    UILabel * friendNew = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconNew.frame)+13,
                                                                    22.5,
                                                                    70,
                                                                    15)];
    friendNew.font = [UIFont systemFontOfSize:17];
    friendNew.text = @"通知";
    [topView addSubview:friendNew];
    
    
    UIView * countLabel = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 25,
                                                                   25,
                                                                   10,
                                                                   10)];
    countLabel.backgroundColor = [UIColor redColor];
    countLabel.layer.cornerRadius = 5;
    _noReadServerMessageLabel = countLabel;
    _noReadServerMessageLabel.hidden = YES;
    
    UIImage  *image = [UIImage imageNamed:@"arrow.png"];
    UIImageView * chooseImageView = [[UIImageView alloc]initWithImage:image];
    chooseImageView.frame = CGRectMake(CGRectGetMaxX(countLabel.frame)+5,
                                       25,
                                       5,
                                       10);
    
    [topView addSubview:chooseImageView];
    [topView addSubview:countLabel];
    [headerView addSubview:topView];
    
    topView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(headerViewButtonClicked)];
    [topView addGestureRecognizer:tap];
    
    
    UIView * topView1 = [[UIView alloc]initWithFrame:CGRectMake(0, [topView bottom],SCREEN_WIDTH, 60)];
    topView1.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:topView1];
    [Tools_F setViewlayer:topView1 cornerRadius:0 borderWidth:0.7 borderColor:BASE_CELL_LINE_COLOR];
    
    
    
    UIImageView * iconNew1 = [[UIImageView alloc]initWithFrame:CGRectMake(7.5,
                                                                          7.5,
                                                                          45,
                                                                          45)];
    iconNew1.image = [UIImage imageNamed:@"120"];
    [Tools_F setViewlayer:iconNew1 cornerRadius:3 borderWidth:0 borderColor:[UIColor clearColor]];
    UIImageView * chooseImageView1 = [[UIImageView alloc]initWithImage:image];
    chooseImageView1.frame = CGRectMake(CGRectGetMaxX(countLabel.frame)+ 5,
                                        25,
                                        5,
                                        10);
    [topView1 addSubview:chooseImageView1];
    
    [topView1 addSubview:iconNew1];
    
    
    UILabel * friendNew1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconNew1.frame) + 13,
                                                                     22.5,
                                                                     70,
                                                                     15)];
    friendNew1.font = [UIFont systemFontOfSize:17];
    friendNew1.text = @"附近的人";
    [topView1 addSubview:friendNew1];
    
    [headerView addSubview:topView1];
    
    topView1.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] init];
    [tap1 addTarget:self action:@selector(headerViewButtonClicked1)];
    [topView1 addGestureRecognizer:tap1];
    
    
//    UIView * topView2 = [[UIView alloc]initWithFrame:CGRectMake(0, [topView bottom],SCREEN_WIDTH, 60)];
//    topView2.backgroundColor = [UIColor whiteColor];
//    [headerView addSubview:topView2];
//    [Tools_F setViewlayer:topView2 cornerRadius:0 borderWidth:0.7 borderColor:BASE_CELL_LINE_COLOR];
//    UIImageView * iconNew2 = [[UIImageView alloc]initWithFrame:CGRectMake(7.5,
//                                                                          7.5,
//                                                                          45,
//                                                                          45)];
//    iconNew2.image = [UIImage imageNamed:@"120"];
//    [Tools_F setViewlayer:iconNew2 cornerRadius:3 borderWidth:0 borderColor:[UIColor clearColor]];
//    UIImageView * chooseImageView2 = [[UIImageView alloc]initWithImage:image];
//    chooseImageView2.frame = CGRectMake(CGRectGetMaxX(countLabel.frame)+ 5,
//                                        25,
//                                        5,
//                                        10);
//    [iconNew2 addSubview:chooseImageView2];
//    
//    [topView2 addSubview:iconNew2];
//    
//    
//    UILabel * friendNew2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconNew1.frame) + 13,
//                                                                     22.5,
//                                                                     70,
//                                                                     15)];
//    friendNew2.font = [UIFont systemFontOfSize:17];
//    friendNew2.text = @"附近的人";
//    [topView2 addSubview:friendNew2];
//    
//    [headerView addSubview:topView2];
//    
//    topView2.userInteractionEnabled = YES;
//    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] init];
//    [tap2 addTarget:self action:@selector(headerViewButtonClicked2)];
//    [topView2 addGestureRecognizer:tap2];
    
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, [topView1 bottom] );
    self.listTable.tableHeaderView = headerView;
    
}

#pragma mark -- tableView delegate
//索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    _indexArray = [MySortingVC returnIndexArrayDataWithGroupArray:_listDatas];
    return _indexArray;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _listDatas.count;
}
//组头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
    
}
//组头
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                             0, SCREEN_WIDTH,
                                                             20)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                     0, SCREEN_WIDTH - 20,
                                                                     20)];
    titleLabel.textColor = QYQHEXCOLOR(0x999999);
    
    titleLabel.text = _indexArray[section];
    
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    [view addSubview:titleLabel];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_listDatas[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ident = @"QYQMessageCellfriend";
    QYQMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        
        cell = [[QYQMessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:ident];
    }
    MySortingModel * model = _listDatas[indexPath.section][indexPath.row];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.icon]placeholderImage:[UIImage imageNamed:@"120"]];
    cell.nickNameLabel.text = model.nickname;
    cell.isFriendList = YES;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MySortingModel * model = _listDatas[indexPath.section][indexPath.row];
    ZXDetailMessageViewController * detail = [[ZXDetailMessageViewController alloc]init];
    ZXUser * user = [[ZXUser alloc] init];
    user.uid = [NSString stringWithFormat:@"%lu",[model.uid integerValue]];
    user.nickname = model.nickname;
    user.email = model.email;
    user.icon = model.icon;
    user.birthday = model.birthday;
    user.gender = model.gender;
    detail.kUser = user;
    detail.hidesBottomBarWhenPushed = YES;
    detail.isFromContact = YES;
    [self.navigationController pushViewController:detail animated:YES];
    
    
}
//!在对应样式下进行操作,删除好友
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteFriend:indexPath];
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

#pragma mark -- actions
- (void)headerViewButtonClicked{
    
    ZXNotiViewController * noti = [[ZXNotiViewController alloc] init];
    noti.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:noti animated:YES];
}

- (void)headerViewButtonClicked1{
    ZXNearbyPeopleViewController * nearBy = [[ZXNearbyPeopleViewController alloc] init];
    nearBy.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nearBy animated:YES];
}

- (void)headerViewButtonClicked2{

}

- (void)rightButtonClicked{
    EMDAddFriendViewController * af = [[EMDAddFriendViewController alloc] init];
    af.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:af animated:YES];
}

- (void)showNoRead{
    ZXWeakSelf;
    [[FMDBManger shareInstance] fetchAllNoReadMessage:^(NSInteger noCount) {
    } andChatterCount:^(NSInteger noChatterCount) {
    } andServerCount:^(NSInteger noServerCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (noServerCount > 0) {
                __weakSelf.noReadServerMessageLabel.hidden = NO;
            }
            else{
                __weakSelf.noReadServerMessageLabel.hidden = YES;
            }
        });
    }];
}

- (void)deleteFriend:(NSIndexPath *)indexPath{
    MySortingModel * model = _listDatas[indexPath.section][indexPath.row];
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSString * action = @"delete";
    dic = [ZXCommens factionaryParams:@{@"action":action,@"contact_id":model.uid} WithServerAndMethod:@{@"service":@"user",@"method":@"contact"}];
    
    [self showHudInView:self.view hint:@""];
    
    ZXRequest *request = [[ZXRequest alloc] initWithRUrl:Host_Server
                                              andRMethod:YTKRequestMethodPost
                                            andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self hideHud];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            NSArray * sectionArray = [self.listDatas objectAtIndex:indexPath.section];
            if (sectionArray.count == 1) {
                [self.listDatas removeObjectAtIndex:indexPath.section];
            }
            else{
                NSMutableArray * smSectionArray = [NSMutableArray arrayWithArray:sectionArray];
                [smSectionArray removeObjectAtIndex:indexPath.row];
                [self.listDatas replaceObjectAtIndex:indexPath.section withObject:smSectionArray];
            }
            [self.listTable reloadData];
            if (_listDatas.count == 0) {
                [self.bgview setHidden:NO];
            }else{
                [self.bgview setHidden:YES];
            }
            [self sectionIndexTitlesForTableView:self.listTable];
            [[FMDBManger shareInstance] delOneChatIdAllMessage:model.uid];
            [[FMDBManger shareInstance] deleteOneChatAllMessageWithChatter:model.uid];
            //通知chatlist
            NSNotification *notification =
            [NSNotification notificationWithName:NEW_MESSAGE
                                          object:nil
                                        userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //通知刷新tabbar刷新消息
            NSNotification *notification1 =
            [NSNotification notificationWithName:UPDATE_BADGE
                                          object:nil
                                        userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification1];
        }
        else{
            [self showHint:request.responseJSONObject[@"entity"][@"reason"]];
        }
    } failure:^(YTKBaseRequest *request) {
        [self showHint:@"请求失败"];
    }];
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
