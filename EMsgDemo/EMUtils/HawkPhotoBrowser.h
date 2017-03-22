//
//  HawkPhotoBrowser.h
//  qiuyouquan
//
//  Created by QYQ-Hawk on 15/12/22.
//  Copyright © 2015年 QYQ-Hawk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HawkPhotoBrowser : UIView <UIScrollViewDelegate>

/**
 *  网络图片的URL地址数组
 */
@property (nonatomic,strong)NSArray *imageArray;

/**
 *  展示本地图片
 */
@property (nonatomic,strong)NSArray *downImageArray;
/**
 *  当前点击的是图片数组中的第几个
 */
@property (nonatomic,assign)int currentIndex;

/**
 *  是否显示保存按钮,默认不显示
 */
@property (nonatomic,assign)BOOL isShowSave;

- (id)init;

- (void)show;

@end

