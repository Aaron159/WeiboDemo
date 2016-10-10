//
//  ThemeImageView.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/30.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "ThemeImageView.h"

@implementation ThemeImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.leftCapWidth = 0;
        self.topCapHeight = 0;
        //监听主题改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChange) name:kThemeChangedNotificationName object:nil];
    }
    
    return self;
}

- (void)awakeFromNib {
    self.leftCapWidth = 0;
    self.topCapHeight = 0;
    //监听主题改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChange) name:kThemeChangedNotificationName object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setImageName:(NSString *)imageName {
    _imageName = [imageName copy];
    [self themeChange];
}

//当主题发生改变时，刷新当前显示的图片
- (void)themeChange {
    //获取当前视图，在当前主题下的图片
    // Skins/主题文件夹/图片名
    
    //获取manager对象
    ThemeManager *manager = [ThemeManager shareManage];
    
    //从管理器中，获取相对应的图片
    UIImage *image = [manager themeImageWithName:self.imageName];
    
    //对图片进行拉伸
    image = [image stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
    
    self.image = image;
}

//重新设置拉伸点时，刷新图片
-(void)setLeftCapWidth:(CGFloat)leftCapWidth {
    _leftCapWidth = leftCapWidth;
    [self themeChange];
}
-(void)setTopCapHeight:(CGFloat)topCapHeight {
    _topCapHeight = topCapHeight;
    [self themeChange];
}
@end
