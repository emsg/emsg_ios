//
//  ZXSettingSelfInfoController.m
//  ChatDemo-UI3.0
//
//  Created by hawk on 16/3/12.
//  Copyright © 2016年 hawk. All rights reserved.
//

#import "ZXSettingSelfInfoController.h"
#import "ZXBaseTableViewCell.h"
#import "ZXEditSelfInfoViewController.h"
#import "ZXSelectSexViewController.h"
#import "UploadFile.h"
#import "LCActionSheet.h"

@interface ZXSettingSelfInfoController()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}
@property (nonatomic,strong)NSArray * titlesArray;
@property (nonatomic,strong)NSArray * imagesArray;
@property (nonatomic,strong)UIImageView * showHeaderImageView;
@property (nonatomic,strong)UIImagePickerController * imagePicker;
@property (nonatomic,strong)UITableView *  menuTableView;

@end

@implementation ZXSettingSelfInfoController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_menuTableView reloadData];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.title = @"个人信息";
    
    self.view.backgroundColor = BASE_VC_COLOR;
    
    _titlesArray = @[@[@"头像",@"EMsg号",@"昵称",@"性别",@"生日"],@[@"邮箱"]];
    //    _imagesArray = @[@[@"tabbar_setting"],@[@"tabbar_setting",@"tabbar_setting"],@[@"关于我们",@"帮助",@"检查版本更新",@"退出登录"]];
    
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
    ZXBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[ZXBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    cell.textLabel.text = _titlesArray[indexPath.section][indexPath.row];
    
    //赋值
    ZXUser * user = [ZXCommens fetchUser];
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
            if (self.showHeaderImageView == nil) {
                self.showHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 10, 60, 60)];
            }
            self.showHeaderImageView.contentMode = UIViewContentModeScaleAspectFill;
            [cell.contentView addSubview:self.showHeaderImageView];
            [Tools_F setViewlayer:self.showHeaderImageView cornerRadius:5 borderWidth:0 borderColor:[UIColor clearColor]];
            [self.showHeaderImageView sd_setImageWithURL:[NSURL URLWithString:user.icon] placeholderImage:[UIImage imageNamed:@"120.png"]];
            
        }
        else if (indexPath.row == 1){
            cell.detailTextLabel.text = user.uid;
        }
        else if(indexPath.row == 2){
            cell.detailTextLabel.text = user.nickname;
        }
        else if(indexPath.row == 3){
            cell.detailTextLabel.text = user.gender;
        }
        else if(indexPath.row == 4){
            cell.detailTextLabel.text = user.birthday;
        }
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = user.email;
        }
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZXEditSelfInfoViewController * zs = [[ZXEditSelfInfoViewController alloc] init];
    if (indexPath.section == 0 && indexPath.row == 0) {
        /*LCActionSheet * sheet = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:[[NSArray alloc] initWithObjects:@"拍照",@"从手机相册中选择",nil] redButtonIndex:-1 clicked:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self pickImageFromCamera];
            }
            if (buttonIndex == 1) {
                [self pickImageFromAlbum];
            }
        }];*/
        LCActionSheet *sheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:nil clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            
            NSLog(@"clickedButtonAtIndex: %d", (int)buttonIndex);
            if (buttonIndex == 0) {
                [self pickImageFromCamera];
            }
            if (buttonIndex == 1) {
                [self pickImageFromAlbum];
            }
        } otherButtonTitles:@"拍照",@"从手机相册中选择", nil];
        [sheet show];
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        zs.type = 1;
        [self.navigationController pushViewController:zs animated:YES];
        return;
    }
    if(indexPath.section == 0 && indexPath.row == 3)
    {
        ZXSelectSexViewController * zsv = [[ZXSelectSexViewController alloc] init];
        [self.navigationController pushViewController:zsv animated:YES];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        zs.type = 2;
        [self.navigationController pushViewController:zs animated:YES];
        return;
    }
    if (indexPath.section == 0 && indexPath.row == 4 ) {
        zs.type = 3;
        [self.navigationController pushViewController:zs animated:YES];
        return;

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

#pragma mark -- photo
#pragma mark 从摄像机选择图片
- (void)pickImageFromCamera {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.allowsEditing = YES;
    [self.imagePicker setShowsCameraControls:YES];
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}
#pragma mark 从相册选择图片
- (void)pickImageFromAlbum {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}
#pragma mark 从相册选择图片并处理图片
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __weak ZXSettingSelfInfoController *weakSelf = self;
    [self.navigationController dismissViewControllerAnimated:
     YES completion:^{
         UIImage *image1 = [info objectForKey:UIImagePickerControllerEditedImage];
         [self showHudInView:self.view hint:@"上传中..."];
         [[UploadFile sharedUploadFile] uploadImage:image1 resultBlock:^(NSDictionary * dic) {
             if ([dic[@"success"] intValue] == 1) {
                 NSString * headerUrl = [NSString stringWithFormat:@"%@%@",Server_File_Host,dic[@"entity"][@"id"]];
                 NSDictionary *dic = [[NSDictionary alloc] init];
                 dic = [ZXCommens factionaryParams:@{@"icon_url":headerUrl} WithServerAndMethod:@{@"service":@"user",@"method":@"set_icon"}];
                 ZXRequest * request = [[ZXRequest alloc] initWithRUrl:Host_Server andRMethod:YTKRequestMethodPost andRArgument:dic];
                 [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                     [weakSelf hideHud];
                     if ([request.responseJSONObject[@"success"] integerValue] == 1) {
                         ZXUser * user = [ZXCommens fetchUser];
                         user.icon = headerUrl;
                         [ZXCommens putUserInfo:user];
                         [weakSelf.menuTableView reloadData];
                     }
                     else{
                         if ([request.responseJSONObject[@"entity"][@"code"] integerValue] == 2000) {
                             [weakSelf showHint:dic[@"entity"][@"reason"]];
                             [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE object:@NO];
                         }
                     }
                 } failure:^(YTKBaseRequest *request) {
                     [weakSelf hideHud];
                     [weakSelf showHint:@"上传失败"];
                 }];
             }
             else{
                 [weakSelf hideHud];
                 [weakSelf showHint:dic[@"entity"][@"reason"]];
             }
         } upProgress:^(float f) {
         }];
     }];
}


@end
