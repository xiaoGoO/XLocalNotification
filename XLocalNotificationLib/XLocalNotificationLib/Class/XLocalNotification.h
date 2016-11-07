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


@protocol XLocalNotificationDelegate;

@interface XLocalNotification : NSObject

+ (instancetype) shareInstance;

/**
 * 初始化
 */
- (void) initSDK;
/**
 * 测试推送
 */
- (void) plushTs;


/**
 *  发送倒计时推送
 *
 *  @param identifier   id
 *  @param title        标题
 *  @param subTitle     副标题
 *  @param body         内容
 *  @param userInfo     传递数据
 *  @param badge        红点
 *  @param longTime     间隔时长
 *  @param repeats      是否重复提醒
 */
- (void) plushNotificationWithIdentifier:(NSString *) identifier title:(NSString *) title subTitle:(NSString *) subTitle body:(NSString *)body userInfo:(NSDictionary *)userInfo badge:(int) badge longTime:(NSTimeInterval)longTime repeats:(BOOL)repeats;

/**
 *  移除所有通知
 */
- (void) removeAllNotification;
/**
 *  通过ID移除通知
 *
 *  @param identifier 唯一标识
 */
- (void) removeNotificationByIdentifier:(NSString *)identifier;

/**
 *  添加推送监听
 *
 *  @param delegate 监听回调
 */
- (void) addNotificationDeleaget:(id<XLocalNotificationDelegate>) delegate;



@end
/**
 *  代理
 */
@protocol XLocalNotificationDelegate <NSObject>

- (void) XLocalNotificationDidReceiveUserInfo:(NSDictionary *)userInfo;

@end

/**
 *  通知状态
 */
typedef NS_ENUM(NSInteger, XNotificationAuthorStatus) {
    /** *  未授权通知权限 */ XNotificationAuthorStatusNotDetermined = 0,
    /** *  权限被拒绝 */ XNotificationAuthorStatusDenied,
    /** *  允许权限 */ XNotificationAuthorStatusAuthorized
};

