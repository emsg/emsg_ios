//
//  EMDMineViewController.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDMineViewController.h"
#import "UploadFile.h"
#import "MBProgressHUD+Add.h"
#import "ZXSettingSelfInfoController.h"
#import "EMDEngineManger.h"

@interface EMDMineViewController()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,EMDEngineMangerDelegate>
@property (nonatomic,strong)NSArray * titlesArray;
@property (nonatomic,strong)UIImageView * showHeaderImageView;
@property (nonatomic,strong)UITableView *  menuTableView;
@property (nonatomic,strong)UIImagePickerController * imagePicker;
@property (nonatomic,strong)UILabel * nickNameLabel;

@end

@implementation EMDMineViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_menuTableView reloadData];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    _titlesArray = @[@[@"昵称"],@[@"关于我们",@"帮助",@"检查SDK版本更新",@"退出登录"]];
    
    _menuTableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 49)
                      style:UITableViewStyleGrouped];
    _menuTableView.backgroundColor = BASE_VC_COLOR;
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    _menuTableView.sectionHeaderHeight = 10.0;
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_menuTableView];
    
}


#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titlesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [_titlesArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    
    //赋值
    ZXUser * user = [ZXCommens fetchUser];
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (self.showHeaderImageView == nil) {
            self.showHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 60, 60)];
        }
        [cell.contentView addSubview:self.showHeaderImageView];
        self.showHeaderImageView.contentMode = UIViewContentModeScaleAspectFill;
        [Tools_F setViewlayer:self.showHeaderImageView cornerRadius:5 borderWidth:0.5 borderColor:BASE_VC_COLOR];
        [self.showHeaderImageView sd_setImageWithURL:[NSURL URLWithString:user.icon] placeholderImage:[UIImage imageNamed:@"120.png"]];
        if (self.nickNameLabel == nil) {
            self.nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 30, SCREEN_WIDTH - 110, 20)];
        }
        _nickNameLabel.text = user.nickname;
        _nickNameLabel.textColor = QYQHEXCOLOR_ALPHA(0x666666, 1);
        [cell.contentView addSubview:_nickNameLabel];
    }
    else{
        cell.textLabel.text = _titlesArray[indexPath.section][indexPath.row];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        ZXSettingSelfInfoController * setting = [[ZXSettingSelfInfoController alloc] init];
        setting.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setting animated:YES];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
       
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
       
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        //获取app版本号
        NSString *key=@"CFBundleShortVersionString";
        NSString *currentVerionCode=[NSBundle mainBundle].infoDictionary[key];
        [self showHint:[NSString stringWithFormat:@"当前版本号:%@",currentVerionCode]];
    }
    if (indexPath.section == 1 && indexPath.row == 3) {
        [self logoutAction];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 80;
    }
    else{
        return 44;
    }
}


#pragma mark -- methods

- (void)logoutAction
{

    [self showHudInView:self.view hint:@"提交中"];
    NSDictionary * dic = [ZXCommens factionaryParams:@{} WithServerAndMethod:@{@"service":@"user",@"method":@"logout"}];
    ZXWeakSelf;
    ZXRequest *request = [[ZXRequest alloc] initWithRUrl:Host_Server
                                              andRMethod:YTKRequestMethodPost
                                            andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [__weakSelf hideHud];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            [[EMDEngineManger sharedInstance] logout];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE object:@NO];
        }
        else{
            [__weakSelf showHint:request.responseJSONObject[@"entity"][@"reason"]];
        }
    } failure:^(YTKBaseRequest *request) {
        [__weakSelf hideHud];
        [__weakSelf showHint:@"退出失败"];
    }];

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
