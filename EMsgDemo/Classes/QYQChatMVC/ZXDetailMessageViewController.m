//
//  ZXDetailMessageViewController.m
//  ChatDemo-UI3.0
//
//  Created by mac on 16/3/13.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ZXDetailMessageViewController.h"
#import "QYQChatController.h"

@interface ZXDetailMessageViewController ()
/** 头视图 */
@property (nonatomic,strong)UIImageView * headImageView;
@property (nonatomic,strong)UIImageView * sexImageView;
@property (nonatomic,strong)UILabel * headLabel;
/** 详细视图 */
@property (nonatomic,strong)UILabel * firstLabel;
@property (nonatomic,strong)UILabel * secondLabel;
@property (nonatomic,copy)NSArray * array;
@end

@implementation ZXDetailMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BASE_VC_COLOR;

    if(self.isFromSearch){
        [self fetchUserInfo];
    }
    else{
        [self initView];
    }

}


- (void)initView{
    
    self.navigationItem.title = @"详细资料";
    UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 80)];
    [self.view addSubview:headView];
    self.array = @[@"EMsgID",@"性别",@"邮箱",@"生日"];
    NSArray * valueArray = @[_kUser.uid ? _kUser.uid : @"",_kUser.gender ? _kUser.gender : @"",_kUser.email ? _kUser.email : @"",_kUser.birthday ? _kUser.birthday : @""];
    /** 头视图 */
    {
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [headView addSubview:self.headImageView];
        self.headImageView.image = [UIImage imageNamed:@"120"];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:_kUser.icon] placeholderImage:[UIImage imageNamed:@"120"]];
        
        self.sexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 30, 20, 20)];
//        [headView addSubview:self.sexImageView];
        self.sexImageView.image = [UIImage imageNamed:@"120"];
        
        self.headLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 30, SCREEN_WIDTH - 130, 20)];
        [headView addSubview:self.headLabel];
        self.headLabel.text = _kUser.nickname;
        self.headLabel.textColor = QYQHEXCOLOR_ALPHA(0x333333, 1);
        
    }
    for (NSInteger i = 0; i < self.array.count ; i ++) {
        UIView * myView = [self setViewWith:valueArray[i] andIndexNumber:i];
        [self.view addSubview:myView];
    }
    UIButton * myButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:myButton];
    if (!_kUser.is_contact) {
        [myButton setTitle:@"添加好友" forState:UIControlStateNormal];
    }
    if (_kUser.is_contact) {
        [myButton setTitle:@"发消息" forState:UIControlStateNormal];
    }
    if (self.isFromContact == YES) {
        [myButton setTitle:@"发消息" forState:UIControlStateNormal];
    }
    myButton.frame = CGRectMake(20, 320, SCREEN_WIDTH - 40, 40);
    myButton.backgroundColor = QYQHEXCOLOR_ALPHA(0x33db61, 1);
    [myButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [Tools_F setViewlayer:myButton cornerRadius:3 borderWidth:0 borderColor:QYQHEXCOLOR_ALPHA(0x33db61, 1)];
    [myButton addTarget:self action:@selector(confirmBut) forControlEvents:UIControlEventTouchUpInside];
    ZXUser * suer = [ZXCommens fetchUser];
    if ([_kUser.uid integerValue] == [suer.uid integerValue]) {
        [myButton setHidden:YES];
    }
}
-(UIView *)setViewWith:(NSString *)string andIndexNumber:(NSInteger )index
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + 80 + index * 40, SCREEN_WIDTH, 40)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel * firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 60, 20)];
    [view addSubview:firstLabel];
    firstLabel.textColor = QYQHEXCOLOR_ALPHA(0x333333, 1);
    firstLabel.text = self.array[index];
    
    UILabel * secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, SCREEN_WIDTH - 120, 20)];
    [view addSubview:secondLabel];
    secondLabel.textColor = QYQHEXCOLOR_ALPHA(0x999999, 1);
    secondLabel.text = string;
    if (index < 2) {
        UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(10,40, SCREEN_WIDTH - 20, 0.7)];
        line.backgroundColor = QYQHEXCOLOR_ALPHA(0xdddddd, 1);
        [view addSubview:line];
    }
    return view;


}

- (void)fetchUserInfo{
    
    NSDictionary *dic = [ZXCommens factionaryParams:@{@"userid":_kUser.uid} WithServerAndMethod:@{@"service":@"user",@"method":@"get_user_info"}];
    [self showHudInView:self.view hint:@"加载中..."];
    ZXRequest *request = [[ZXRequest alloc] initWithRUrl:Host_Server
                                              andRMethod:YTKRequestMethodPOST
                                            andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self hideHud];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            self.kUser = [ZXUser mj_objectWithKeyValues:request.responseJSONObject[@"entity"][@"user"]];
            [self initView];
        }
        else{
            [self showHint:@"请求失败"];
        }
    } failure:^(YTKBaseRequest *request) {
        [self hideHud];
        [self showHint:@"请求失败"];
    }];
}

-(void)confirmBut
{
    if (self.isFromChatVC == YES) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        if (_kUser.is_contact || self.isFromContact) {
            QYQChatController * chat = [[QYQChatController alloc] init];
            chat.kChatter = _kUser.uid;
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:@{@"toName":_kUser.nickname,@"toPhoto":_kUser.icon ? _kUser.icon : @""}];
            chat.infoDic = dic;
            chat.navigationItem.title = _kUser.nickname;
            [self.navigationController pushViewController:chat animated:YES];
            return;
        }
        if (!_kUser.is_contact) {
            [self sendFriendApply];
        }
    }
}
- (void)sendFriendApply{
    NSDictionary *dic = [ZXCommens factionaryParams:@{@"contact_id":_kUser.uid,@"action":@"add"} WithServerAndMethod:@{@"service":@"user",@"method":@"contact"}];
    [self showHudInView:self.view hint:@""];
    ZXRequest *request = [[ZXRequest alloc] initWithRUrl:Host_Server
                                              andRMethod:YTKRequestMethodPOST
                                            andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self hideHud];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            [self showHint:@"已发送"];
        }
        else{
            [self showHint:request.responseJSONObject[@"entity"][@"reason"]];
        }
    } failure:^(YTKBaseRequest *request){
        [self hideHud];
        [self showHint:@"请求失败"];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
