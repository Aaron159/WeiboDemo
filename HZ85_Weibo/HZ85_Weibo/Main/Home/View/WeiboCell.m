//
//  WeiboCell.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/2.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "WeiboCell.h"
#import "GDataXMLNode.h"
#import "WeiboCellLayout.h"
#import "WXLabel.h"
#import "RegexKitLite.h"
#import "WeiboWebViewController.h"
#import "UserViewController.h"
#import "WXPhotoBrowser.h"
@class WeiboCellLayout;

@interface WeiboCell ()<WXLabelDelegate,PhotoBrowerDelegate>{
    
}
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet ThemeLabel *nameLabel;
@property (weak, nonatomic) IBOutlet ThemeLabel *timeLaebl;
@property (weak, nonatomic) IBOutlet ThemeLabel *sourceLabel;

//要计算文字的高度什么的，所以不能用xib来做
@property (strong, nonatomic) WXLabel *weiboTextLabel;
//@property (strong, nonatomic) UIImageView *weiboImageView;
@property (strong, nonatomic) WXLabel *reWeiboTextlabel; //转发微博的正文
@property (strong, nonatomic) ThemeImageView *reWeiboBGImageView;   //转发微博的背景
@property (strong, nonatomic) NSArray *imageArray;
@end

@implementation WeiboCell


