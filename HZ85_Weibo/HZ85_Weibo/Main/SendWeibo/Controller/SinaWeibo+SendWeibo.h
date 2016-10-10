//
//  SinaWeibo+SendWeibo.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/9/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "SinaWeibo.h"

typedef void(^SendWeiboSuccessBlock)(id result);
typedef void(^SendWeiboFailBlock)(NSError *error);

@interface SinaWeibo (SendWeibo)

/**
 *  发送微博
 *
 *  @param text    微博正文
 *  @param image   图片
 *  @param parmas  参数字典
 *  @param success 成功
 *  @param fail    失败
 */
- (void)sendWeiboWithText:(NSString *)text
                    image:(UIImage *)image
                   params:(NSDictionary *)parmas
                  success:(SendWeiboSuccessBlock)success
                     fail:(SendWeiboFailBlock)fail;
@end
