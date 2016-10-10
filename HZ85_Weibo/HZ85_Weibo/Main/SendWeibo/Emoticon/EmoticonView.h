//
//  EmoticonView.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/10/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import <UIKit/UIKit.h>

//每一个表情视图，最多可以显示32个表情
//使用一个数组，来保存32个表情
//绘制当前数组中保存的表情
//识别手指点击

@interface EmoticonView : UIView


@property (nonatomic, copy) NSArray *emoticonsArray;

@end