- (void)setWeibo:(WeiboModel *)weibo {
    _weibo = weibo;
    
    _nameLabel.text = _weibo.user.name;
    _timeLaebl.text = _weibo.created_at;
//    _sourceLabel.text = _weibo.source;
    [_userImageView sd_setImageWithURL:_weibo.user.profile_image_url];
    
    //------------------------微博来源------------------------
    //<a href="http://weibo.com" rel="nofollow">新浪微博</a>
//    if (_weibo.source.length != 0) {
//        NSArray *array1 = [_weibo.source componentsSeparatedByString:@">"];
//        NSString *subString = [array1 objectAtIndex:1];
//        NSArray *array2 = [subString componentsSeparatedByString:@"<"];
//        NSString *source = array2.firstObject;
//        
//        _sourceLabel.text = [NSString stringWithFormat:@"来源：%@", source];
//        _sourceLabel.hidden = NO;
//    } else {
//        _sourceLabel.hidden = YES;
//    }
    
    //使用XML 来获取来源
    if (_weibo.source.length != 0) {
        GDataXMLElement *element = [[GDataXMLElement alloc] initWithXMLString:_weibo.source error:nil];
        NSString *source = element.stringValue;
        _sourceLabel.text = [NSString stringWithFormat:@"来源：%@", source];
        _sourceLabel.hidden = NO;
        } else {
            _sourceLabel.hidden = YES;
    }
    
    //------------------------时间显示------------------------
    // Tue May 31 17:46:55 +0800 2011
    // 星期 月份 日期 时:分:秒 时区 年份
    //1.使用时间格式化符 来转化时间字符串 -->  NSDate
    NSString *formatterString = @"E M d HH:mm:ss Z yyyy";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置时间格式
    [formatter setDateFormat:formatterString];
    //设置语言类型／地区
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    //时间格式化
    NSDate *date = [formatter dateFromString:_weibo.created_at];
    
    //2.判断时间段
    //计算时间差
    NSTimeInterval sceond = -[date timeIntervalSinceNow];
    //计算各种时间单位
    NSTimeInterval minute = sceond / 60;
    NSTimeInterval hour = minute / 60;
    NSTimeInterval day = hour / 24;
    
    NSString *timeString = nil;
    
    if (sceond < 60) {
        timeString = @"刚刚";
    } else if (minute < 60  ) {
        timeString = [NSString stringWithFormat:@"%li分钟之前", (NSInteger)minute];
    } else if (hour < 24) {
        timeString = [NSString stringWithFormat:@"%li小时之前", (NSInteger)hour];
    } else if (day < 7) {
        timeString = [NSString stringWithFormat:@"%li天之前", (NSInteger)day];
    } else {
        //具体时间
        [formatter setDateFormat:@"M月d日 HH:mm"];
        //设置当前的所在地区
        [formatter setLocale:[NSLocale currentLocale]];
        //转化成字符串
        timeString = [formatter stringFromDate:date];
    }
    
    _timeLaebl.text = timeString;
    
    
    //------------------------布局对象创建------------------------
    WeiboCellLayout *layout = [WeiboCellLayout layoutWithWeiboModel:_weibo];
    
    
    //------------------------微博正文------------------------
    self.weiboTextLabel.text = _weibo.text;
    self.weiboTextLabel.frame = layout.weiboTextFrame;

    
    //------------------------微博图片------------------------
//    self.weiboImageView.frame = layout.weiboimageFrame;
//    [self.weiboImageView sd_setImageWithURL:_weibo.bmiddle_pic];
    if (_weibo.retweeted_status.pic_urls.count>0) {
        for (int i = 0; i < 9; i++) {
            //取出ImageView
            UIImageView *iv = self.imageArray[i];
            //设置frame
            NSValue *value = layout.imageFrameArray[i];
            CGRect frame = [value CGRectValue];
            iv.frame = frame;
            if (i < _weibo.retweeted_status.pic_urls.count) {
                //设置内容
                NSURL *url = [NSURL URLWithString:_weibo.retweeted_status.pic_urls[i][@"thumbnail_pic"]];
                [iv sd_setImageWithURL:url];
            }
       }
    }else if (_weibo.bmiddle_pic) {
        for (int i = 0; i < 9; i++) {
            //取出ImageView
            UIImageView *iv = self.imageArray[i];
            //设置frame
            NSValue *value = layout.imageFrameArray[i];
            CGRect frame = [value CGRectValue];
            iv.frame = frame;
            if (i < _weibo.pic_urls.count) {
                
                //设置内容
                NSURL *url = [NSURL URLWithString:_weibo.pic_urls[i][@"thumbnail_pic"]];
                
                [iv sd_setImageWithURL:url];
            }
            
        }
    } else {
        for (UIImageView *iv in _imageArray) {
            iv.frame = CGRectZero;
        }
    }
    
    //---------------转发微博正文------------------------
    self.reWeiboTextlabel.text = _weibo.retweeted_status.text;
    self.reWeiboTextlabel.frame = layout.reWeiboTextframe;
    NSLog(@"%@",_weibo.retweeted_status.text);

    //------------------------背景-----------------------
    self.reWeiboBGImageView.frame = layout.reWeiboBGImageFrame;
    
  //传统方法
  /*
 //    //微博正文
 //    self.WeiboTextLabel.text = _model.text;
 ////    self.WeiboTextLabel.frame = CGRectMake(10, 70, kScreenWidth - 20,300);
 ////    self.WeiboTextLabel.backgroundColor = [UIColor cyanColor];
 //
 //    //根据文本数量，计算文本高度
 //    NSDictionary *sttributes = @{NSFontAttributeName:kWeiboTextFont};
 //    CGRect rect = [_model.text boundingRectWithSize:CGSizeMake(kScreenWidth - 20, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:sttributes context:nil];
 //    CGFloat height = rect.size.height;
 //
 //    self.WeiboTextLabel.frame = CGRectMake(10, 70, kScreenWidth-20, height);
 
 //    //-------------微博图片--------------------
 //    //判断微博，是否有图片
 //    if (_model.bmiddle_pic) {
 //        //图片加载
 //        [self.weiboImageView sd_setImageWithURL:_model.bmiddle_pic];
 //        //设置图片的frmae
 //        self.weiboImageView.frame = CGRectMake(10, CGRectGetMaxY(self.WeiboTextLabel.frame) +10, 200, 200);
 //    }else{
 //        self.weiboImageView.frame = CGRectZero;
 //    }
 */
}

