//
//  BaseNavigationController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/29.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //监听通知，切换主题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedTheme) name:kThemeChangedNotificationName object:nil];
    
//    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
//    
//    //设置背景图片
//    //mask_titlebar.png -- mask_titlebar64.png
//    //手机系统版本判断
//    if (kSystemVersion >= 7.0) {
//        //使用高度为64的图片
////        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"Skins/bluemoon/mask_titlebar64.png"] forBarMetrics:UIBarMetricsDefault];
//        bgImageView.imageName = @"mask_titlebar64.png";
//        bgImageView.frame = CGRectMake(0, -20, kScreenWidth, 64);
//        
//    } else {
//        //使用高度为44的图片
//        bgImageView.imageName = @"mask_titlebar.png";
//        bgImageView.frame = CGRectMake(0, 0, kScreenWidth, 44);
////        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"Skins/bluemoon/mask_titlebar.png"] forBarMetrics:UIBarMetricsDefault];
//    }
//    [self.navigationBar insertSubview:bgImageView atIndex:1];
////    NSLog(@"%@", self.navigationBar.subviews);
    
    
    
    //设置标题字体/颜色
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationBar.titleTextAttributes = attributes;
    //将导航栏设置为不透明  会影响每一个视图的布局
    self.navigationBar.translucent = NO;
    
    [self changedTheme];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changedTheme {
    
    //获取背景图片
    NSString *imageName;
    if (kSystemVersion >= 7) {
        imageName = @"mask_titlebar64.png";
    } else {
        imageName = @"mask_titlebar.png";
    }
    
    UIImage *image = [[ThemeManager shareManage] themeImageWithName:imageName];
    
    //设置导航栏背景
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
}


//状态栏字体颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
