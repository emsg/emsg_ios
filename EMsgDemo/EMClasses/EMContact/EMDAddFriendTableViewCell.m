//
//  EMDAddFriendTableViewCell.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/21.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMDAddFriendTableViewCell.h"

@implementation EMDAddFriendTableViewCell

//初始化方法(通过代码)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView * iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,45,45)];
        _iconImageView = iconImageView;
        [self.contentView addSubview:iconImageView];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImageView.clipsToBounds = YES; // 裁剪边缘
        [self.iconImageView.layer setCornerRadius:3];//圆角幅度
        
        UILabel * nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+ 13,
                                                                            10,
                                                                            SCREEN_WIDTH,
                                                                            20)];
        _nickNameLabel = nickNameLabel;
        nickNameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:nickNameLabel];
        
        //个人详情
        UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+13,
                                                                          CGRectGetMaxY(nickNameLabel.frame),
                                                                          140, 20)];
        detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel = detailLabel;
        detailLabel.textColor =QYQHEXCOLOR(0x999999);
        [self.contentView addSubview:detailLabel];
        
        UIButton * accept = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 15, 50, 30)];
        accept.backgroundColor = BASE_GREEN_COLOR;
        [accept setTitle:@"接受" forState:UIControlStateNormal];
        [accept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:accept];
        accept.titleLabel.font = [UIFont systemFontOfSize:15];
        [Tools_F setViewlayer:accept cornerRadius:3 borderWidth:0 borderColor:[UIColor clearColor]];
        self.acceptButton = accept;
        [self.acceptButton addTarget:self action:@selector(acceptAction) forControlEvents:UIControlEventTouchUpInside];

        
        UIButton * reject = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 15, 50, 30)];
        reject.backgroundColor = BASE_GREEN_COLOR;
        [reject setTitle:@"拒绝" forState:UIControlStateNormal];
        reject.titleLabel.font = [UIFont systemFontOfSize:15];
        [reject setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:reject];
        [Tools_F setViewlayer:reject cornerRadius:3 borderWidth:0 borderColor:[UIColor clearColor]];
        self.rejectButton = reject;
        [self.rejectButton addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];

    }
    
    return self;
}


-(void)setKUser:(ZXUser *)kUser{
    _nickNameLabel.text = kUser.nickname;
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:kUser.icon] placeholderImage:[UIImage imageNamed:@"120"]];
    [self.rejectButton setHidden:YES];
    [self.acceptButton setHidden:YES];
}

- (void)setKMessage:(EMsgMessage *)kMessage{
    _kMessage = kMessage;
    _nickNameLabel.text = kMessage.payload.attrs.contact_nickname;
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:kMessage.payload.attrs.contact_icon] placeholderImage:[UIImage imageNamed:@"120"]];
    if (![kMessage.payload.attrs.action isEqualToString:@"add"]) {
        if ([kMessage.payload.attrs.action isEqualToString:@"accept"]) {
            _detailLabel.text = @"同意了你的好友请求";
        }
        if ([kMessage.payload.attrs.action isEqualToString:@"reject"]) {
            _detailLabel.text = @"拒绝了你的好友请求";
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.acceptButton setHidden:YES];
        [self.rejectButton setHidden:YES];
    }
    else{
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _detailLabel.text = @"请求加你为好友";
        [self.acceptButton setHidden:NO];
        [self.rejectButton setHidden:NO];
    }
    
}

- (void)acceptAction{
    self.kAcceptBlock(_kMessage);
}
- (void)rejectAction{
    self.kRejectBlock(_kMessage);
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
