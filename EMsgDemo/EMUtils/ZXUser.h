//
//  ZXUser.h
//  ChatDemo-UI3.0
//
//  Created by hawk on 16/3/9.
//  Copyright © 2016年 hawk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXUser : NSObject

@property(nonatomic,strong)NSString * uid;

@property(nonatomic,strong)NSString * token;

@property(nonatomic,strong)NSString * mobile;

@property(nonatomic,strong)NSString * email;

@property (nonatomic,copy)NSString * host;

@property (nonatomic,copy)NSString * port;

@property (nonatomic,copy)NSString * domain;

@property (nonatomic,copy)NSString * nickname;

@property(nonatomic,strong)NSString * gender;

@property (nonatomic,strong)NSString * icon;

@property (nonatomic,strong)NSString * username;

@property (nonatomic,strong)NSString * birthday;

@property (nonatomic,assign)BOOL is_contact;


@end
