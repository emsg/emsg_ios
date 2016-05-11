//
//  ZXNearbyPeopleViewController.m
//  EMsgDemo
//
//  Created by Hawk on 5/9/16.
//  Copyright © 2016 鹰. All rights reserved.
//

#import "ZXNearbyPeopleViewController.h"
#import "ZXNearByTableViewCell.h"
#import "ZXDetailMessageViewController.h"
#import "MBProgressHUD+Add.h"
#import "LCActionSheet.h"
#import "HawkLocation.h"
#import "NSDate+Category.h"

@interface ZXNearbyPeopleViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property  (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, strong) HawkLocation *locationManager;

@property int pageNo;

@property int pageSize;

@property (nonatomic,strong)NSString * sex;

@end

@implementation ZXNearbyPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self beginRefresh];
    
    self.navigationItem.title = @"附近的人";
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    self.pageNo = 0;
    
    self.pageSize = 20;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self createNav];
    
    // Do any additional setup after loading the view.
}

- (void)createNav{
    UIButton *rightBtn = [[UIButton alloc]
                          initWithFrame:CGRectMake(0,0,40,20)];
    [rightBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self
                 action:@selector(rightNavClick)
       forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBuutonItem =
    [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarBuutonItem;
}

#pragma mark - private 

- (void)fetchUserLocation{
    if (!_locationManager) {
        _locationManager = [[HawkLocation alloc] init];
        _locationManager.needLocateCity = YES;
    }
    
    [_locationManager startLocatingWithResult:^(NSInteger status, NSError *error) {
        [self updateLocationForStatus:status isMustSelectCity:YES];
    }];
}

//定位结束结果
- (void)updateLocationForStatus:(HLLocalLocationStatus)status isMustSelectCity:(BOOL)isMust
{
    switch (status) {
        case HLLocalLocationStatusNone:
            break;
        case HLLocalLocationStatusDisabled:
        {
            [self.tableView.mj_header endRefreshing];
            //用户未打开定位
            [self showMessageLetUserOpenLocal];
        }
            break;
        case HLLocalLocationStatusOngoing:
            break;
        case HLLocalLocationStatusSuccess:
        {
            
            self.pageNo = 0;
            
            [self requestNearbyPeople];
        }
            break;
        case HLLocalLocationStatusFailure:
        {
            [self.tableView.mj_header endRefreshing];
            [MBProgressHUD showError:@"定位失败了,请重试" toView:self.view];
        }
            break;
        default:
            break;
    }
}

- (void)showMessageLetUserOpenLocal{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        UIAlertView *alIos8 = [[UIAlertView alloc] initWithTitle:nil message:@"打开“定位服务”来允许“球友圈访问您的位置信息”" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启定位", nil];
        [alIos8 show];
        alIos8.tag = 1299;
    }
    else
    {
        UIAlertView *alIos7 = [[UIAlertView alloc] initWithTitle:nil message:@"请在iPhone的“设置-隐私-定位服务”选项中，设置EMSG访问位置信息”" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        alIos7.tag = 1399;
        [alIos7 show];
    }
}


- (void)loadData {
    
    [self fetchUserLocation];
    
}

- (void)loadMoreData {
    self.pageNo += self.pageSize;
    
    [self requestNearbyPeople];
    
}

- (void)requestNearbyPeople{
    
    __weak typeof(self) weakSelf = self;

    NSDictionary *dic = nil;
    
    if (self.sex) {
       dic = [ZXCommens factionaryParams:@{@"geo":[NSString stringWithFormat:@"%@,%@",_locationManager.latitude,_locationManager.longitude],@"page_size":[NSString stringWithFormat:@"%d",self.pageSize],@"page_no":[NSString stringWithFormat:@"%d",self.pageNo / self.pageSize],@"gender":self.sex} WithServerAndMethod:@{@"service":@"user",@"method":@"find_user_by_geo"}];
    }
    else{
        dic = [ZXCommens factionaryParams:@{@"geo":[NSString stringWithFormat:@"%@,%@",_locationManager.latitude,_locationManager.longitude],@"page_size":[NSString stringWithFormat:@"%d",self.pageSize],@"page_no":[NSString stringWithFormat:@"%d",self.pageNo / self.pageSize]} WithServerAndMethod:@{@"service":@"user",@"method":@"find_user_by_geo"}];
    }
    
    ZXRequest * request = [[ZXRequest alloc] initWithRUrl:Host_Server andRMethod:YTKRequestMethodPost andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [weakSelf endRefreshAnimation];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            NSArray * arr = request.responseJSONObject[@"entity"][@"user_list"];
            if (weakSelf.pageNo == 0) {
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:arr];
            }
            else{
                [weakSelf.dataArray addObjectsFromArray:arr];
            }
            [weakSelf.tableView reloadData];
            if ([request.responseJSONObject[@"entity"][@"page_size"] intValue] != [request.responseJSONObject[@"entity"][@"total_count"] intValue]) {
                [weakSelf endNoMoreDataRefresh];
            }
        }
        else{
            
        }
    } failure:^(YTKBaseRequest *request) {
        [weakSelf endRefreshAnimation];
    }];
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1299){
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ident = @"QYQMessageCellfriend";
    ZXNearByTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        
        cell = [[ZXNearByTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:ident];
    }
    NSDictionary * dic = [self.dataArray objectAtIndex:indexPath.row];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[ZXCommens isNilString:dic[@"icon"]] ? nil:dic[@"icon"]]placeholderImage:[UIImage imageNamed:@"120"]];
    cell.nickNameLabel.text = [ZXCommens isNilString:dic[@"nickname"]] ? @"未知人" : dic[@"nickname"];
    cell.gender = [ZXCommens isNilString:dic[@"gender"]] ? @"男" :  dic[@"gender"];
    cell.distLabel.text = [self transformDist:dic];
    cell.timeLabel.text = [self transformTime:dic];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dic = [self.dataArray objectAtIndex:indexPath.row];
    if ([ZXCommens isNilString:dic[@"id"]]) {
        [MBProgressHUD showError:@"用户信息不存在" toView:nil];
        return;
    }
    
    ZXDetailMessageViewController * detailMessage = [[ZXDetailMessageViewController alloc] init];
    ZXUser * user = [[ZXUser alloc] init];
    user.uid = dic[@"id"];
    detailMessage. kUser = user;
    detailMessage.isFromSearch = YES;
    [self.navigationController pushViewController:detailMessage animated:YES];
    
}

