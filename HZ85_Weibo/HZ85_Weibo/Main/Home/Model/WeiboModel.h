//
//  WeiboModel.h
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/2.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

/*
 YYModel的使用
 1.创建Model类，继承与NSObject
 2.定义Model类中的属性，尽量使类中的属性名，和Json中的Key保持一致
 3.对于属性名和Key不相同的属性，需要复写 modelCustomPropertyMapper 来建立关联关系
 4.添加YYModel的第三方框架，并且在需要使用的地方加入YYModel.h
 5.使用 yy_modelWithJSON: 方法来创建对象，能够自动的填充所有数据。
 */


#import <Foundation/Foundation.h>
@class UserModel;


@interface WeiboModel :         NSObject
@property (copy, nonatomic)     NSString    *source;            //微博来源
@property (copy, nonatomic)     NSString    *created_at;        //发布时间
@property (copy, nonatomic)     NSString    *idstr;             //微博编号
@property (copy, nonatomic)     NSString    *text;              //微博文本
@property (assign, nonatomic)   NSInteger   reposts_count;      //转发数
@property (assign, nonatomic)   NSInteger   comments_count;     //评论数
@property (assign, nonatomic)   NSInteger   attitudes_count;    //点赞数
@property (strong, nonatomic)   UserModel   *user;              //发微博的用户
@property (strong, nonatomic)   WeiboModel  *retweeted_status;  //被转发的微博
@property (copy, nonatomic)     NSURL       *thumbnail_pic;     //缩略图片地址
@property (copy, nonatomic)     NSURL       *bmiddle_pic;       //中等尺寸图片地址
@property (copy, nonatomic)     NSURL       *original_pic;      //原始图片地址
@property (copy, nonatomic)     NSArray     *pic_urls;          //多图地址

@property (copy,nonatomic) NSDictionary *geo;//位置信息




@end
