//
//  NearbyUserViewController.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/9/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

/*
 1.创建地图显示视图
 2.获取当前用户位置
 3,将用户位置发给服务器,获取附近的用户的微博
 4.显示在地图中
 */

#import "NearbyUserViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "YYModel.h"
#import "WeiboAnnotation.h"
#import "WeiboAnnotationView.h"
#define kNearbyWeiboAPI @"place/nearby_timeline.json"

@interface NearbyUserViewController()<MKMapViewDelegate,SinaWeiboRequestDelegate>
{
    MKMapView *_mapView;
    BOOL _isLocation;
}

@end

@implementation NearbyUserViewController

-(void)viewDidLoad {
    [super viewDidLoad];
     _isLocation = NO;
    [self createMapView];
}

-(void)createMapView {
   
    //在ios8以上版本，需要获取定位权限
    if (kSystemVersion > 8.0) {
        [[[CLLocationManager alloc]init] requestWhenInUseAuthorization];
    }
    
    //创建地图视图
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    //显示当前用户位置，设置为YES自动进行定位
    _mapView.showsUserLocation = YES;
    //获取用户位置 代理
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];

}
//刷新了用户位置
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    NSLog(@"%@",userLocation);
    //1、调整地图显示的范围
    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
    //获取经纬度
    double lat = coordinate.latitude;
    double lon = coordinate.longitude;
    
    //显示范围
    //地图显示的大小，单位为经纬度的1度
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    //创建区域对象
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    //设定显示区域
    [_mapView setRegion:region animated:YES];
    
    //判断是否是第一次进行定位，只有在第一次定位时，才来请求附近的微博
    if (_isLocation == NO) {
        _isLocation = YES;
        //2.发送请求，获取附近的微博
        SinaWeibo *wb = kSinaWeiboObject;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
        [params setObject:[NSString stringWithFormat:@"%f", lon] forKey:@"long"];
        
        [wb requestWithURL:kNearbyWeiboAPI params:params httpMethod:@"GET" delegate:self];
    }
    
}

//获取附近微博信息
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result{
//    NSLog(@"%@",result);
    NSArray *array = result[@"statuses"];
    //遍历数组，构造微博对象
    for (NSDictionary *dic in array) {
        WeiboModel *model = [WeiboModel yy_modelWithJSON:dic];
//        NSLog(@"%@",model);
        //创建标注点
        WeiboAnnotation *annotation = [[WeiboAnnotation alloc] init];
        annotation.weiboModel = model;
        //在地图中添加标注点
        [_mapView addAnnotation:annotation];
    }
}

//自定义标注视图(根tableviewcell for index 差不多原理 model - cell - controller=Annotation - MKAnnotationView - Controller)
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  
    //当前用户位置点，也是一个标注视图
    //当前用户位置点不需要自定义标注，所以返回nil，让系统来标注
//    NSLog(@"%@",annotation);
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    //从复用池中 获取标注视图
    WeiboAnnotationView *view = (WeiboAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"WeiboAnnotationView"];
    if (view == nil) {
        view = [[WeiboAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"WeiboAnnotationView"];
    }

    return view;
}


@end
