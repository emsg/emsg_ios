//
//  EMDContactViewController.h
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMBaseUIViewController.h"

@interface EMDContactViewController : EMBaseUIViewController
@property (nonatomic, strong) UIView * noReadServerMessageLabel;
//public
- (void)apiRequestContactList;
@end
