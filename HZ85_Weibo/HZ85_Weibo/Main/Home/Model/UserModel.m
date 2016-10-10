//
//  UserModel.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/2.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             //key Model类中属性的名字
             //value 字典中，属性对应的Key
             @"des" : @"description"
             };

}

@end