#pragma mark - 创建子视图
//懒加载模式 创建子视图
- (WXLabel *)weiboTextLabel {
    if (_weiboTextLabel == nil) {
        //创建对象
        _weiboTextLabel = [[WXLabel alloc] initWithFrame:CGRectZero];
        _weiboTextLabel.font = kWeiboTextFont;
        //行数
        _weiboTextLabel.numberOfLines = 0;
        //设置主题颜色
//        _weiboTextLabel.colorName = kHomeWeiboTextColor;
        
        //添加代理
        _weiboTextLabel.wxLabelDelegate = self;
        //设置行间距
        _weiboTextLabel.linespace = LineSpace;
        //添加视图
        [self.contentView addSubview:_weiboTextLabel];
        
    }
    
    return _weiboTextLabel;
}

-(NSArray *)imageArray {
    if (_imageArray == nil) {
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        for (int i = 0;  i < 9; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            [self.contentView addSubview:imageView];
            [mArray addObject:imageView];
            //给图片添加手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [imageView addGestureRecognizer:tap];
            
            //开启图片的点击事件
            imageView.userInteractionEnabled = YES;
            
            imageView.tag = i;
            
        }
        _imageArray = [mArray copy];
    }
    
    return _imageArray;
}

- (WXLabel *)reWeiboTextlabel {
    if (_reWeiboTextlabel == nil) {
        _reWeiboTextlabel = [[WXLabel alloc] initWithFrame:CGRectZero];
//        _reWeiboTextlabel.colorName = kHomeReWeiboTextColor;
        _reWeiboTextlabel.font = kReWeiboTextFont;
        _reWeiboTextlabel.numberOfLines = 0;
        
        //添加代理
        _reWeiboTextlabel.wxLabelDelegate = self;
        //设置行间距
        _reWeiboTextlabel.linespace = LineSpace;
        
        [self.contentView addSubview: _reWeiboTextlabel];
    }
    
    return _reWeiboTextlabel;
}

- (ThemeImageView *)reWeiboBGImageView {
    if (_reWeiboBGImageView == nil) {
        _reWeiboBGImageView = [[ThemeImageView alloc] initWithFrame:CGRectZero];
        _reWeiboBGImageView.imageName = @"timeline_rt_border_selected_9.png";
        
        //设置背景图片的拉伸点
        _reWeiboBGImageView.topCapHeight = 20;
        _reWeiboBGImageView.leftCapWidth = 27;
        
        [self.contentView insertSubview:_reWeiboBGImageView atIndex:0];
    }
    
    return _reWeiboBGImageView;
}


