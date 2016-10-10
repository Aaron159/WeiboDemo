//
//  BaseViewController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/29.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置主题背景
//    self.view.backgroundColor = [UIColor colorWithPatternImage:<#(nonnull UIImage *)#>];
    //创建一个图片视图，来实现背景图片切换
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"bg_detail.jpg";
    
    [self.view insertSubview:bgImageView atIndex:0];
    
    [self createBackButton];
    
    
}

- (void)createBackButton {
    
    //判断导航控制器的栈中 是否有超过一个视图控制器
    if (self.navigationController.viewControllers.count >= 2) {
        ThemeButton *backButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 60, 44);
        //按钮的背景图片
        backButton.backgroundImageName = @"titlebar_button_back_9.png";
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.navigationItem.leftBarButtonItem = item;
    }
    
    
}


- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
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
