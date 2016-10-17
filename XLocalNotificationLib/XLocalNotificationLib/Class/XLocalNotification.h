//
//  XLocalNotification.h
//  XLocalNotificationLib
//
//  Created by xiaoG on 16/10/14.
//  Copyright © 2016年 xiaoG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

typedef void(^NotificationCallBack)(NSDictionary* info);

@interface XLocalNotification : NSObject

+ (instancetype) shareInstance;

-(void) addNotificationObserver:(NotificationCallBack ) block;
/**
 * 初始化
 */
- (void) initSDK;
/**
 * 测试推送
 */
- (void) plushTs;

@end
