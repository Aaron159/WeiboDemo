//
//  WeiboModel.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/2.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "WeiboModel.h"

@implementation WeiboModel

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
//    NSNumber *timestamp = dic[@"timestamp"];
//    if (![timestamp isKindOfClass:[NSNumber class]]) return NO;
//    _createdAt = [NSDate dateWithTimeIntervalSince1970:timestamp.floatValue];
    
    //获取字符串
    NSString *weiboText = [self.text copy];
    
    //字符串内容替换
    //   [兔子] --> <image url = '001.png'>
    
//    [weiboText insertString:@"<image url = '001.png'>" atIndex:weiboText.length - 1];
    
    //1.使用正则表达式，查找表情字符串
    NSString *regex = @"\\[\\w+\\]";
    NSArray *array = [weiboText componentsMatchedByRegex:regex];
    //2.使用plist文件中查找表情是否存在
    //读取Plist文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"];
    NSArray *emotions = [[NSArray alloc] initWithContentsOfFile:filePath];
    for (NSString *str in array) {
          //使用谓词来查找(分两步来，否则不成功)
        NSString *s = [NSString stringWithFormat:@"chs='%@'",str];
        NSPredicate *pre = [NSPredicate predicateWithFormat:s];
        //谓词过滤
        NSArray *result = [emotions filteredArrayUsingPredicate:pre];
        
        //获取过滤结果
        NSDictionary *dic = [result firstObject];
        
        if (dic == nil) {
            //表情在列表中不存在，则忽略此表情
            continue;
        }
        //3.如果表情存在，则获取表情文件名，按照格式替换
        //替换后的字符串
        NSString *imageName = dic[@"png"];
        NSString *imageString = [NSString stringWithFormat:@"<image url = '%@'>",imageName];
        
        weiboText = [weiboText stringByReplacingOccurrencesOfString:str withString:imageString];
//        NSLog(@"替换成功 %@",str);
    }
    
    //重新设置text
    self.text = [weiboText copy];
    
    return YES;
}

@end
