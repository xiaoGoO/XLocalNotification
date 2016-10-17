//
//  ViewController.m
//  SimpleDome
//
//  Created by xiaoG on 16/10/14.
//  Copyright © 2016年 xiaoG. All rights reserved.
//

#import "ViewController.h"
#import <XLocalNotificationLib/XLocalNotificationLib.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *testPlushBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)onPlush:(UIButton *)sender {
    [[XLocalNotification shareInstance] plushTs];
    
}

@end
