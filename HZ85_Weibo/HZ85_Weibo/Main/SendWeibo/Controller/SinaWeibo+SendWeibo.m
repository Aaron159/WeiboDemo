//
//  SinaWeibo+SendWeibo.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/9/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "SinaWeibo+SendWeibo.h"
#import "AFNetworking.h"
@class AFHTTPSessionManager;

@implementation SinaWeibo (SendWeibo)


//https://upload.api.weibo.com/2/statuses/upload.json
//https://api.weibo.com/2/statuses/update.json

- (void)sendWeiboWithText:(NSString *)text
                    image:(UIImage *)image
                   params:(NSDictionary *)parmas
                  success:(SendWeiboSuccessBlock)success
                     fail:(SendWeiboFailBlock)fail {
    //处理参数  token
    NSMutableDictionary *mDic = [parmas mutableCopy];
    [mDic setObject:self.accessToken forKey:@"access_token"];
    [mDic setObject:text forKey:@"status"];
    
    
    if (image) {
        //1.有图片的
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:mDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //图片转Data
            NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
            //拼接数据
            [formData appendPartWithFileData:imageData name:@"pic" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (fail) {
                fail(error);
            }
        }];
        
    } else {
        //2.没图片的
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //发送POST请求
        [manager POST:@"https://api.weibo.com/2/statuses/update.json" parameters:mDic success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (fail) {
                fail(error);
            }
        }];
    }
}
@end
