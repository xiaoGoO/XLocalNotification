//
//  Utils.m
//  XLocalNotificationLib
//
//  Created by xiaoG on 16/10/17.
//  Copyright © 2016年 xiaoG. All rights reserved.
//

#import "Utils.h"

@implementation Utils

/**
 *  将NULL转换为nil
 *
 *  @param obj 要转换的对象
 *
 *  @return id 任意类型
 */
+ (id) convertNULL:(id) obj{
    if (obj == [NSNull null]) {
        return nil;
    }
    return obj;
}



@end
