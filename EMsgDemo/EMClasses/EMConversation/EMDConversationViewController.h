//
//  EMDConversationViewController.h
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "EMBaseUIViewController.h"

@interface EMDConversationViewController : EMBaseUIViewController
- (void)removeTableViewDelegate;

- (void)reloadChatListDataSource;
@end
