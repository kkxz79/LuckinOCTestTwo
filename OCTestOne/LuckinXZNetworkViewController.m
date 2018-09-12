//
//  LuckinXZNetworkViewController.m
//  OCTestOne
//
//  Created by kkxz on 2018/9/12.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "LuckinXZNetworkViewController.h"
#import "XZBaseRequest.h"
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.height == 2436) : NO)

@interface LuckinXZNetworkViewController ()

@end

@implementation LuckinXZNetworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"XZNetwork";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"bannar" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
    self.navigationItem.rightBarButtonItem = barButton;
    [self dataRequest];
}

-(void)dataRequest
{
    NSDictionary * dict = @{@"version":@"1900"};
    XZBaseRequest *request = [[XZBaseRequest alloc] init];
    request.subUrl = @"/resource/m/sys/app/start2";
    request.requestArgument = dict;
    [request startWithCompletionBlockSuccess:^(XZBaseRequest * _Nonnull request) {
        NSDictionary* resultDict = request.responseJsonObject[@"content"];
        NSLog(@"resultDict :%@",resultDict);
        //启动app时，存储uid
        NSString * uid = request.responseJsonObject[@"uid"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:(uid==nil ? @"":uid) forKey:@"global_uid"];
        [userDefaults synchronize];
        NSLog(@"start uid ：%@",uid);
        
    }failure:^(XZBaseRequest * _Nonnull request, NSError * _Nonnull error) {
        //
    }];
}

-(void)rightButtonAction
{
    //首页bannar广告位图
    NSDictionary * dict = @{
                            @"Width":iPhoneX ? @(1125) : @(1),
                            @"Height":iPhoneX ? @(2436) : @(2),
                            @"source":@(2),
                            @"displayLocation":@"0",
                            @"appVersion":@"1900"
                            };
    XZBaseRequest *request = [[XZBaseRequest alloc] init];
    request.subUrl = @"/resource/m/sys/app/adpos";
    request.requestArgument = dict;
    [request startWithCompletionBlockSuccess:^(XZBaseRequest * _Nonnull request) {
        //
    } failure:^(XZBaseRequest * _Nonnull request, NSError * _Nonnull error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
