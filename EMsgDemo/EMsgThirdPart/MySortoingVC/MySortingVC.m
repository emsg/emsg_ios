//
//  MySortingVC.m
//  按照字典中的某一属性排序（中文）
//
//  使用说明：引入MySortingVC.h和MySortingModel.h的头文件 创建一个该类的对象 对象调用中文排序/非中文排序 返回值为Model数组  调用返回索引数组的前提必须调用排序
//
//  Created by SKY on 15/9/25.
//  Copyright (c) 2015年 SKY. All rights reserved.
//

#import "MySortingVC.h"
#import "MySortingModel.h"


@implementation MySortingVC

#pragma mark 中文对象数据排序
+ (NSArray *)sortingChineseWithDicArray:(NSArray *)dicArray andAttributeKey:(NSString *)attributeKey{
    
    if (dicArray.count == 0) {//无数据直接返回
        return nil;
    }
    
    NSMutableArray *modelArray = [NSMutableArray array];//初始化model数组
    //数据的处理
    for (NSDictionary *subDic in dicArray) {
        
        //将Dic中需要排序的中文属性改成拼音 并对拼音做处理
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:subDic];
        NSString *kname = [mutableDic objectForKey:attributeKey];
        kname  = [kname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除中文名字两端空格和回车
        [mutableDic setObject:kname forKey:attributeKey];
        NSString *pinyinName = [[self chineseTransfrom:kname] capitalizedString];//转拼音且拼音首字母转大写
        [mutableDic setValue:pinyinName forKey:@"pinyinName"];//在字典中增加拼音名字属性
        
        MySortingModel *model = [MySortingModel modelWithDic:mutableDic];
        [modelArray addObject:model];
        
    }
    
    //按照拼音属性排序标识  YES 为升序  NO为降序
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"pinyinName" ascending:YES];
    NSArray * sortDescriptorArray = [[NSArray alloc]initWithObjects:&sortDescriptor count:1];
    
    //此处ModelArr必须为可变数组
    [modelArray sortUsingDescriptors:sortDescriptorArray];//将Model数组排序
    NSArray *groupArray = [self dataGroupingWith:modelArray];//将数据分组
    
    return groupArray;//返回分组后的Model数组
}




#pragma mark 将数据按照首字母分组（特殊字符为一组）
+ (NSMutableArray *)dataGroupingWith:(NSMutableArray *)modelArray{
    
    NSMutableArray *groupArray = [NSMutableArray array];//初始化存放各个分组的数组
    NSString *temporaryStr = [[NSString alloc]init];//临时存放首字母
    NSMutableArray *otherCharArr = [NSMutableArray array];//存放首字母不是A-Z的数组
    
    //分组
    for (MySortingModel * model in modelArray) {
        
        //Cocoa框架中的NSPredicate用于查询，原理和用法都类似于SQL中的where，作用相当于数据库的过滤取
        //判断字符串首字母是否为字母
        NSString *initial = [model.pinyinName substringToIndex:1];//取出拼音首字母
        NSString *regex = @"[A-Za-z]+";//正则判断
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        if ([predicate evaluateWithObject:initial]) {//首字母是字母
            
            //按照字母分组
            if (![temporaryStr isEqualToString:initial]) {//首字母不同
                NSMutableArray *mutArr = [NSMutableArray array];
                [mutArr addObject:model];
                [groupArray addObject:mutArr];
                temporaryStr = initial;
            } else {//首字母相同
                NSMutableArray *mutArr = groupArray[groupArray.count-1];//取出最后一个数组来添加相同的元素
                [mutArr addObject:model];//加入首字母相同的元素
            }
            
            
        } else {//首字母不是字母
            
            [otherCharArr addObject:model];
            
        }
        
    }
    
    if (otherCharArr.count > 0) {
        //遍历完成后将不是字母开头的分组放到分组的最后一个元素
        [groupArray addObject:otherCharArr];
    }
    

    
    
    return groupArray;//返回分组后的数据
}


#pragma mark 返回索引数组
+ (NSMutableArray *)returnIndexArrayDataWithGroupArray:(NSArray *)groupArray{
    
    NSMutableArray *indexArray = [NSMutableArray array];//初始化索引数组
    //取出数组的每个元素的分组字母
    for (NSArray *subArray in groupArray) {
        
        //判断字符串首字母是否为字母
        NSString *pinyinStr = [subArray[0] pinyinName];//取出索引的拼音字符串
        NSString *initial = [pinyinStr substringToIndex:1];//取出拼音首字母
        NSString *regex = @"[A-Za-z]+";//正则判断
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        if ([predicate evaluateWithObject:initial]) {//是字母
            [indexArray addObject:initial];
        } else {//不是字母
            initial = @"#";
            [indexArray addObject:initial];
        }
        
        
    }
    
    return indexArray;//返回索引数组
}




#pragma mark 中文转拼音
+ (NSString * )chineseTransfrom:(NSString *)string{
    NSMutableString *ms = [[NSMutableString alloc] initWithString:string];
    if ([string length]) {
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
        }
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
        }
    }
    return ms;
}



#pragma mark 过滤指定字符串
//里面的指定字符根据自己的需要添加
+ (NSString*)RemoveSpecialCharacter: (NSString *)str {
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @",.？、 ~￥#&<>《》()[]{}【】^@/￡¤|§¨「」『』￠￢￣~@#&*（）——+|《》$_€"]];
    if (urgentRange.location != NSNotFound)
    {
        return [self RemoveSpecialCharacter:[str stringByReplacingCharactersInRange:urgentRange withString:@""]];
    }
    return str;
}


@end
