//
//  ThemeImageView.h
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/30.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeImageView : UIImageView

//图片名
@property (nonatomic, copy) NSString *imageName;

//用于拉伸的坐标参数
@property (nonatomic, assign)CGFloat leftCapWidth;
@property (nonatomic, assign)CGFloat topCapHeight;
@end
