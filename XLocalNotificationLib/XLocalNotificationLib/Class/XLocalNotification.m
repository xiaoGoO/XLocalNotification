//
//  XLocalNotification.m
//  XLocalNotificationLib
//
//  Created by xiaoG on 16/10/14.
//  Copyright © 2016年 xiaoG. All rights reserved.
//

#import "XLocalNotification.h"
#import "Aspects.h"


@interface XLocalNotification (){
    NSMutableArray *_handles;
}

@end

@implementation XLocalNotification


static XLocalNotification *_xLocalNotification;

+ (instancetype) shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!_xLocalNotification)
            _xLocalNotification = [[XLocalNotification alloc] init];
    });
    return _xLocalNotification;
}

/**
 * 初始化
 */
- (void) initSDK{
    [self registerNotification];
}


/**
 * 注册通知
 */
-(void) registerNotification{
    
    //IOS 10 注册推送
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            NSLog(@"推送注册成功");
        }else{
            NSLog(@"推送注册失败");
        }
    }];
    
    //获取通知设置状态
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"---->%ld",settings.authorizationStatus);
        if(settings.authorizationStatus == UNAuthorizationStatusNotDetermined){//未授权通知权限
            
        }else if(settings.authorizationStatus == UNAuthorizationStatusDenied){//拒绝通知权限
            
        }else if(settings.authorizationStatus == UNAuthorizationStatusAuthorized){//允许通知权限
        }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    //拦截 推送接收方法 application:didReceiveLocalNotification:
    if([((NSObject *)[UIApplication sharedApplication].delegate) respondsToSelector:@selector(application:didReceiveLocalNotification:)]){
        [((NSObject *)[UIApplication sharedApplication].delegate) aspect_hookSelector:@selector(application:didReceiveLocalNotification:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info,UIApplication *application,UILocalNotification * notification){
            
            for (NotificationCallBack block in _handles) {
                block(notification.userInfo);
            }
            
        } error:nil];
    }
    //拦截 推送接收方法 userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
    if([((NSObject *)[UIApplication sharedApplication].delegate) respondsToSelector:@selector(userNotificationCenter:willPresentNotification: withCompletionHandler:)]){
        [((NSObject *)[UIApplication sharedApplication].delegate) aspect_hookSelector:@selector(userNotificationCenter:willPresentNotification: withCompletionHandler:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info,UNUserNotificationCenter *center,UNNotification * notification){
            for (NotificationCallBack block in _handles) {
                block(notification.request.content.userInfo);
            }
        } error:nil];
    }
    
    
    
    
}
- (void) plushNotificationWith


- (void) plushTs{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"我是标题";
    content.subtitle = @"我是副标题";
    content.body = @"我是内容";
    content.badge = @(2);
    [self plushNotificationById:@"123" time:60 content:content];
//    [self plushByContent:content];
}

- (void) plushNotificationById:(NSString *)identifier time:(NSTimeInterval) time content:(UNNotificationContent *)content{
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:YES];
    UNNotificationRequest *requset = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:requset withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"---->%@",error);
    }];
}

- (void) plushByContent:(UNNotificationContent *)content{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday
    components.hour = 17;
    components.minute = 20;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"111" content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

-(void) addNotificationObserver:(NotificationCallBack)block{
    if(!_handles)
        _handles = [[NSMutableArray alloc] init];
    [_handles addObject:block];
}




@end
