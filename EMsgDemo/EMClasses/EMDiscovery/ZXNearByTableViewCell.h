//
//  ZXNearByTableViewCell.h
//  EMsgDemo
//
//  Created by Hawk on 5/10/16.
//  Copyright © 2016 鹰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXNearByTableViewCell : UITableViewCell

@property (nonatomic,weak)UIImageView * iconImageView;
@property (nonatomic,weak)UILabel * nickNameLabel;
@property (nonatomic,weak)UILabel * timeLabel;
@property (nonatomic,strong)NSString * gender;
@property (nonatomic,weak)UILabel * distLabel;

@end
