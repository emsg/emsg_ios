//
//  ZXDetailMessageViewController.h
//  ChatDemo-UI3.0
//
//  Created by mac on 16/3/13.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXDetailMessageViewController : UIViewController

@property (nonatomic,strong)ZXUser *kUser;

@property (nonatomic,assign)BOOL  isFromChatVC;

@property (nonatomic,assign)BOOL isFromContact;

@end
