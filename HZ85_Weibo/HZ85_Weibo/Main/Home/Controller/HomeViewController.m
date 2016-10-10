//
//  HomeViewController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/29.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "ThemeImageView.h"
#import "WeiboModel.h"
#import "YYModel.h"
#import "UserModel.h"
#import "WeiboCell.h"
#import "WeiboCellLayout.h"
#import "WXRefresh.h"

#import <AVFoundation/AVFoundation.h>
@class WeiboModel;
@class WeiboCellLayout;

//获取首页微博接口
#define kGetTimeLineWeiboAPI @"statuses/home_timeline.json"

@interface HomeViewController () <SinaWeiboRequestDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_table;
    NSMutableArray *_weiboArray;
    ThemeImageView *_newWeiboCountView;
    ThemeLabel *_newWeiboCountLabel;
    
    //提示音ID
    SystemSoundID _msgcomeID;
}
@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadWeiboData];
    [self createTableView];
    
    //注册系统声音
    //获取声音文件路径 NSURL
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"msgcome" withExtension:@"wav"];
    //注册
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL,&_msgcomeID);
    
    [self createButtons];
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadNewWeibo) name:kHomeViewController object:nil];
    
}
-(void)createButtons {
    if (self.navigationController.viewControllers.count ==1) {
        ThemeButton *setButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
        setButton.frame = CGRectMake(0, 0, 60, 44);
        //按钮的背景图片
        setButton.backgroundImageName = @"titlebar_button_9.png";
        [setButton setTitle:@"置顶" forState:UIControlStateNormal];
        [setButton addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:setButton];
        
        self.navigationItem.rightBarButtonItem = item;
    }
    
}
- (void)rightAction {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_table scrollToRowAtIndexPath:indexPath
                            atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //注销系统声音
    AudioServicesRemoveSystemSoundCompletion(_msgcomeID);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 加载微博数据
- (void)loadWeiboData {
    //发起网络请求
    //1.获取微博对象
    SinaWeibo *weibo = kSinaWeiboObject;
    //2.判断当前的登陆状态是否有效
    if (![weibo isAuthValid]) {
        [weibo logIn];
        return;
    }
    NSDictionary *params = @{@"count" : @"30"};
    
    //3.发起网络请求
    SinaWeiboRequest *request =  [weibo requestWithURL:kGetTimeLineWeiboAPI    //接口名，URL地址的后半段
                   params:[params mutableCopy]
               httpMethod:@"GET"
                 delegate:self];
    request.tag = 0;
    //设置请求标记 0:第一次请求数据 1：下拉刷新 2：上拉刷新
    
}

#pragma mark - 网络请求完毕，接收到结果
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
    //NSLog(@"result = %@", result);
    //微博数组
    NSArray *array = result[@"statuses"];
    
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    
    //遍历数组
    for (NSDictionary *dic in array) {
        //创建微博对象
        WeiboModel *weiboModel = [WeiboModel yy_modelWithJSON:dic];
        
        [mArray addObject:weiboModel];
//       NSLog(@"%@:%@", weiboModel.user.name, weiboModel.text);
    }
    
    //--------判断状态---------
    if (request.tag == 0) {
        //第一次加载
        _weiboArray = [mArray mutableCopy];
    }else if (request.tag == 1){
        //下拉
        //将mArray中的内容,插入到最前面
        if (mArray.count == 0) {
            [_table.pullToRefreshView stopAnimating];
            [self showNewWeiboCount:0];
            return;
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, mArray.count)];
        [_weiboArray insertObjects:mArray atIndexes:indexSet];
        [_table.pullToRefreshView stopAnimating];
        [self showNewWeiboCount:mArray.count];
    }else if (request.tag == 2){
        //上拉
        //将mArray中的内容,插入到最前面
        if (mArray.count == 0) {
            [_table.infiniteScrollingView stopAnimating];
            return;
        }
//方法错误，插入到最后应该是添加
//（方法错误，插入到最后应该是添加）NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_weiboArray.count];
        [_weiboArray addObjectsFromArray:mArray];
        [_table.infiniteScrollingView stopAnimating];
    }
    
    //刷新表视图
    [_table reloadData];
    
}

