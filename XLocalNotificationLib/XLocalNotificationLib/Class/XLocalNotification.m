//
//  XLocalNotification.m
//  XLocalNotificationLib
//
//  Created by xiaoG on 16/10/14.
//  Copyright © 2016年 xiaoG. All rights reserved.
//

#import "XLocalNotification.h"
#import "Aspects.h"
#import "Utils.h"

@interface XLocalNotification (){
    NSMutableArray *_handles;
}

@end

@implementation XLocalNotification


static XLocalNotification *_xLocalNotification;

#pragma mark - single Method

+ (instancetype) shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!_xLocalNotification)
            _xLocalNotification = [[XLocalNotification alloc] init];
    });
    return _xLocalNotification;
}

#pragma mark - 初始化

/**
 * 初始化
 */
- (void) initSDK{
    [self registerNotification];
}

#pragma mark - 注册

/**
 * 注册通知
 */
-(void) registerNotification{
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){//IOS 10以后版本
        [self registerNotificationIOS10];
    }else if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){//IOS 8 以后版本
        [self registerNotificationIOS8RoLater];
    }else{
        [self registerNotificationOther];
    }
    
    
}
/**
 *  其他版本注册
 */
-(void) registerNotificationOther{

}

/**
 *  IOS 8 之后版本 注册
 */
- (void) registerNotificationIOS8RoLater{
    if([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
}
/**
 *  IOS 10 注册方法
 */
-(void) registerNotificationIOS10{
    //IOS 10 注册推送
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            NSLog(@"推送注册成功");
        }else{
            NSLog(@"推送注册失败");
        }
    }];
    
    //拦截 推送接收方法 application:didReceiveLocalNotification:
    if([((NSObject *)[UIApplication sharedApplication].delegate) respondsToSelector:@selector(application:didReceiveLocalNotification:)]){
        [((NSObject *)[UIApplication sharedApplication].delegate) aspect_hookSelector:@selector(application:didReceiveLocalNotification:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info,UIApplication *application,UILocalNotification * notification){
            for (id<XLocalNotificationDelegate> deleagte in _handles) {
                [deleagte XLocalNotificationDidReceiveUserInfo:notification.userInfo];
            }
            
        } error:nil];
    }
    //拦截 推送接收方法 userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
    if([((NSObject *)[UIApplication sharedApplication].delegate) respondsToSelector:@selector(userNotificationCenter:willPresentNotification: withCompletionHandler:)]){
        [((NSObject *)[UIApplication sharedApplication].delegate) aspect_hookSelector:@selector(userNotificationCenter:willPresentNotification: withCompletionHandler:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info,UNUserNotificationCenter *center,UNNotification * notification){
            for (id<XLocalNotificationDelegate> deleagte in _handles) {
                [deleagte XLocalNotificationDidReceiveUserInfo:notification.request.content.userInfo];
            }
        } error:nil];
    }
}

#pragma mark - TEST

- (void) plushTs{
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"我是标题";
    content.subtitle = @"我是副标题";
    content.body = @"我是内容";
    content.badge = @(2);
    //    [self plushNotificationById:@"123" time:60 content:content];
    //    [self plushByContent:content];
}

- (void) plushByContent:(UNNotificationContent *)content{
    [self checkNotificationActiveCallBlock:^(XNotificationAuthorStatus status) {
        if(status == XNotificationAuthorStatusDenied){//木有通知权限
            [self showAlertWithTitle:@"温馨提示" msg:@"请设置通知权限" buttons:@[@"确认",@"取消"] callBlock:^(int index) {
                switch (index) {
                    case 0:
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:"]];
                        break;
                        
                    default:
                        break;
                }
            }];
        }else if(status == XNotificationAuthorStatusAuthorized){//有接收通知权限
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.hour = 17;
            components.minute = 20;
            
            UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"111" content:content trigger:trigger];
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        }else{
            [self showAlertWithTitle:@"温馨提示" msg:@"通知功能状态异常" buttons:@[@"关闭"] callBlock:^(int index) {
                
            }];
        }
        
    }];
    
}

#pragma mark - 公开方法
/**
 *  发送倒计时推送
 *
 *  @param identifier   id
 *  @param title        标题
 *  @param subTitle     副标题
 *  @param body         内容
 *  @param userInfo     传递数据
 *  @param badge        红点
 *  @param longTime     间隔时长 只能填大于或者等于60的数字（即为最少一分钟）
 *  @param repeats      是否重复提醒
 */
