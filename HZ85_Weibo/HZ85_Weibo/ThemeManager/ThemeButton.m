//
//  ThemeButton.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/30.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "ThemeButton.h"

@implementation ThemeButton


//监听通知
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotificationName object:nil];
        
    }
    return self;
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotificationName object:nil];
}
//移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//改变主题
- (void)themeChanged {
    
    //获取图片
    UIImage *image = [[ThemeManager shareManage] themeImageWithName:_imageName];
    UIImage *bgImage = [[ThemeManager shareManage] themeImageWithName:_backgroundImageName];
    
    //更新图片
    [self setImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    
}

//改变图片名
- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    [self themeChanged];
}

- (void)setBackgroundImageName:(NSString *)backgroundImageName {
    _backgroundImageName = backgroundImageName;
    [self themeChanged];
}

@end
