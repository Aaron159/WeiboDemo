//
//  EmoticonInputView.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/10/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

/*
 1.键盘切换
 2.表情数据读取
 3.显示表情图
 4.点击表情，输出文本
 */
#import <UIKit/UIKit.h>

#define kEmoticonWidth (kScreenWidth / 8)   //单个表情宽度
#define kPageControllerHeight 20            //页码显示器高度
#define kScrollViewHeight (kEmoticonWidth * 4)
#define kEmoticonInputViewHeight (kScrollViewHeight + kPageControllerHeight) //视图总高度

@interface EmoticonInputView : UIView<UIScrollViewDelegate>
{
    NSArray *_emoticonArray;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}
@end
