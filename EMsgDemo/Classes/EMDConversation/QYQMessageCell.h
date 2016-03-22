//
//  messageCell.h
//  QiuYouQuan
//
//  Created by sport on 15/10/15.
//  Copyright (c) 2015年 QYQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYQBaseTableViewCell.h"
#import "EMsgMessage.h"

@interface QYQMessageCell : QYQBaseTableViewCell
@property (nonatomic,weak)UIImageView * iconImageView;
@property (nonatomic,weak)UILabel * nickNameLabel;
@property (nonatomic,weak)UIButton * sexButton;
@property (nonatomic,weak)UILabel * detailLabel;
@property (nonatomic,weak)UILabel * timeLabel;
@property (nonatomic,weak)UILabel * unreadLabel;
@property (nonatomic,assign)BOOL isFriendList;

/**
 *  传入一条消息的字典或者模型
 */
@property (nonatomic,strong)EMsgMessage * message;

- (void)setIsFriendList:(BOOL)isFriendList;

@end
