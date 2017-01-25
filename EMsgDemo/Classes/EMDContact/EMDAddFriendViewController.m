//
//  EMDAddFriendViewController.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/21.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDAddFriendViewController.h"
#import "EMDAddFriendTableViewCell.h"
#import "MBProgressHUD+Add.h"
#import "ZXDetailMessageViewController.h"

@interface EMDAddFriendViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITextField * field;
@property (nonatomic,strong)UITableView *listTable;
@property (nonatomic,strong)NSMutableArray * listArray;
@end

@implementation EMDAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listArray = [[NSMutableArray alloc] init];
    
    self.navigationItem.title = @"添加好友";
    
    [self configField];
    
    [self setupViews];
    
    [self setNav];
    // Do any additional setup after loading the view.
}

- (void)setupViews{
    //表
    self.listTable = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, 148, CGRectGetWidth(self.view.frame),
                                               SCREEN_HEIGHT - 148)
                      style:UITableViewStylePlain];
    self.listTable.backgroundColor = BASE_VC_COLOR;
    self.listTable.delegate = self;
    self.listTable.dataSource = self;
    self.listTable.sectionFooterHeight = 0;
    [self.view addSubview:_listTable];
    self.listTable.tableFooterView = [[UIView alloc] init];
    //    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeText)];
    //    [self.listTable addGestureRecognizer:tap];
}

- (void)configField{
    
    UIView * bg = [[UIView alloc] initWithFrame:CGRectMake(0,84, SCREEN_WIDTH, 44)];
    bg.backgroundColor = [UIColor whiteColor];
    [Tools_F setViewlayer:bg cornerRadius:0 borderWidth:0.7 borderColor:BASE_CELL_LINE_COLOR];
    [self.view addSubview:bg];
    
    _field = [[UITextField alloc] initWithFrame:CGRectMake(5,0, SCREEN_WIDTH, 44)];
    _field.placeholder = @"邮箱/昵称";
    [bg addSubview:_field];
}

- (void)setNav{
    CGRect backframe= CGRectMake(0, 0, 40, 22);
    UIButton* backButton= [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = backframe;
    [backButton setTitle:@"搜索" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    //定制自己的风格的 UIBarButtonItem
    UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = someBarButtonItem;
    
}

- (void)confirm{
    
    if (self.field.text.length < 1) {
        [MBProgressHUD showError:@"查询内容不能为空" toView:nil];
        return;
    }
    
    [self closeText];
    
    NSDictionary *dic = nil;
    dic = [ZXCommens factionaryParams:@{[Tools_F validateEmail:_field.text] ? @"email":@"nickname":_field.text} WithServerAndMethod:@{@"service":@"user",@"method":@"find_user"}];
    
    [self showHudInView:self.view hint:@""];
    
    ZXRequest *request = [[ZXRequest alloc] initWithRUrl:Host_Server
                                              andRMethod:YTKRequestMethodPOST
                                            andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self hideHud];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            _listArray = request.responseJSONObject[@"entity"][@"user_list"];
            [self.listTable reloadData];
        }
        else{
            [self showHint:request.responseJSONObject[@"entity"][@"reason"]];
        }
    } failure:^(YTKBaseRequest *request) {
        [self showHint:@"请求失败"];
    }];
    
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
    NSDictionary * dic = [_listArray objectAtIndex:indexPath.row];
    ZXUser * user = [ZXUser mj_objectWithKeyValues:dic];
    cell.kUser = user;
    return cell;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dic = [_listArray objectAtIndex:indexPath.row];
    ZXUser * user = [ZXUser mj_objectWithKeyValues:dic];
    ZXDetailMessageViewController * zd = [[ZXDetailMessageViewController alloc] init];
    zd.kUser = user;
    [self.navigationController pushViewController:zd animated:YES];
    
}

- (void)closeText{
    [_field resignFirstResponder];
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
