//
//  LeftViewController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/1.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
    NSArray *_arr;
    NSInteger _selectIndex;
}
@end

@implementation LeftViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"设置";
    
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"mask_bg.jpg";
    
    [self.view insertSubview:bgImageView atIndex:0];
    
    [self createTabel];
    
}

-(void)createTabel {
   
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 180, kScreenHeight-64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_table];
    _table.rowHeight = 50;

    _arr = @[@"无",@"滑动",@"滑动&缩放",@"3D旋转",@"视差滑动"];
    _selectIndex = 1;
}

#pragma mark - table的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"LeftCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LeftCell" owner:self options:nil]lastObject];
        cell.backgroundColor = [UIColor clearColor];
    }
    ThemeImageView *image = (ThemeImageView *)[cell viewWithTag:101];
    ThemeLabel *label = (ThemeLabel *)[cell viewWithTag:102];
    label.font = kWeiboTextFont;
    label.text = _arr[indexPath.row];
    label.colorName = kLinkColor;
    image.imageName =@"avatar_default.png";
    
    if (indexPath.row == _selectIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
       cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    _selectIndex = indexPath.row;
    [_table reloadData];
    
    //maanager
    MMExampleDrawerVisualStateManager *manager = [MMExampleDrawerVisualStateManager sharedManager];
    //改变滑动样式
    manager.leftDrawerAnimationType = indexPath.row;
    manager.rightDrawerAnimationType = indexPath.row;
    
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
