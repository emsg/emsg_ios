//
//  MySortingModel.m
//  按照字典中的某一属性排序（中文）
//
//  Created by SKY on 15/9/24.
//  Copyright (c) 2015年 SKY. All rights reserved.
//

#import "MySortingModel.h"

@implementation MySortingModel

//+ (BOOL)propertyIsOptional:(NSString *)propertyName{
//    return YES;
//}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

+ (MySortingModel *)modelWithDic:(NSDictionary *)dic{
    NSArray * allKeys = [dic allKeys];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < allKeys.count ;i++) {
        if([dic valueForKey:[allKeys objectAtIndex:i]]) {
            NSString * sKey = [allKeys objectAtIndex:i];
            if ([sKey isEqualToString:@"id"]) {
                sKey = @"uid";
            }
            [dict setObject:[dic valueForKey:[allKeys objectAtIndex:i]] forKey:sKey];

        }
    }
    

    return [[MySortingModel alloc]initWithDic:dict];
}


//重写init给Model赋值
- (id)initWithDic:(NSDictionary *)dic{
    
    if (self = [super init]) {
        
        [self setValuesForKeysWithDictionary:dic];
        
    }
    
    return self;
}

+(id)copyWithZone:(struct _NSZone *)zone{
    return self;
}

@end