- (void) plushNotificationWithIdentifier:(NSString *) identifier title:(NSString *) title subTitle:(NSString *) subTitle body:(NSString *)body userInfo:(NSDictionary *)userInfo badge:(int) badge longTime:(NSTimeInterval)longTime repeats:(BOOL)repeats{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [Utils convertNULL:title];
    content.subtitle = [Utils convertNULL:subTitle];
    content.body = [Utils convertNULL:body];
    content.userInfo = [Utils convertNULL:userInfo];
    content.badge = [NSNumber numberWithInt:badge];
    [self plushTimeNotificationById:identifier time:longTime content:content repeats:repeats];
}



/**
 *  移除所有通知
 */
- (void) removeAllNotification{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
}
/**
 *  通过ID移除通知
 *
 *  @param identifier 唯一标识
 */
- (void) removeNotificationByIdentifier:(NSString *)identifier{
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];

}

/**
 *  添加推送监听
 *
 *  @param delegate 监听回调
 */
- (void) addNotificationDeleaget:(id<XLocalNotificationDelegate>) delegate{
    if(!_handles)
        _handles = [[NSMutableArray alloc] init];
    [_handles addObject:delegate];
}


-(void)checkNotificationActiveCallBlock:(void (^)(XNotificationAuthorStatus)) callBlock{
    //IOS 10 注册推送
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //获取通知设置状态
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if(settings.authorizationStatus == UNAuthorizationStatusNotDetermined){//未授权通知权限
            callBlock(XNotificationAuthorStatusNotDetermined);
        }else if(settings.authorizationStatus == UNAuthorizationStatusDenied){//拒绝通知权限
            callBlock(XNotificationAuthorStatusDenied);
        }else if(settings.authorizationStatus == UNAuthorizationStatusAuthorized){//允许通知权限
            callBlock(XNotificationAuthorStatusAuthorized);
        }
        
    }];
}

#pragma mark - 私有方法

-(void) plushTTT{
    NSDate *fireDate = [[NSDate alloc] init];
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSCalendarUnit repeatInterval = kCFCalendarUnitSecond;
    NSString *sContent = @"我是内容";
    NSString *sTitle = @"我是变态";
    NSInteger iBadge = 1;
    NSDictionary *infoDic = @{}
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = fireDate;
    //时区
    notification.timeZone = timeZone;
    //设置重复间隔
    notification.repeatInterval = repeatInterval;
    //通知内容
    notification.alertBody = sContent;
    //通知标题
    notification.alertTitle = sTitle;
    //角标数字
    notification.applicationIconBadgeNumber = iBadge;
    //通知数据
    notification.userInfo = infoDic;
    
    
}

/**
 *  发送倒计时推送
 *
 *  @param identifier 唯一标示
 *  @param time       时长
 *  @param content    内容
 *  @param repeats    是否重复
 */
- (void) plushTimeNotificationById:(NSString *)identifier time:(NSTimeInterval) time content:(UNNotificationContent *)content repeats:(BOOL)repeats{
    
    
    [self checkNotificationActiveCallBlock:^(XNotificationAuthorStatus status) {
        if(status == XNotificationAuthorStatusDenied){//木有通知权限
            [self showAlertWithTitle:@"温馨提示" msg:@"请设置通知权限" buttons:@[@"确认",@"取消"] callBlock:^(int index) {
                switch (index) {
                    case 0:
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:"]];
                        break;
                    default:
                        break;
                }
            }];
        }else if(status == XNotificationAuthorStatusAuthorized){//有接收通知权限
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:repeats];
            UNNotificationRequest *requset = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:requset withCompletionHandler:^(NSError * _Nullable error) {
                NSLog(@"---->%@",error);
            }];
        }else{
            [self showAlertWithTitle:@"温馨提示" msg:@"通知功能状态异常" buttons:@[@"关闭"] callBlock:^(int index) {
                
            }];
        }
        
    }];
    
}
/**
 *   *  显示对话框
 *
 *  @param title     标题
 *  @param msg       内容
 *  @param buttons   按钮 ["确认","取消"]
 *  @param callBlock 点击事件回调
 */
-(void) showAlertWithTitle:(NSString *)title msg:(NSString *)msg buttons:(NSArray<NSString *> *)buttons callBlock:(void (^)(int)) callBlock{
    //主线程执行弹出提示框，否则不刷新页面
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        int i = 0;
        for (NSString *item in buttons) {
            __block int j = i;
            UIAlertAction * action = [UIAlertAction actionWithTitle:item style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                callBlock(j);
            }];
            [alertView addAction:action];
            i++;
        }
        [[self getCurrentVC] presentViewController:alertView animated:YES completion:nil];
    });

}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
    result = nextResponder;
    else
    result = window.rootViewController;
    
    return result;
}


@end
