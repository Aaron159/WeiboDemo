//
//  ThemeLabel.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/1.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "ThemeLabel.h"

@implementation ThemeLabel


//More_Item_Text_color

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

    //获取当前主题下的颜色
    UIColor *color = [[ThemeManager shareManage] themeColorWithName:_colorName];
    
    //设置颜色
    self.textColor = color;
}


//刷新颜色
- (void)setColorName:(NSString *)colorName {
    _colorName = [colorName copy];
    
    [self themeChanged];
}

@end
