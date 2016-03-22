//
//  messageCell.m
//  QiuYouQuan
//
//  Created by sport on 15/10/15.
//  Copyright (c) 2015年 QYQ. All rights reserved.
//

#import "QYQMessageCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Category.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "Tools_F.h"

@implementation QYQMessageCell
//初始化方法(通过代码)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //头像

        UIImageView * iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,45,45)];
        _iconImageView = iconImageView;
        [self.contentView addSubview:iconImageView];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImageView.clipsToBounds = YES; // 裁剪边缘
        [self.iconImageView.layer setCornerRadius:3];//圆角幅度
        
        //未读
        UILabel * unLabel = [[UILabel alloc] initWithFrame:CGRectMake([iconImageView right], iconImageView.y - 10, 16, 16)];
        unLabel.center = CGPointMake([iconImageView right], iconImageView.y);
        _unreadLabel = unLabel;
        _unreadLabel.backgroundColor = [UIColor redColor];
        _unreadLabel.textColor = [UIColor whiteColor];
        
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont systemFontOfSize:11];
        _unreadLabel.layer.cornerRadius = 8;
        _unreadLabel.clipsToBounds = YES;

        [self.contentView addSubview:_unreadLabel];

        //昵称
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
        
                                                                                    300-63, 20)];
        detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel = detailLabel;
        detailLabel.textColor =QYQHEXCOLOR(0x999999);
        [self.contentView addSubview:detailLabel];
        
        //性别
        UIButton *sexButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        sexButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        sexButton.layer.cornerRadius = 2.5;
        [sexButton setTintColor:[UIColor whiteColor]];
        sexButton.titleLabel.font = [UIFont systemFontOfSize:11];
        _sexButton = sexButton;
        [sexButton setTitle:@"" forState:UIControlStateNormal];
        [sexButton setFrame:CGRectMake(CGRectGetMaxX(nickNameLabel.frame)+6,
                                       12,
                                       60,
                                       20)];
        [self.contentView addSubview:sexButton];
        //时间
        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        10,
                                                                        SCREEN_WIDTH - 10,
                                                                        20)];
        timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel = timeLabel;
        timeLabel.textColor = QYQHEXCOLOR(0x999999);
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:timeLabel];
    }
    
    return self;
}

- (void)setIsFriendList:(BOOL)isFriendList{
    _unreadLabel.hidden = YES;
}

-(void)setMessage:(EMsgMessage *)message{
    _message = message;
    
    BOOL isGroup = NO;
    
    if ([message.envelope.type isEqualToString:@"2"]) {
        isGroup = YES;
    }
    else{
        isGroup = NO;
    }
    
    NSInteger _unreadCount = [message.unReadCountStr integerValue];
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            _unreadLabel.font = [UIFont systemFontOfSize:11];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            _unreadLabel.font = [UIFont systemFontOfSize:10];
        }else{
            _unreadLabel.font = [UIFont systemFontOfSize:8];
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
        _unreadLabel.text = [NSString stringWithFormat:@"%lu",(long)_unreadCount];
    }else{
        [_unreadLabel setHidden:YES];
    }
    
    CGSize nickSize = [self sendContent:message.payload.attrs.messageFromNickName andFontSize:[UIFont systemFontOfSize:15]];
    if (isGroup == YES) {
        nickSize = [self sendContent:message.payload.attrs.messageGroupName andFontSize:[UIFont systemFontOfSize:15]];
    }
        [_nickNameLabel setFrame:CGRectMake(CGRectGetMaxX(_iconImageView.frame)+13,
                                            10,
                                            nickSize.width,
                                            20)];


    if ([_message.payload.attrs.messageType isEqualToString:@"specialTopic"] ||
        [_message.payload.attrs.messageType isEqualToString:@"activity"] ||
        [_message.payload.attrs.messageType isEqualToString:@"race"]||
        [_message.envelope.from isEqualToString:@"qyqRobot@qiuyouzone.com/qiuyouzone"]) {
        _nickNameLabel.textColor = BASE_COLOR;
        [_iconImageView setImage:[UIImage imageNamed:@"120"]];

    }
    else{

        if (isGroup == YES) {
            [_iconImageView sd_setImageWithURL:[NSURL URLWithString:message.payload.attrs.messageGroupUrl] placeholderImage:[UIImage imageNamed:@"120"]];

        }
        else{
            [_iconImageView sd_setImageWithURL:[NSURL URLWithString:message.payload.attrs.messageFromHeaderUrl] placeholderImage:[UIImage imageNamed:@"120.png"]];
        }
        _nickNameLabel.textColor = QYQHEXCOLOR(0x333333);

    }
    if ([message.payload.attrs.messageFromSex isEqualToString:@"男"]) {
        [_sexButton setImage:[UIImage imageNamed:@"nv"] forState:UIControlStateNormal];
        _sexButton.backgroundColor = QYQCOLOR(132, 173, 235);
        
    }else{
        
        [_sexButton setImage:[UIImage imageNamed:@"nan"] forState:UIControlStateNormal];
        _sexButton.backgroundColor = QYQCOLOR(237, 91, 155);
    }
    
    [_sexButton setTitle:message.payload.attrs.messageFromAge forState:UIControlStateNormal];
    [_sexButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    CGSize buttonSize = [self sizeWithText:_sexButton.titleLabel.text font:_sexButton.titleLabel.font maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    _sexButton.frame =CGRectMake(CGRectGetMaxX(_nickNameLabel.frame)+5,
                                 12,
                                 15 + buttonSize.width,
                                 15);
    
    if (message.payload.attrs.messageFromAge) {
        _sexButton.hidden = NO;
        if (isGroup == YES) {
            _sexButton.hidden = YES;
        }
        else{
            _sexButton.hidden = NO;
            
        }
    }
    else{
        _sexButton.hidden = YES;
    }
    _sexButton.hidden = YES;

    if (isGroup == YES) {
        _nickNameLabel.text = message.payload.attrs.messageGroupName;
    }
    else{
        _nickNameLabel.text = message.payload.attrs.messageFromNickName;
    }
    
    //时间戳的转换时间
    NSString * showTitleTime = @"0";
    if (message.envelope.ct.length == 13) {
        showTitleTime = [message.envelope.ct substringToIndex:10];
    }
    else{
        showTitleTime = message.envelope.ct;
    }
    NSDate *confromTimesp = [NSDate
                             dateWithTimeIntervalSince1970:[showTitleTime longLongValue]];
    //判断显示的时间
    _timeLabel.text = [confromTimesp formattedTime];
    if ([message.payload.attrs.messageType isEqualToString:@"image"]) {
        _detailLabel.text = @"[图片]";
    }
    else if ([message.payload.attrs.messageType isEqualToString:@"audio"]) {
        _detailLabel.text = @"[语音]";
    }
    else if ([message.payload.attrs.messageType isEqualToString:@"geo"]) {
        _detailLabel.text = @"[位置]";
    }
    else{
        _detailLabel.text = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.payload.content];
    }
}
//根据字符串长度获取宽度的方法
- (CGSize)sendContent:(NSString *)cont andFontSize:(UIFont *)font{
    CGSize Username;
    Username = [cont boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return Username;
}
//自适应尺寸
-(CGSize)sizeWithText:(NSString *)text
                 font:(UIFont *)font
              maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    maxSize=[text boundingRectWithSize:maxSize
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:attrs
                               context:nil]
    .size;
    return maxSize;
}
- (void)awakeFromNib {
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
