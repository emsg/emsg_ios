//
//  EMsgAttrs.h
//  EmsClientDemo
//
//  Created by QYQ-Hawk on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  消息附加属性类
 */
@interface EMsgAttrs : NSObject
/**
 *  消息类型:包括@"text","image","audio","geo",@"specialTopic",@"activity",@"race"分别对应：文本消息，图片消息，语音消息，地理位置消息,主题,活动,赛事
 */
@property(nonatomic, strong) NSString *messageType;
/**
 *  图片消息时，文件服务器图片地址id
 */
@property(nonatomic, strong) NSString *messageImageUrlId;
/**
 *  语音消息时，语音时长
 */
@property(nonatomic, strong) NSString *messageAudioTime;
/**
 *  消息为地理位置的时候，GeoLat
 */
@property(nonatomic, strong) NSString *messageGeoLat;
/**
 *  消息为地理位置的时候，GeoLng
 */
@property(nonatomic, strong) NSString *messageGeoLng;
/**
 *  用户的昵称
 */
@property(nonatomic, strong) NSString *messageFromNickName;
/**
 * 用户的头像
 */
@property(nonatomic, strong) NSString *messageFromHeaderUrl;
/**
 *  to用户的昵称
 */
@property(nonatomic, strong) NSString *messageToNickName;
/**
 * to用户的头像
 */
@property(nonatomic, strong) NSString *messageToHeaderUrl;
/**
 *  用户的性别
 */
@property(nonatomic, strong) NSString *messageFromSex;
/**
 *  用户的年龄
 */
@property(nonatomic, strong) NSString *messageFromAge;

/**
 *  显示时间label
 */
@property (nonatomic,assign) BOOL isShowTimelabel;
/**
 *  赛事/活动/主题ID
 */
@property(nonatomic,copy) NSString * messageId;
//"messageId":"活动id",
//"name":"活动名称",
//"image":"活动图片",
//"time":"活动时间",
//"addr":"活动地址",
@property(nonatomic,copy) NSString *name;

@property(nonatomic,copy) NSString *image;

@property(nonatomic,copy) NSString *time;

@property(nonatomic,copy) NSString * addr;


@property (nonatomic,copy) NSString * userId;

//战队队长id
@property (nonatomic,copy)NSString * corpsId;

@property (nonatomic,copy)NSString * corpsName;

//群组
@property (nonatomic,copy)NSString * groupNickName;

@property (nonatomic,copy)NSString * messageGroupUrl;

//群昵称
@property (nonatomic,copy)NSString * messageGroupName;

//群id
@property (nonatomic,copy)NSString * messageGroupId;

@property (nonatomic,copy)NSString * messageNoti;

//新字段
/**
 *  当 action = add / reject / accept 接口调用成功时，
 content_id 对应的 app 用户会收到 emsg_server 推来的 “添加、拒绝、接受” 好友消息
 */

@property (nonatomic,copy)NSString * message_type;

@property (nonatomic,copy)NSString * action;

@property (nonatomic,copy)NSString * contact_icon;

@property (nonatomic,copy)NSString * contact_nickname;

@property (nonatomic,copy)NSString * contact_id;

@end
