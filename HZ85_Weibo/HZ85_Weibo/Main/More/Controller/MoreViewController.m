//
//  MoreViewController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/29.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "MoreViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "AppDelegate.h"
@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet ThemeImageView *icon1;
@property (weak, nonatomic) IBOutlet ThemeImageView *icon2;
@property (weak, nonatomic) IBOutlet ThemeImageView *icon3;
@property (weak, nonatomic) IBOutlet ThemeImageView *icon4;
@property (weak, nonatomic) IBOutlet ThemeLabel *themeNameLabel;   //当前主题名
@property (weak, nonatomic) IBOutlet ThemeLabel *label1;
@property (weak, nonatomic) IBOutlet ThemeLabel *label2;
@property (weak, nonatomic) IBOutlet ThemeLabel *label3;
@property (weak, nonatomic) IBOutlet ThemeLabel *label4;
@property (weak, nonatomic) IBOutlet ThemeLabel *cacheLabel;

@end

@implementation MoreViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置主题背景
    //创建一个图片视图，来实现背景图片切换
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"bg_detail.jpg";
    
    [self.view insertSubview:bgImageView atIndex:0];
    
    
    
    //标题图片名
    _icon1.imageName = @"more_icon_theme.png";
    _icon2.imageName = @"more_icon_account.png";
    _icon3.imageName = @"more_icon_draft.png";
    _icon4.imageName = @"more_icon_feedback.png";
    
    //设置文本颜色
    _themeNameLabel.colorName = kMoreItemTextColor;
    _label1.colorName = kMoreItemTextColor;
    _label2.colorName = kMoreItemTextColor;
    _label3.colorName = kMoreItemTextColor;
    _label4.colorName = kMoreItemTextColor;
    _cacheLabel.colorName = kMoreItemTextColor;
    
    [self createButtons];
}
-(void)createButtons {
    if (self.navigationController.viewControllers.count ==1) {
        ThemeButton *setButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
        setButton.frame = CGRectMake(0, 0, 60, 44);
        //按钮的背景图片
        setButton.backgroundImageName = @"titlebar_button_9.png";
        [setButton setTitle:@"设置" forState:UIControlStateNormal];
        [setButton addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
        
//        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:setButton];
       MMDrawerBarButtonItem *item = [[MMDrawerBarButtonItem alloc]initWithCustomView:setButton];
        
        self.navigationItem.leftBarButtonItem = item;
    }

}
-(void)leftAction {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma 清理缓存操作
//界面即将显示时
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ThemeManager *manager = [ThemeManager shareManage];
    
    _themeNameLabel.text = manager.currentThemeName;
    
    NSString *name =manager.currentThemeName;
    _cacheLabel.text = name;
    
    //找到缓存数据-》 计算大小 -》清除缓存
    [self  readCacheSize];
}
- (void)clearCache
{
    //    [[SDImageCache sharedImageCache] clearDisk];
    NSString *cache = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    [[NSFileManager defaultManager] removeItemAtPath:cache error:NULL];
}

- (void)readCacheSize
{
    NSUInteger size = [self getCacheData];
    
    double mbSize = size / 1024.0 / 1024.0;
    _cacheLabel.text = [NSString stringWithFormat:@"%.2f MB", mbSize];
}

- (NSUInteger )getCacheData
{
    //找到缓存路径
    NSUInteger size = 0;
    //1、简单方法
    //    NSUInteger size = [[SDImageCache sharedImageCache] getSize];
    //找到缓存路径
    NSString *cache = [NSHomeDirectory()  stringByAppendingPathComponent:@"Library/Caches"];
    //文件枚举 获取当前路径下的所有文件的属性
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:cache];
    //拿到文件夹里面的所有文件
    for (NSString   *fileName in fileEnumerator) {
        //获取所有文件路径
        NSString *filePath = [cache stringByAppendingPathComponent:fileName];
        //获取所有文件的属性
        NSDictionary *dic = [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:NULL];
        //计算每个文件的大小
        //计算总共文件的大小
        size += [dic fileSize];
    }
    
    return size;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1 && indexPath.row == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清除缓存" message:[NSString stringWithFormat:@"确定清除缓存%@", self.cacheLabel.text] preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self clearCache];
            [self readCacheSize];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
        
        [self presentViewController:alert animated:YES completion:NULL];
    }else if (indexPath.section == 2 && indexPath.row == 0){
        //获取AppDelegate
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate logoutWeibo];
    }

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
