//
//  EmoticonInputView.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/10/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "EmoticonInputView.h"
#import "YYModel.h"
#import "Emoticon.h"
#import "EmoticonView.h"
@implementation EmoticonInputView

-(instancetype)initWithFrame:(CGRect)frame {
   
    //强制修改高度
    frame.size.height = kEmoticonInputViewHeight;
    //原点位置设置为0
    frame.origin = CGPointZero;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        [self loadData];
        [self createScrollView];
    }

    return self;
}


-(void)loadData {

    NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    //遍历和数据解析
    for (NSDictionary *dic in array) {
        Emoticon *e = [Emoticon yy_modelWithJSON:dic];
        [mArray addObject:e];
    }
    
    _emoticonArray = [mArray copy];

}
//创建滑动视图
-(void)createScrollView {
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScrollViewHeight)];
    [self addSubview:_scrollView];
    
    //设置滑动视图
    //分页滑动
    _scrollView.pagingEnabled = YES;
    //隐藏滑动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    //分配表情
    NSInteger pageCount = (_emoticonArray.count - 1) / 32 +1;
    NSLog(@"pageCount = %li",pageCount);
    for (int i = 0; i < pageCount; i++) {
        //第i页 (i*32) 到 (i+1)*32 -1
        EmoticonView *emoticonView = [[EmoticonView alloc] initWithFrame:CGRectMake(i*kScreenWidth, 0, kScreenWidth, kScrollViewHeight)];
        //表情数组分割
        NSRange range = NSMakeRange(i*32, 32);
        //判断是否超出范围
        if ((range.length +range.location) > _emoticonArray.count) {
            //调整分割的长度
            range.length = _emoticonArray.count - range.location;
        }
        NSArray *subArray = [_emoticonArray subarrayWithRange:range];
    
        //设置每一页所显示的表情
        emoticonView.emoticonsArray = subArray;
        [_scrollView addSubview:emoticonView];
        
    }
    
    //设置滑动范围
    _scrollView.contentSize = CGSizeMake(pageCount *kScreenWidth, kScrollViewHeight);
    
    _pageControl = [[UIPageControl alloc]  initWithFrame:CGRectMake(0, kScrollViewHeight, kScreenWidth, kPageControllerHeight)];
    [_pageControl addTarget:self action:@selector(pageControllerValueChangedAction) forControlEvents:UIControlEventValueChanged];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.numberOfPages = pageCount;
    
    [self addSubview:_pageControl];
}
//需求二：根据UIPageControl页码的改变来滑动UIScrollView
- (void)pageControllerValueChangedAction{
    float x = _pageControl.currentPage * _scrollView.bounds.size.width;
    _scrollView.contentOffset = CGPointMake(x, 0);
    
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"已经停止减速");
//    需求一：根据UIScrollView滑动的位置来改变UIPageControl的页码
    int index = (int) scrollView.contentOffset.x / scrollView.bounds.size.width;
    _pageControl.currentPage = index;
    
}

@end