#pragma mark - 创建表视图
- (void)createTableView {
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 49) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    _table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_table];
    
    
    //注册单元格
    UINib *nib = [UINib nibWithNibName:@"WeiboCell" bundle:[NSBundle mainBundle]];
    [_table registerNib:nib forCellReuseIdentifier:@"WeiboCell"];
    
    //使用weak类型的指针,来解决Block中的循环引用
    __weak HomeViewController *weakSelf = self;
    
    //添加下拉刷新
    [_table addPullDownRefreshBlock:^{
        __strong HomeViewController *strongSelf = weakSelf;
        //三者之间循环引用 不能用[self loadNewData];
        [strongSelf loadNewData];
    }];
    
    //上拉 加载更多
    [_table addInfiniteScrollingWithActionHandler:^{
        __strong HomeViewController *strongSelf = weakSelf;
        //三者之间循环引用 不能用[self loadNewData];
        [strongSelf loadMoreData];
    }];
    
    //创建新微博提示视图
    _newWeiboCountView = [[ThemeImageView alloc] initWithFrame:CGRectMake(3, 3, kScreenWidth - 6, 40)];
    _newWeiboCountView.imageName = @"timeline_notify.png";
    //改变frame 不如改变 y值
    _newWeiboCountView.transform = CGAffineTransformMakeTranslation(0, -60);
    [self.view addSubview:_newWeiboCountView];
    
    //文本显示Label
    _newWeiboCountLabel = [[ThemeLabel alloc]initWithFrame:_newWeiboCountView.bounds];
    _newWeiboCountLabel.colorName = kHomeUserNameTextColor;
    _newWeiboCountLabel.text = @"8条微博已经刷新";
    _newWeiboCountLabel.textAlignment = NSTextAlignmentCenter;
    [_newWeiboCountView addSubview:_newWeiboCountLabel];
    
    
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  _weiboArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiboCell"];
    //填充微博数据
    WeiboModel *wb = _weiboArray[indexPath.row];
//    UserModel *user = wb.user;
    
    [cell setWeibo:wb];
    
    
    return cell;
}

//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取微博对象
    WeiboModel *wb = _weiboArray[indexPath.row];
    //根据正文高度计算总高度
//    //根据文本数量，计算文本高度
//    NSDictionary *attributes = @{NSFontAttributeName : kWeiboTextFont};
//    CGRect rect = [wb.text boundingRectWithSize:CGSizeMake(kScreenWidth - 20, 1000)
//                                            options:NSStringDrawingUsesLineFragmentOrigin
//                                         attributes:attributes
//                                            context:nil];
//    CGFloat height = rect.size.height;
//    
//    CGFloat imageHeight = wb.bmiddle_pic ? 210 : 0;
//    
    
    
    //创建布局对象
    WeiboCellLayout *layout = [WeiboCellLayout layoutWithWeiboModel:wb];
    //获取高度
    return [layout cellHeight];
}

#pragma mark - 加载更多数据，刷新 (上拉 和 下拉)

-(void)loadNewData {
//    NSLog(@"下拉刷新 最新微博");
    //请求网络数据，获取比当前微博列表中，第一条微博更晚的微博
    WeiboModel *firstWeibo = [_weiboArray firstObject];
    //获取第一条微博的id
    NSString *idStr = firstWeibo.idstr;
    
    //发起网络请求
    //1.获取微博对象
    SinaWeibo *weibo = kSinaWeiboObject;
    //2.判断当前的登陆状态是否有效
    if (![weibo isAuthValid]) {
        [weibo logIn];
        return;
    }
    NSDictionary *params = @{@"count" : @"30",
                             @"since_id" : idStr};
   SinaWeiboRequest *request =  [weibo requestWithURL:kGetTimeLineWeiboAPI
                   params:[params mutableCopy]
               httpMethod:@"GET"
                 delegate:self];
    request.tag = 1;
    
    [_table.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2];

}

-(void)loadMoreData {
    //    NSLog(@"上拉刷新 更多微博");
    WeiboModel *lastWeibo = [_weiboArray lastObject];
    //获取第一条微博的id
    NSString *idStr = lastWeibo.idstr;
    
    //发起网络请求
    //1.获取微博对象
    SinaWeibo *weibo = kSinaWeiboObject;
    //2.判断当前的登陆状态是否有效
    if (![weibo isAuthValid]) {
        [weibo logIn];
        return;
    }
    NSDictionary *params = @{@"count" : @"30",
                             @"max_id" : idStr};
    SinaWeiboRequest *request = [weibo requestWithURL:kGetTimeLineWeiboAPI
                                                params:[params mutableCopy]
                                            httpMethod:@"GET"
                                              delegate:self];
    request.tag =2;
    [_table.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2];
}

#pragma mark - 微博数量显示
-(void)showNewWeiboCount:(NSInteger)count {
    //设置文本显示的条数
    if (count ==0) {
        _newWeiboCountLabel.text = @"没有新微博";
    }else {
        _newWeiboCountLabel.text = [NSString stringWithFormat:@"%li条新微博",count];
    }
    //播放动画效果
    [UIView animateWithDuration:0.5 animations:^{
        _newWeiboCountView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
           //播放提示音
           AudioServicesPlaySystemSound(_msgcomeID);
            //延迟两秒,再次动画
            [UIView animateWithDuration:0.5 delay:2 options:UIViewAnimationOptionLayoutSubviews animations:^{
                _newWeiboCountView.transform = CGAffineTransformMakeTranslation(0, -60);
            } completion:nil];
    }];
}

#pragma mark - 刷新微博 
-(void)reloadNewWeibo {
    NSLog(@"刷新微博");
    //播放下拉刷新动画
    [_table.pullToRefreshView startAnimating];
    //调用下拉刷新方法
    [self loadNewData];
}
@end
