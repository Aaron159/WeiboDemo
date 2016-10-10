//
//  WeiboCellLayout.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/3.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "WeiboCellLayout.h"
#import "WXLabel.h"
@interface WeiboCellLayout()
{
    CGFloat _cellHeight;
}
@end

@implementation WeiboCellLayout

+ (instancetype)layoutWithWeiboModel:(WeiboModel *)weibo {
    WeiboCellLayout *layout = [[WeiboCellLayout alloc] init];
    if (layout) {
        layout.weibo = weibo;
    }
    
    return layout;
}



//在输入一个Model时，计算Frame
- (void)setWeibo:(WeiboModel *)weibo {
    if (_weibo == weibo) {
        return;
    }
    
    _weibo = weibo;
    
    //初始化总高度为0
    _cellHeight = 0;
    //顶部视图
    _cellHeight += CellTopViewHeight;
    //空隙
    _cellHeight += SpaceWidth;
    
    //计算frame
    //------------------------微博正文------------------------
    //计算高度
    //根据文本数量，计算文本高度
//    NSDictionary *attributes = @{NSFontAttributeName : kWeiboTextFont};

//    CGRect rect = [_weibo.text boundingRectWithSize:CGSizeMake(kScreenWidth - 2 * SpaceWidth, 1000)
//                                            options:NSStringDrawingUsesLineFragmentOrigin
//                                         attributes:attributes
//                                            context:nil];
//    CGFloat weiboTextHeight = rect.size.height;

    
    //pointSize 字体的实际大小
    CGFloat weiboTextHeight = [WXLabel getTextHeight:kWeiboTextFont.pointSize width:kScreenWidth - 2 * SpaceWidth text:_weibo.text linespace:LineSpace];
    weiboTextHeight += 2;
    
    //文本frmae
    _weiboTextFrame = CGRectMake(SpaceWidth, CellTopViewHeight + SpaceWidth, kScreenWidth - 2 * SpaceWidth, weiboTextHeight);
    
    //累加总高度
    _cellHeight += weiboTextHeight;
    //空隙
    _cellHeight += SpaceWidth;
    
    
    
    
    if (_weibo.retweeted_status) {
        //------------------------转发微博正文------------------------
        //计算高度
        //根据文本数量，计算文本高度
//        NSDictionary *attributes = @{NSFontAttributeName : kReWeiboTextFont};
//        
//        CGRect rect = [_weibo.retweeted_status.text boundingRectWithSize:CGSizeMake(kScreenWidth - 4 * SpaceWidth, 1000)
//                                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                                       attributes:attributes
//                                                          context:nil];
//        CGFloat reWeiboTextHeight = rect.size.height;
        
        CGFloat reWeiboTextHeight = [WXLabel getTextHeight:kReWeiboTextFont.pointSize width:kScreenWidth - 4 * SpaceWidth text:_weibo.retweeted_status.text linespace:LineSpace];
        reWeiboTextHeight += 2;
        _reWeiboTextframe = CGRectMake(2 * SpaceWidth, _cellHeight + 10, kScreenWidth - 4 * SpaceWidth, reWeiboTextHeight);
        //累加总高度
        _cellHeight += reWeiboTextHeight;
        _cellHeight += SpaceWidth * 2;
        
        
        //------------------------背景图片------------------------
        _reWeiboBGImageFrame = CGRectMake(SpaceWidth, _reWeiboTextframe.origin.y - SpaceWidth, kScreenWidth - 2 * SpaceWidth, 2 * SpaceWidth + _reWeiboTextframe.size.height);
        _cellHeight += SpaceWidth;
        
/*-------------转发微博有图片------------------------
//        if (_weibo.retweeted_status.bmiddle_pic) {
//            _weiboimageFrame = CGRectMake(2 * SpaceWidth, CGRectGetMaxY(_reWeiboTextframe) + SpaceWidth, ImageViewWidth, ImageViewWidth);
//            _cellHeight += _weiboimageFrame.size.height;
//            _cellHeight += SpaceWidth;
//            _reWeiboBGImageFrame.size.height += _weiboimageFrame.size.height + SpaceWidth;
//        } else {
//            _weiboimageFrame = CGRectZero;
//        }
 */
        if (_weibo.retweeted_status.pic_urls.count >0) {
            CGFloat reImageHeight = [self layoutNineImageViewFrameWithImageCount:_weibo.retweeted_status.pic_urls.count viewWidth:(kScreenWidth - 4*SpaceWidth) top:CGRectGetMaxY(_reWeiboTextframe) + SpaceWidth];
            _cellHeight += reImageHeight;
            _cellHeight += SpaceWidth;
            _reWeiboBGImageFrame.size.height += reImageHeight + SpaceWidth;
        }else{
         _imageFrameArray = nil;
        }

    } else {
        _reWeiboTextframe = CGRectZero;
        _reWeiboBGImageFrame = CGRectZero;
//-------------------微博图片------------------------
        //判断是否有图片
        if (_weibo.pic_urls.count > 0) {
            CGFloat imageHeight = [self layoutNineImageViewFrameWithImageCount:_weibo.pic_urls.count viewWidth:(kScreenWidth - 2*SpaceWidth) top:(CGRectGetMaxY(_weiboTextFrame)+SpaceWidth)];
            
            //累加高度
            _cellHeight += imageHeight;
            _cellHeight += SpaceWidth;
        } else {
//            _weiboimageFrame = CGRectZero;
            _imageFrameArray = nil;
        }
  
    }
    
    /*
    //测试九宫格布局
//    CGFloat height = [self layoutNineImageViewFrameWithImageCount:_weibo.pic_urls.count viewWidth:(kScreenWidth - 2 * SpaceWidth) top:500];
//    NSLog(@"%li个视图总高度:%f",_weibo.pic_urls.count,height);
//    for (NSValue *value  in _imageFrameArray) {
//        NSLog(@"%@", value);
//    }
    */
}

