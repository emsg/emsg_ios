//
//  QYQChatController.h
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMBaseUIViewController.h"

typedef NS_ENUM(NSInteger, ZBMessageViewState) {
  ZBMessageViewStateShowFace,
  ZBMessageViewStateShowShare,
  ZBMessageViewStateShowNone,
};
@interface QYQChatController : EMBaseUIViewController

//聊天对象,单聊:聊天对方的球友号 群聊:group+群组id
@property(nonatomic, strong) NSString *kChatter;
//如果是用户主动发起的聊天,需要将此聊天对象的信息传入,用来在ChatList界面生成一条数据
@property(nonatomic,strong)NSMutableDictionary * infoDic;
//单聊/群聊 = NO/YES
@property(nonatomic,assign)BOOL isGroup;
//是否是系统消息
@property (nonatomic,assign)BOOL isSystemMessage;

- (void)makeChatter;

- (void)messageViewAnimationWithMessageRect:(CGRect)rect
                   withMessageInputViewRect:(CGRect)inputViewRect
                                andDuration:(double)duration
                                   andState:(ZBMessageViewState)state;
@end
