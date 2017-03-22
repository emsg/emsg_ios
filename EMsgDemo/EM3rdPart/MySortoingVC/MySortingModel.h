//
//  MySortingModel.h
//  按照字典中的某一属性排序（中文）
//
//  Created by SKY on 15/9/24.
//  Copyright (c) 2015年 SKY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySortingModel : NSObject

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

@property(copy,nonatomic) NSString *pinyinName;


//字典转Model的类方法
+ (MySortingModel *)modelWithDic:(NSDictionary *)dic;

@end
