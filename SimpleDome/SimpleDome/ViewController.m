//
//  ViewController.m
//  SimpleDome
//
//  Created by xiaoG on 16/10/14.
//  Copyright © 2016年 xiaoG. All rights reserved.
//

#import "ViewController.h"
#import <XLocalNotificationLib/XLocalNotificationLib.h>

@interface ViewController ()<XLocalNotificationDelegate>
@property (weak, nonatomic) IBOutlet UIButton *testPlushBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[XLocalNotification shareInstance] addNotificationDeleaget:self];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)onPlush:(UIButton *)sender {
    switch (sender.tag) {
        case 101:
//            [[XLocalNotification shareInstance] plushNotificationWithIdentifier:@"view" title:@"我是标题哟！" subTitle:@"我是副标题" body:@"我是内容详情哟！！！！" userInfo:@{@"title":@"标题",@"name":@"xiaoG"} badge:1 longTime:60 repeats:YES];
            [[XLocalNotification shareInstance] plushTs];
            break;
        case 102:
            [[XLocalNotification shareInstance] removeAllNotification];
        case 103:
            [[XLocalNotification shareInstance] removeNotificationByIdentifier:@"view"];
        default:
            break;
    }
    
}

- (void) XLocalNotificationDidReceiveUserInfo:(NSDictionary *)userInfo{

    NSLog(@"接收到推送-->%@",userInfo);
}

@end