- (NSString *)transformTime:(NSDictionary *)dic{
    
    if (!dic[@"ts"] || [dic[@"ts"] isKindOfClass:[NSNull class]]) {
        return @"时间未知";
    }
    NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:[dic[@"ts"] longValue]];
    return [currentTime timeIntervalDescription];
}


- (NSString *)transformDist:(NSDictionary *)dic{
    
    if (!dic[@"dist"]) {
        return @"距离未知";
    }
    
    CGFloat dist = [dic[@"dist"] floatValue];
    
    return [NSString stringWithFormat:@"%.2fKm",dist];
}

- (void)rightNavClick{
    
    __weak typeof(self) weakSelf = self;
    
    LCActionSheet * sheet = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:[[NSArray alloc] initWithObjects:@"只看女生",@"只看男生",@"查看全部",@"清除地理位置并退出",nil] redButtonIndex:-1 clicked:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            self.sex = @"女";
            [self.tableView.mj_header beginRefreshing];
        }
        if (buttonIndex == 1) {
            self.sex = @"男";
            [self.tableView.mj_header beginRefreshing];

        }
        if (buttonIndex == 2) {
            
            self.sex = nil;
            [self.tableView.mj_header beginRefreshing];

        }
        if (buttonIndex == 3) {
            
            [weakSelf.navigationController popViewControllerAnimated:YES];

        }
        
    }];
    [sheet show];
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
