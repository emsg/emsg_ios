//
//  QYQBaseUIViewController.m
//  qiuyouquan
//
//  Created by QYQ-Hawk on 15/11/19.
//  Copyright © 2015年 QYQ-Hawk. All rights reserved.
//

#import "QYQBaseUIViewController.h"


@implementation QYQBaseUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BASE_VC_COLOR;
    
    
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
