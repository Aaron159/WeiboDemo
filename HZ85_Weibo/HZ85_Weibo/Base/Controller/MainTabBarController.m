//
//  MainTabBarController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/29.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()
{
    ThemeImageView *_arrowImageView;
}
@end

@implementation MainTabBarController

/*
 1.子视图控制器的读取和创建
 2.标签栏的自定义操作
 */

#pragma mark - 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        [self createSubViewController];
        
        [self customTabBar];
    }
    
    return self;
}


//创建子控制器
- (void)createSubViewController {
    
    //读取五个故事版，获取视图控制器
    NSArray *storyboardNames = @[@"Home",
                                 @"Message",
                                 @"Discover",
                                 @"Profile",
                                 @"More"];
    
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    
    //遍历所有的StoryBoard，获取视图控制器
    for (NSString *sbName in storyboardNames) {
        //读取故事版
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:sbName bundle:[NSBundle mainBundle]];
        //导航控制器
        UINavigationController *navi = [storyboard instantiateInitialViewController];
        
        //将读取到的视图控制器，添加到viewControllers数组中
        [mArray addObject:navi];
    }
    
    self.viewControllers = [mArray copy];
    
    
}
//自定义标签栏按钮
- (void)customTabBar {
    
    //设置标签栏背景
//    self.tabBar.backgroundImage = [UIImage imageNamed:@"Skins/bluemoon/mask_navbar.png"];
    
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:CGRectMake(0, -5, kScreenWidth, 54)];
    bgImageView.imageName = @"mask_navbar.png";
    [self.tabBar insertSubview:bgImageView atIndex:0];
    
    
    //删除原有按钮
    //获取标签栏的子视图
    for (UIView *subView in self.tabBar.subviews) {
        //判断获取到的子视图，是否是标签栏上面的按钮
        //UITabBarButton
        //NSLog(@"%@", subView);
        Class buttonClass = NSClassFromString(@"UITabBarButton");
        if ([subView isKindOfClass:buttonClass]) {
            //视图是UITabBarButton
            [subView removeFromSuperview];
        }
    }
    
    //按钮宽度 = 屏幕宽度/5
    CGFloat buttonWidth = kScreenWidth / 5;
    
    //自定义添加按钮  home_tab_icon_5.png
    //循环创建五个按钮
    for (int i = 0; i < 5; i++) {
        
        ThemeButton *button = [ThemeButton buttonWithType:UIButtonTypeCustom];
        //计算frame
        CGRect frame = CGRectMake(buttonWidth * i, 0, buttonWidth, 49);
        button.frame = frame;
        
        //设置图片
        NSString *imageName = [NSString stringWithFormat:@"home_tab_icon_%i.png", i + 1];
        button.imageName = imageName;
        
        [self.tabBar addSubview: button];
        
        button.tag = i;
        //实现点击按钮，页面切换
        [button addTarget:self action:@selector(tabBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //选中框
    _arrowImageView = [[ThemeImageView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 49)];
    _arrowImageView.imageName = @"home_bottom_tab_arrow.png";
    [self.tabBar insertSubview:_arrowImageView atIndex:1];
    
    //标签栏的阴影
    self.tabBar.shadowImage = [[UIImage alloc] init];
    
}


- (void)tabBarButtonAction:(UIButton *)button {
    self.selectedIndex = button.tag;
    
    [UIView animateWithDuration:0.3 animations:^{
        _arrowImageView.center = button.center;
    }];
}


#pragma mark -



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
