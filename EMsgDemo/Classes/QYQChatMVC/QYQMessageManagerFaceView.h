//
//  QYQMessageManagerFaceView.h
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/24.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBFaceView.h"

@protocol ZBMessageManagerFaceViewDelegate <NSObject>

- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele;

@end

@interface QYQMessageManagerFaceView : UIView<UIScrollViewDelegate,ZBFaceViewDelegate>

@property (nonatomic,weak)id<ZBMessageManagerFaceViewDelegate>delegate;

@end
