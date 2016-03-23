//
//  EMDLoginViewController.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDLoginViewController.h"
#import "MBProgressHUD+Add.h"
#import "EMDRegisterViewController.h"
#import "EMDEngineManger.h"

@interface EMDLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation EMDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"登录";
    
    self.usernameTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordTextField.secureTextEntry = YES;
    [_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    ZXUser * user = [ZXCommens fetchUser];
    if (user.username) {
        self.usernameTextField.text = user.username;
    }
    [ZXCommens deleteUserInfo];
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)loginAction:(id)sender {
    if (self.usernameTextField.text.length < 1 || self.passwordTextField.text.length < 1) {
        [MBProgressHUD showError:@"用户名或密码错误" toView:nil];
        return;
    }
    NSString * deviceToken = [ZXCommens fetchDeviceToken];
    NSDictionary *dic = [[NSDictionary alloc] init];
    dic = [ZXCommens factionaryParams:@{@"username":_usernameTextField.text,@"password":_passwordTextField.text,@"device_token":deviceToken ? deviceToken : @""} WithServerAndMethod:@{@"service":@"user",@"method":@"login"}];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ZXRequest * request = [[ZXRequest alloc] initWithRUrl:Host_Server andRMethod:YTKRequestMethodPost andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            ZXUser * user = [[ZXUser alloc] init];
            user = [ZXUser mj_objectWithKeyValues:request.responseJSONObject[@"entity"][@"user"]];
            user.domain = request.responseJSONObject[@"entity"][@"emsg_server"][@"domain"];
            user.port = request.responseJSONObject[@"entity"][@"emsg_server"][@"port"];
            user.host = request.responseJSONObject[@"entity"][@"emsg_server"][@"host"];
            user.token = request.responseJSONObject[@"entity"][@"token"];
            [ZXCommens putUserInfo:user];
            [self autoLoginMsgCilent];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE object:@YES];
        }
        else{
            [MBProgressHUD showError:request.responseJSONObject[@"entity"][@"reason"] toView:nil];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"网络好像出了问题" toView:nil];
    }];

}
- (IBAction)registerAction:(id)sender {
    [self.navigationController pushViewController:[[EMDRegisterViewController alloc] init] animated:YES];
}

- (IBAction)findPasswordAction:(id)sender {
}
- (void)autoLoginMsgCilent {
    ZXUser *userInfoModel = [ZXCommens fetchUser];
    if (userInfoModel.token) {
        //异步登陆账号
        EMDEngineManger *engine = [EMDEngineManger sharedInstance];
        if (![engine isAuthed]) {
            NSString *username =
            [NSString stringWithFormat:@"%@@%@/%@", userInfoModel.uid,
             userInfoModel.domain,
             [ZXCommens creatMSTimastmap]];
            
            BOOL successed =
            [engine auth:username
            withPassword:userInfoModel.token
                withHost:userInfoModel.host
                withPort:[userInfoModel.port integerValue]];
            
            if (successed) //连接成功
            {
                
            } else { //连接失败
                [engine autoReconnect];
            }
        }
    }
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
