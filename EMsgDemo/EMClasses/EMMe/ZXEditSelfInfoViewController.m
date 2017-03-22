//
//  ZXEditSelfInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by hawk on 16/3/12.
//  Copyright © 2016年 hawk. All rights reserved.
//

#import "ZXEditSelfInfoViewController.h"
#import "MBProgressHUD+Add.h"

@interface ZXEditSelfInfoViewController ()

@property(nonatomic,strong)UITextField * field;
@property (weak, nonatomic) UIDatePicker * datePicker;
@property (nonatomic,copy)NSString * dataString;


@end

@implementation ZXEditSelfInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BASE_VC_COLOR;

    if (self.type == 1 || self.type == 2) {
        [self configField];
    }
    if (self.type == 3) {
        self.navigationItem.title = @"生日";

        [self setupBirthDayDatePicker];
    }
    
    [self setNav];
    // Do any additional setup after loading the view from its nib.
}

- (void)setupBirthDayDatePicker{
    UIDatePicker * _datePicker1 = [[UIDatePicker alloc] init];
    
    [_datePicker1 setTimeZone:[NSTimeZone defaultTimeZone]];
    
    _datePicker1.frame = CGRectMake(0, SCREEN_HEIGHT - 216, SCREEN_WIDTH, 216);
    
    _datePicker1.datePickerMode = UIDatePickerModeDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    ZXUser * user = [ZXCommens fetchUser];
    
    NSDate *destDate= [dateFormatter dateFromString:user.birthday];
    
    [_datePicker1 setDate:destDate];
    
    _datePicker1.maximumDate = [[NSDate alloc] init];
    
    _datePicker1.backgroundColor = [UIColor whiteColor];
    
    [Tools_F setViewlayer:_datePicker1 cornerRadius:0 borderWidth:0.7 borderColor:QYQHEXCOLOR_ALPHA(0xdddddd, 1)];
    
    self.datePicker = _datePicker1;
    
    [self.datePicker addTarget:self
                        action:@selector(chooseDate:)
              forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
}

- (void)configField{
    
    UIView * bg = [[UIView alloc] initWithFrame:CGRectMake(0,44 + 64, SCREEN_WIDTH, 44)];
    bg.backgroundColor = [UIColor whiteColor];
    [Tools_F setViewlayer:bg cornerRadius:0 borderWidth:0.7 borderColor:BASE_CELL_LINE_COLOR];
    [self.view addSubview:bg];
    
    _field = [[UITextField alloc] initWithFrame:CGRectMake(5,0, SCREEN_WIDTH, 44)];
    ZXUser * user = [ZXCommens fetchUser];
    
    if (_type == 1) {
        self.navigationItem.title = @"昵称";
        _field.placeholder = user.nickname;
    }
    if (_type == 2) {
        self.navigationItem.title = @"邮箱";
        _field.placeholder = user.email;
    }
    
    [bg addSubview:_field];
}

- (void)setNav{
    CGRect backframe= CGRectMake(0, 0, 40, 22);
    UIButton* backButton= [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = backframe;
    [backButton setTitle:@"保存" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    //定制自己的风格的 UIBarButtonItem
    UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = someBarButtonItem;
    
}

- (void)confirm{
    
    if (_field.text.length < 1 && self.type != 3) {
        [MBProgressHUD showError:@"输入内容不能为空" toView:nil];
        return;
    }
    
    NSDictionary *dic = [[NSDictionary alloc] init];
    if (_type == 1) {
        dic = [ZXCommens factionaryParams:@{@"nickname":_field.text} WithServerAndMethod:@{@"service":@"user",@"method":@"update_user_info"}];
    }
    if (_type == 2) {
        dic = [ZXCommens factionaryParams:@{@"email":_field.text} WithServerAndMethod:@{@"service":@"user",@"method":@"update_user_info"}];
    }
    if (_type == 3) {
        dic = [ZXCommens factionaryParams:@{@"birthday":self.dataString} WithServerAndMethod:@{@"service":@"user",@"method":@"update_user_info"}];
    }
    
    __weak ZXEditSelfInfoViewController *weakSelf = self;
    [self showHudInView:self.view hint:@"提交中"];
    ZXRequest *request = [[ZXRequest alloc] initWithRUrl:Host_Server
                                              andRMethod:YTKRequestMethodPost
                                            andRArgument:dic];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [weakSelf hideHud];
        if ([request.responseJSONObject[@"success"] integerValue] == 1) {
            ZXUser * user = [ZXCommens fetchUser];
            if (weakSelf.type == 1) {
                user.nickname = weakSelf.field.text;
            }
            if (weakSelf.type == 2) {
                user.email = weakSelf.field.text;
            }
            if (weakSelf.type == 3) {
                user.birthday = weakSelf.dataString;
            }
            [ZXCommens putUserInfo:user];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else{
            [weakSelf showHint:request.responseJSONObject[@"entity"][@"reason"]];
        }
    } failure:^(YTKBaseRequest *request) {
        [weakSelf hideHud];
        [weakSelf showHint:@"请求失败"];
    }];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.dataString =  [formatter stringFromDate:selectedDate];
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
