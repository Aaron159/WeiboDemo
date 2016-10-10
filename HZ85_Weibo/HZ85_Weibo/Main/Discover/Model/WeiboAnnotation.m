//
//  WeiboAnnotation.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/9/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "WeiboAnnotation.h"

@implementation WeiboAnnotation

-(void)setWeiboModel:(WeiboModel *)weiboModel {
    _weiboModel = weiboModel;
    
    //从微博对象中 获取地理位置信息 填充到 coordinate中
    NSDictionary *geo = _weiboModel.geo;
//    NSLog(@"%@",geo);
    //获取经纬度坐标点
    NSArray *coordinates = geo[@"coordinates"];
    if (coordinates.count == 2) {
        //纬度
        double lat = [[coordinates firstObject] doubleValue];
        //经度
        double lon = [[coordinates lastObject] doubleValue];
        
        _coordinate = CLLocationCoordinate2DMake(lat, lon);
    }
    
}

@end
