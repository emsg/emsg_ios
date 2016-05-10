//
//  HawkLocation.h
//  qiuyouquan
//
//  Created by QYQ-Hawk on 15/12/21.
//  Copyright © 2015年 QYQ-Hawk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HawkLocationModel : NSObject

@property (nonatomic,copy)NSString * address;

@property (nonatomic,copy)NSString * country;

@property (nonatomic,copy)NSString * province;

@property (nonatomic,copy)NSString * city;

@property (nonatomic,copy)NSString * area;

@property (nonatomic, copy) NSString *latitude;

@property (nonatomic, copy) NSString *longitude;


@end

typedef void(^LocationResultBlock)(NSInteger status, NSError *error);

typedef NS_ENUM(NSUInteger, HLLocalLocationStatus) {
    HLLocalLocationStatusNone,
    HLLocalLocationStatusDisabled,
    HLLocalLocationStatusOngoing,
    HLLocalLocationStatusFailure,
    HLLocalLocationStatusSuccess,
};

@interface HawkLocation : NSObject

/**
 *  Defaultly NO.
 */
@property (nonatomic, assign) BOOL needLocateCity;

/**
 *  Locating status
 */
@property (nonatomic, assign, readonly) HLLocalLocationStatus status;

/**
 *  Description of location result
 */
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, strong) HawkLocationModel *kHL;


- (void)startLocatingWithResult:(LocationResultBlock)block;

/**
 *  Unnecessary indeed
 */
- (void)stopLocating;

@end
