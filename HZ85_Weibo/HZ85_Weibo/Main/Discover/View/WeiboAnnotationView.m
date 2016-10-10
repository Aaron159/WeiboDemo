//
//  WeiboAnnotationView.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/10/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "WeiboAnnotationView.h"
#import "WeiboAnnotation.h"
@implementation WeiboAnnotationView

//为了进行视图内容的自定义，需要来复写初始化方法

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
   
    self  = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
//        NSLog(@"创建标注视图成功");
        [self createSubViews];
    }
   
    return self;
}

-(void)createSubViews {
    //背景图片
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    bgImageView.image = [UIImage imageNamed:@"nearby_map_people_bg.png"];
    [self addSubview:bgImageView];
    
    //头像视图
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 50, 50)];
    userImageView.backgroundColor =[UIColor orangeColor];
    userImageView.layer.cornerRadius = 3;
    userImageView.userInteractionEnabled = YES;
    [bgImageView addSubview:userImageView];
    
    //默认（0，0）是不变的点
    //改变背景视图位置，使得背景视图的底边中点对准左上角点
    //使得底边中点的位置为（0，0）
    bgImageView.frame = CGRectMake(-35, -70, 70, 70);
    
    //设置头像
    //获取标注对象
    WeiboAnnotation *annotation = self.annotation;
    //获取WeiboModel
    WeiboModel *model = annotation.weiboModel;
    //获取用户头像地址
    NSURL *url  = model.user.profile_image_url;
    
    [userImageView sd_setImageWithURL:url];
}

@end
