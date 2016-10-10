//
//  Emoticon.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/10/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Emoticon : NSObject

@property (nonatomic , copy)NSString *cht; //繁体文本
@property (nonatomic , copy)NSString *chs; //简体文本
@property (nonatomic , copy)NSString *gif;
@property (nonatomic , copy)NSString *png;
@property (nonatomic , copy)NSString *type;

@property (nonatomic, strong, readonly) UIImage *emoticonImage; //表情所对应的图片

@end