#pragma mark - wxLabel代理方法
//检索文本的正则表达式的字符串
- (NSString *)contentsOfRegexStringWithWXLabel:(WXLabel *)wxLabel {
    //需要添加链接字符串的正则表达式：@用户、http://、#话题#
    NSString *regex1 = @"@[\\w-]{2,30}";
    NSString *regex2 = @"http(s)?://([A-Za-z0-9._-]+(/)?)*";
    NSString *regex3 = @"#[^#]+#";
    NSString *regex = [NSString stringWithFormat:@"(%@)|(%@)|(%@)",regex1,regex2,regex3];
    return regex;
}
//设置当前链接文本的颜色
- (UIColor *)linkColorWithWXLabel:(WXLabel *)wxLabel {
    
    return [[ThemeManager shareManage] themeColorWithName:kLinkColor];
    
}
//设置当前文本手指经过的颜色
- (UIColor *)passColorWithWXLabel:(WXLabel *)wxLabel {
    
    return [UIColor redColor];
}
//手指离开当前超链接文本响应的协议方法
- (void)toucheEndWXLabel:(WXLabel *)wxLabel withContext:(NSString *)context {
    //使用正则表达式，判断所点击的是不是URL链接
    NSString *regex = @"http(s)?://([A-Za-z0-9._-]+(/)?)*";
    NSString *regex1 = @"@[\\w-]{2,30}";
    if ([context isMatchedByRegex:regex]) {
//        NSLog(@"%@",context);
        //创建浏览器界面
        WeiboWebViewController *webVC = [[WeiboWebViewController alloc] initWithURL:[NSURL URLWithString:context]];
        webVC.hidesBottomBarWhenPushed = YES;
        
        //使用响应者链 查找导航控制器
        UIResponder *nextResponder = self.nextResponder;
        while (nextResponder) {
            //判断对象是否是导航控制器
            if ([nextResponder isKindOfClass:[UINavigationController  class]]) {
            //PUSH跳转
                UINavigationController *navi = (UINavigationController *)nextResponder;
                [navi pushViewController:webVC animated:YES];
               
                break;
            }
            nextResponder = nextResponder.nextResponder;
        }
        
    } else if ([context isMatchedByRegex:regex1]){
        
        NSString *substr = [context substringFromIndex:1];
        UserViewController *userVC = [[UserViewController alloc] initWithScreen_name:substr];
        userVC.hidesBottomBarWhenPushed = YES;
        //使用响应者链 查找导航控制器
        UIResponder *nextResponder = self.nextResponder;
        while (nextResponder) {
            //判断对象是否是导航控制器
            if ([nextResponder isKindOfClass:[UINavigationController  class]]) {
                //PUSH跳转
                UINavigationController *navi1 = (UINavigationController *)nextResponder;
                [navi1 pushViewController:userVC animated:YES];
                break;
            }
            nextResponder = nextResponder.nextResponder;
        }
    }

}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    
    _nameLabel.colorName = kHomeUserNameTextColor;
    _timeLaebl.colorName = kHomeTimeLabelTextColor;
    _sourceLabel.colorName = kHomeTimeLabelTextColor;
    
    //监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChange) name:kThemeChangedNotificationName object:nil];
    [self themeChange];
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)themeChange {
    
    ThemeManager *manager = [ThemeManager shareManage];
    
    self.weiboTextLabel.textColor = [manager themeColorWithName:kHomeWeiboTextColor];
    self.reWeiboTextlabel.textColor = [manager themeColorWithName:kHomeReWeiboTextColor];
}
#pragma mark - 图片点击
- (void)tapImageViewAction:(UITapGestureRecognizer *)tap {
    //获取被点击的视图
    UIImageView *imageView = (UIImageView *)tap.view;
//    NSLog(@"tag = %li",imageView.tag);
    
    //显示图片浏览器
    [WXPhotoBrowser showImageInView:self.window selectImageIndex:imageView.tag delegate:self];
    
}
#pragma  mark - PhotoBrowerDelegate
//需要显示的图片个数
- (NSUInteger)numberOfPhotosInPhotoBrowser:
  (WXPhotoBrowser *)photoBrowser{
    if (_weibo.retweeted_status.pic_urls.count > 0) {
        //转发微博的图片
        return _weibo.retweeted_status.pic_urls.count;
    }else {
        //原微博的图片
        return _weibo.pic_urls.count;
    }
    
}

//返回需要显示的图片对应的Photo实例,通过Photo类指定大图的URL,以及原始的图片视图
- (WXPhoto *)photoBrowser:(WXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{

    //创建Photo对象
    WXPhoto *photo = [[WXPhoto alloc] init];
    NSString *imageUrlStr = nil;
    //大图地址 用来加载原图
    if (_weibo.retweeted_status.pic_urls.count > 0) {
        //转发微博中的图片
        NSDictionary *dic = _weibo.retweeted_status.pic_urls[index];
        imageUrlStr = dic[@"thumbnail_pic"];
    }else {
        //原微博中的图片
        NSDictionary *dic = _weibo.pic_urls[index];
        imageUrlStr = dic[@"thumbnail_pic"];
    }
//    NSLog(@"%@",imageUrlStr);//这是缩略图地址
    //将缩略图地址转化为原图（字符串替换）
    imageUrlStr = [imageUrlStr stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
    
    photo.url = [NSURL URLWithString:imageUrlStr];
    //原来、ImageView 获取ImageView的Frame 来实现动画效果 以及ImageView中的缩略图
    
    photo.srcImageView  = _imageArray[index];
    
    
    return photo;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
