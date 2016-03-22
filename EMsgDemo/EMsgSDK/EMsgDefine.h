//
//  EMsgDefine.h
//  EMsgDemo
//
//  Created by Hawk on 16/3/17.
//  Copyright © 2016年 鹰. All rights reserved.
//

#define END_TAG @"\01"

#define HEART_BEAT @"\02\01"

#define SERVER_KILL @"\03\01"

#define MSG_TYPE_OPEN_SESSION 0
#define MSG_TYPE_CHAT 1
#define MSG_TYPE_GROUP_CHAT 2
#define MSG_TYPE_STATE 3

#define SERVER_ACK @"server_ack" //消息回执jid

#define RECONNECT_FREQ 10 //自动重连时间间隔

#define HEART_BEAT_FREQ 50 //心跳包间隔

/**
 *  消息的业务类型（一对一聊天，群组聊天）
 */
typedef NS_ENUM(NSUInteger, MsgType) {
  /**
   *  一对一聊天
   */
  SINGLECHAT = 1,
  /**
   *  群组聊天
   */
  GROUPCHAT
};

/**
 *  数据包类型
 */
typedef NS_ENUM(NSInteger, PacketType) {
  /**
   *  不完整数据
   */
  PACKET_NOTEND = -1,
  /**
   *  普通数据读取完成
   */
  PACKET_END,
  /**
   *  服务器强制断开数据流
   */
  PACKET_KILL,
  /**
   *  心跳包数据流
   */
  PACKET_HEART,
};
/**
 *  语音消息
 */
#define MSG_TYPE_AUDIO @"audio"
/**
 *  图片消息
 */
#define MSG_TYPE_IMG @"image"
/**
 *  文本消息
 */
#define MSG_TYPE_TEXT @"text"
/**
 *  地理位置消息
 */
#define MSG_TYPE_GEO @"geo"