- (CGFloat)cellHeight {
    return _cellHeight;
}

#pragma mark - 九宫格布局
/**
 *  布局九个视图的frame
 *
 *  @param imageCount 图片数量
 *  @param viewWidth  整个视图的总宽度
 *  @param top        最顶部图片的y值
 *
 *  @return 视图的总高度，用于计算单元格高度
 */
- (CGFloat)layoutNineImageViewFrameWithImageCount:(NSInteger)imageCount viewWidth:(CGFloat)viewWidth
    top:(CGFloat)top {
    
    //判断图片数量是否合法
    if (imageCount > 9 || imageCount <= 0) {
        _imageFrameArray = nil;
        return 0;
    }
    
    //分情况讨论图片的布局条件 (行数，列数，每个图片的宽度)
    //所有图片的总高度/每一个图片的边长/列数
    CGFloat viewHeight;
    CGFloat imageWidth;
    NSInteger numberOfColumn = 2;   //列数/一行有几个
    
    if (imageCount == 1) {
        //一行一列
        numberOfColumn = 1;
        imageWidth = viewWidth;
        viewHeight = viewWidth;
    } else if (imageCount == 2) {
        //一行两列
        imageWidth = (viewWidth - ImageViewSpace) / 2;
        viewHeight = imageWidth;
    } else if (imageCount == 4) {
        //两行两列
        imageWidth = (viewWidth - ImageViewSpace) / 2;
        viewHeight = viewWidth;
    } else {
        //三列
        imageWidth = (viewWidth - 2 * ImageViewSpace) / 3;
        numberOfColumn = 3;
        if (imageCount == 3) {
            //一行
            viewHeight = imageWidth;
        } else if (imageCount <= 6) {
            //两行
            viewHeight = imageWidth * 2 + ImageViewSpace;
        } else {
            //三行
            viewHeight = viewWidth;
        }
    }
    
    
    //布局视图
    //1.初始化Array
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    
    //2.循环创建frame
    for (int i = 0; i < 9; i++) {
        
        //如果循环次数大于了图片数量
        if (i >= imageCount) {
            //添加一个空的frame 到数组中去，表示此视图不需要显示
            CGRect frame = CGRectZero;
            [mArray addObject:[NSValue valueWithCGRect:frame]];
        } else {
            //计算当前视图，是第几行第几列
            NSInteger row = i / numberOfColumn;
            NSInteger column = i % numberOfColumn;
            //计算视图的frame
            //x = 列号 * (图片宽度 ＋ 空隙宽度) + leftSpace
            //y = 行号 * (图片宽度 ＋ 空隙宽度) + top
            CGFloat width = imageWidth + ImageViewSpace;
            CGFloat left = (kScreenWidth - viewWidth) / 2;
            CGRect frame = CGRectMake(column * width + left, row * width + top, imageWidth, imageWidth);
            
            [mArray addObject:[NSValue valueWithCGRect:frame]];
        }
    }
    //3.包装成NSValue 添加到数组中
    _imageFrameArray = [mArray copy];
    
    return viewHeight;
}


@end
