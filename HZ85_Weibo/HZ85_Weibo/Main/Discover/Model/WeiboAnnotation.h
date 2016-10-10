//
//  WeiboAnnotation.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/9/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface WeiboAnnotation : NSObject<MKAnnotation>
//表示标注视图在地图中的位置
//这个属性，一般不会手动读取，而是在MapView中，自动读取这个属性来设置标注视图的位置
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

//可选的
@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

//微博对象
@property (nonatomic,strong, nullable) WeiboModel *weiboModel;
//nullable 可以为空 nonnull 不可以为空
@end
