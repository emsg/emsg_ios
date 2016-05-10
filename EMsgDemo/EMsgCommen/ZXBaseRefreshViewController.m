//
//  ZXBaseRefreshViewController.m
//  EMsgDemo
//
//  Created by Hawk on 5/9/16.
//  Copyright © 2016 鹰. All rights reserved.
//

#import "ZXBaseRefreshViewController.h"

@interface ZXBaseRefreshViewController ()

@end

@implementation ZXBaseRefreshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateUI];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self endRefreshAnimation];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}


- (void)updateUI {
    
    [self.view addSubview:self.tableView];
    
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    NSArray * idleImages = @[[UIImage imageNamed:@"ah_7"]];
    
    NSArray * pullingImages = @[[UIImage imageNamed:@"ah_0"]];
    
    NSArray * refreshingImages = @[[UIImage imageNamed:@"ah_0"],[UIImage imageNamed:@"ah_1"],[UIImage imageNamed:@"ah_2"],[UIImage imageNamed:@"ah_3"],[UIImage imageNamed:@"ah_4"],[UIImage imageNamed:@"ah_5"],[UIImage imageNamed:@"ah_6"],[UIImage imageNamed:@"ah_7"]];
    
    [((MJRefreshGifHeader *)self.tableView.mj_header) setImages:idleImages forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [((MJRefreshGifHeader *)self.tableView.mj_header) setImages:pullingImages forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [((MJRefreshGifHeader *)self.tableView.mj_header) setImages:refreshingImages forState:MJRefreshStateRefreshing];
    //hide time
    ((MJRefreshStateHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    
}

- (void)beginRefresh{
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadData {
    
}

- (void)loadMoreData {
    
}

- (void)endRefreshAnimation {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (void)endNoMoreDataRefresh{
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)dealloc {
    
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
