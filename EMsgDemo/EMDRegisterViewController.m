//
//  EMDRegisterViewController.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/18.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDRegisterViewController.h"
#import "MBProgressHUD+Add.h"
#import "EMsgCilent.h"

@interface EMDRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property (weak, nonatomic) IBOutlet UIButton *sexButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) UIDatePicker * datePicker;
@end

@implementation EMDRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"注册";
    
    self.emailTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.usernameTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordTextField.secureTextEntry = YES;
    [_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];

    
    [self setupBirthDayDatePicker];
    // Do any additional setup after loading the view from its nib.
}

- (void)setupBirthDayDatePicker{
    UIDatePicker * _datePicker1 = [[UIDatePicker alloc] init];
    
    [_datePicker1 setTimeZone:[NSTimeZone defaultTimeZone]];
    
    _datePicker1.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 216);
    
    _datePicker1.datePickerMode = UIDatePickerModeDate;
    
    _datePicker1.maximumDate = [[NSDate alloc] init];
    
    _datePicker1.backgroundColor = [UIColor whiteColor];
    
    self.datePicker = _datePicker1;
    
    [self.datePicker addTarget:self
                        action:@selector(chooseDate:)
              forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
}

- (IBAction)birthdayAction:(id)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT - 216, SCREEN_WIDTH, 216);
    }];
    
}
- (IBAction)changeSexAction:(UIButton *)sender {
    if ([_sexButton.titleLabel.text isEqualToString:@"男"]) {
        [_sexButton setTitle:@"女" forState:UIControlStateNormal];
    }
    else{
        [_sexButton setTitle:@"男" forState:UIControlStateNormal];
    }
}
- (IBAction)registerButton:(id)sender {
    
    if ([self.emailTextField.text isEqualToString:self.usernameTextField.text]) {
        [MBProgressHUD showError:@"邮箱和用户名不能一致" toView:nil];
        return;
    }
    if (self.emailTextField.text.length < 1 || ![ZXCommens validateEmail:self.emailTextField.text]) {
        [MBProgressHUD showError:@"邮箱格式不正确" toView:nil];
        return;
    }
    if (self.usernameTextField.text.length < 1) {
        [MBProgressHUD showError:@"请填写用户名" toView:nil];
        return;
    }
    if (self.passwordTextField.text.length < 1) {
        [MBProgressHUD showError:@"请填写密码" toView:nil];
        return;
    }
    if (self.nickNameTextField.text.length < 1) {
        [MBProgressHUD showError:@"请填写昵称" toView:nil];
        return;
    }
    if (self.birthdayButton.titleLabel.text.length < 1) {
        [MBProgressHUD showError:@"请选择生日" toView:nil];
        return;
    }
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSString * deviceToken = [ZXCommens fetchDeviceToken];
    dic = [ZXCommens factionaryParams:@{@"username":_usernameTextField.text,@"password":_passwordTextField.text,@"email":_emailTextField.text,@"nickname":_nickNameTextField.text,@"gender":_sexButton.titleLabel.text,@"birthday":self.birthdayButton.titleLabel.text} WithServerAndMethod:@{@"service":@"user",@"method":@"register",@"device_token":deviceToken?deviceToken : @""}];
    [self showHudInView:self.view hint:nil];
    ZXRequest * request = [[ZXRequest alloc] initWithRUrl:Host_Server andRMethod:YTKRequestMethodPost andRArgument:dic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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

- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    formatter.dateFormat = @"yyyy-MM-dd";
    [self.birthdayButton setTitle: [formatter stringFromDate:selectedDate] forState:UIControlStateNormal];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.3 animations:^{
        self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 216);
    }];
    [self.view endEditing:YES];
}

- (void)autoLoginMsgCilent {
    ZXUser *userInfoModel = [ZXCommens fetchUser];
    if (userInfoModel.token) {
        //异步登陆账号
        EMsgCilent *client = [EMsgCilent sharedInstance];
        if (![client isAuthed]) {
            NSString *username =
            [NSString stringWithFormat:@"%@@%@/%@", userInfoModel.uid,
             userInfoModel.domain,
             [ZXCommens creatMSTimastmap]];
            
            BOOL successed =
            [client auth:username
            withPassword:userInfoModel.token
                withHost:userInfoModel.host
                withPort:[userInfoModel.port integerValue]];
            
            if (successed) //连接成功
            {
                
            } else { //连接失败
                [client autoReconnect];
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
