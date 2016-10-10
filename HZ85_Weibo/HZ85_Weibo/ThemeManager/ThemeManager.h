//
//  ThemeManager.h
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/30.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ThemeImageView.h"
#import "ThemeButton.h"
#import "ThemeLabel.h"

@interface ThemeManager : NSObject

@property (nonatomic, copy) NSString *currentThemeName; //当前的主题名字
@property (nonatomic, copy) NSDictionary *allThemes;    //所有的可用主题
@property (nonatomic, copy) NSDictionary *colorConfigDic;//颜色字典


//获取单例类
+ (ThemeManager *)shareManage;

//获取图片
- (UIImage *)themeImageWithName:(NSString *)imageName;

//获取颜色
- (UIColor *)themeColorWithName:(NSString *)colorName;


@end
