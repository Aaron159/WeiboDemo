//
//  LocationViewController.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/8/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreLocation/CoreLocation.h> //定位用到的类
#import "AppDelegate.h"
#define kLocationNearbyAPI @"place/nearby/pois.json"

@interface LocationViewController ()<CLLocationManagerDelegate,SinaWeiboRequestDelegate,UITableViewDelegate,UITableViewDataSource>
{
    CLLocationManager *_locationManager;
    NSMutableArray *_locationArray;
    UITableView *_tableView;
}
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"周边地点";
    [self startLoaction];
    [self createTableView];
    
    NSDictionary *d = @{@"title" : @"中国计量大学",
                        @"address" : @"学院街258号",
                        @"icon" :@"http://h.hiphotos.baidu.com/zhidao/pic/item/b7fd5266d01609240c53a679d20735fae6cd3459.jpg",
                        @"lon": @"120.0",
                        @"lat": @"30.0"};
    NSDictionary *d1 = @{@"title" : @"弗雷德广场",
                        @"address" : @"艾肯金座2314",
                         @"icon" :@"http://h.hiphotos.baidu.com/zhidao/pic/item/b7fd5266d01609240c53a679d20735fae6cd3459.jpg",
                         @"lon": @"+50.0",
                         @"lat": @"+50.0"};
    _locationArray = [NSMutableArray array];
    [_locationArray addObject:d];
    [_locationArray addObject:d1];
}

//开启定位服务
-(void)startLoaction {
    //获取位置管理器
    _locationManager = [[CLLocationManager alloc] init];
    
    //在IOS8之后 需要来设置定位的服务类型 始终/在程序运行时
    //NSLocationAlwaysUsageDescription或者NSLocationWhenInUseUsageDescription
    //将需要使用的类型,添加到Plist文件中，然后在后面字段中写上提示语
    
    //请求定位权限
    if (kSystemVersion >= 8.0) {
        //请求在程序使用期间的定位权限
        [_locationManager requestWhenInUseAuthorization];
    }
    //设定定位的精准度
    //精准度越高 耗电量越高  根据程序的需求情况，选择合适的精准度
    /*
     kCLLocationAccuracyBest;                //最高精准度
     kCLLocationAccuracyNearestTenMeters;    //10米
     kCLLocationAccuracyHundredMeters;       //100米
     kCLLocationAccuracyKilometer;           //1000米
     kCLLocationAccuracyThreeKilometers;     //3000米
     */
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //设置代理获取结果
    _locationManager.delegate = self;
    
    //开启定位
    [_locationManager startUpdatingLocation];
    
}

#pragma mark - CLLocationManagerDelegate
//在获取到最新的位置信息时 调用
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
//    NSLog(@"%@", locations);
    //当获取到位置信息后，关闭定位
    [manager stopUpdatingLocation];
    
    //获取当前的位置经纬度
    CLLocation *location = [locations firstObject];
    //经度
    double lon = location.coordinate.longitude;
    //纬度
    double lat = location.coordinate.latitude;
    
//    NSLog(@"经度%f,纬度%f",lon ,lat);
    
    //获取当前位置附近的地理信息（地点）
    //地理位置反编码 经纬度坐标信息 --> 实际的地点名称
    //新浪微博的地理信息接口
    //发起网络请求，获取
    SinaWeibo *wb = kSinaWeiboObject;
    
    NSDictionary *dic = @{@"long" : [NSString stringWithFormat:@"%f",lon],
                          @"lat" : [NSString stringWithFormat:@"%f",lat] };
    
    [wb requestWithURL:kLocationNearbyAPI params:[dic mutableCopy] httpMethod:@"GET" delegate:self];
}
//获取附近的地点信息
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result{

//    NSLog(@"%@",result);
    //保存地点信息
    [_locationArray addObjectsFromArray:result[@"pois"]];;
    
    //刷新表视图
    [_tableView reloadData];
}

#pragma mark - UITableView

-(void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight- 64)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _locationArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    //填充数据
    NSDictionary *dic = _locationArray[indexPath.row];
    //地点名称
    cell.textLabel.text = dic[@"title"];
    //地址
    if (![dic[@"address"] isKindOfClass:[NSNull class]]) {
        cell.detailTextLabel.text = dic[@"address"];
    }
    //图标
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:dic[@"icon"]]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //点击一个单元格时
    //1.回传被选中的地理信息
    if (_block) {
        _block(_locationArray[indexPath.row]);
    }
    //2.关闭定位界面
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)addLocationResultBlock:(LocationResultBlock)block{
   _block = [block copy];
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
