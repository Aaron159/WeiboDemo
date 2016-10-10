//
//  WeiboWebViewController.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/6/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "BaseViewController.h"

@interface WeiboWebViewController : BaseViewController

@property (nonatomic, strong) NSURL *url;

-(instancetype)initWithURL:(NSURL *)url;

@end
