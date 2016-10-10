//
//  WeiboCellLayout.h
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/3.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CellTopViewHeight 60
#define SpaceWidth 10
#define ImageViewWidth 200

#define ImageViewSpace 5




@interface WeiboCellLayout : NSObject


//------------------------数据输入------------------------
@property (nonatomic, strong) WeiboModel *weibo;

+ (instancetype)layoutWithWeiboModel:(WeiboModel *)weibo;

//------------------------布局输出------------------------
@property (nonatomic, assign, readonly) CGRect weiboTextFrame;  //正文frmae
@property (nonatomic, assign, readonly) CGRect weiboimageFrame; //正文图片frmae
@property (nonatomic, assign, readonly) CGRect reWeiboTextframe;
@property (nonatomic, assign, readonly) CGRect reWeiboBGImageFrame; //转发微博背景图片frmae

//九个图片
@property (nonatomic,strong,readonly) NSArray *imageFrameArray;

//总高度获取
- (CGFloat)cellHeight;




@end
