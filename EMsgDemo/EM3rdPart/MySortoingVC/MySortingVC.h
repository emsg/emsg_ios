//
//  MySortingVC.h
//  按照字典中的某一属性排序（中文）
//
//  Created by SKY on 15/9/25.
//  Copyright (c) 2015年 SKY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MySortingModel.h"

@interface MySortingVC : NSObject

+ (NSMutableArray *)sortingChineseWithDicArray:(NSArray *)dicArray andAttributeKey:(NSString *)attributeKey;//中文排序
+ (NSMutableArray *)returnIndexArrayDataWithGroupArray:(NSArray *)groupArray;//返回索引数组

@end






