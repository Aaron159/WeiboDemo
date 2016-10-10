//
//  ThemeSelectController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/30.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "ThemeSelectController.h"

@interface ThemeSelectController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_table;
    UIColor *_textColor;
}
@end

@implementation ThemeSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor purpleColor];
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64) style:UITableViewStylePlain];
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    _table.dataSource = self;
    _table.delegate = self;
    
    //监听主题改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotificationName object:nil];
    
    
}

//主题改变
- (void)themeChanged {
    //获取字体颜色
    _textColor = [[ThemeManager shareManage] themeColorWithName:kMoreItemTextColor];
    //刷新单元格
    [_table reloadData];
    
    
    //切换分割线颜色
    _table.separatorColor = [[ThemeManager shareManage] themeColorWithName:kMoreItemLineColor];
}

-(void)viewWillAppear:(BOOL)animated {

    _textColor = [[ThemeManager shareManage] themeColorWithName:kMoreItemTextColor];
    [_table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ThemeManager shareManage].allThemes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemeManager *manager = [ThemeManager shareManage];
    NSDictionary *allThemes = manager.allThemes;
    //获取所有主题的主题名
    NSArray *allNames = allThemes.allKeys;
    //创建单元格
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    NSString *key = allNames[indexPath.row];
    cell.textLabel.text = key;
    //刷新单元格颜色
    cell.textLabel.textColor = _textColor;
    
    //图片
    //more_icon_theme.png
    NSString *imageName = [NSString stringWithFormat:@"%@/%@", allThemes[key], @"more_icon_theme.png"];
    UIImage *image = [UIImage imageNamed:imageName];
    cell.imageView.image = image;
    
    
    //如果当前单元格，是被选中的主题，则打勾
    if ([key isEqualToString:manager.currentThemeName]) {
        //打勾
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //设置当前显示的主题为，点中的主题
    //1.获取所有的主题数组
    ThemeManager *manager = [ThemeManager shareManage];
    NSDictionary *allThemes = manager.allThemes;
    //获取所有主题的主题名
    NSArray *allNames = allThemes.allKeys;

    //2.从数组中，拿到所对应的主题名字
    NSString *selectTheme = allNames[indexPath.row];
    
    //3.设定
    manager.currentThemeName = selectTheme;
    
    //刷新表视图
    [_table reloadData];
    
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
