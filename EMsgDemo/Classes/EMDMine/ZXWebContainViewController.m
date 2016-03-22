//
//  ZXWebContainViewController.m
//  ChatDemo-UI3.0
//
//  Created by hawk on 16/3/13.
//  Copyright © 2016年 hawk. All rights reserved.
//

#import "ZXWebContainViewController.h"

@interface ZXWebContainViewController ()

@end

@implementation ZXWebContainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.showTitle;
    
    self.view.backgroundColor = BASE_VC_COLOR;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:webView];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:_path ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [webView loadRequest:request];
    // Do any additional setup after loading the view.
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
