//
//  QYQMessageShareMenuView.h
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/24.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageShareMenuItem.h"

#define kZBMessageShareMenuPageControlHeight 30

@protocol ZBMessageShareMenuViewDelegate <NSObject>

@optional
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index;

@end

@interface QYQMessageShareMenuView : UIView

/**
 *  第三方功能Models
 */
@property (nonatomic, strong) NSArray *shareMenuItems;

@property (nonatomic, weak) id <ZBMessageShareMenuViewDelegate> delegate;

- (void)reloadData;

@end
