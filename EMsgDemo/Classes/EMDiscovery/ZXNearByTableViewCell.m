//
//  ZXNearByTableViewCell.m
//  EMsgDemo
//
//  Created by Hawk on 5/10/16.
//  Copyright © 2016 鹰. All rights reserved.
//

#import "ZXNearByTableViewCell.h"

@implementation ZXNearByTableViewCell

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
    
        //昵称
        UILabel * nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+ 13,
                                                                            10,
                                                                            SCREEN_WIDTH,
                                                                            20)];
        _nickNameLabel = nickNameLabel;
        nickNameLabel.font = [UIFont systemFontOfSize:15];
        
        [self.contentView addSubview:nickNameLabel];
        
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

- (void)setGender:(NSString *)gender{
    if ([gender isEqualToString:@"男"]) {
        _nickNameLabel.textColor = [UIColor grayColor];
        
    }
    else{
        _nickNameLabel.textColor = QYQCOLOR(246, 153, 183);
        
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
