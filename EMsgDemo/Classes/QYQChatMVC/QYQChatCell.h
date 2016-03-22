//
//  QYQChatCell.h
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMsgMessage.h"
typedef void (^localImageTap)(NSString *lat, NSString *lng);
@interface QYQChatCell : UITableViewCell
@property (nonatomic, strong) EMsgMessage *kMssage;
@property(nonatomic, strong) localImageTap tapLocalImage;
@property (nonatomic, assign) CGFloat cellH;
@property (nonatomic,copy) void(^headBolck)(NSString *numStr);
@end
