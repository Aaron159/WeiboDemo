//
//  DiscoverViewController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/29.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "DiscoverViewController.h"
#import "NearbyUserViewController.h"
@interface DiscoverViewController ()

@end

@implementation DiscoverViewController
- (IBAction)nearbyUser:(id)sender {
    NearbyUserViewController *nearby = [[NearbyUserViewController alloc]init];
    nearby.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nearby animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
