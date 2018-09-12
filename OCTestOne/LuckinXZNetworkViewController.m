//
//  LuckinXZNetworkViewController.m
//  OCTestOne
//
//  Created by kkxz on 2018/9/12.
//  Copyright © 2018年 kkxz. All rights reserved.
//

#import "LuckinXZNetworkViewController.h"
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
   //
}

-(void)rightButtonAction
{
    //
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
