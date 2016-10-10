//
//  UserViewController.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/6/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "BaseViewController.h"

@interface UserViewController : BaseViewController
@property (nonatomic,strong) NSString *screen_name;

-(instancetype)initWithScreen_name:(NSString *)screen_name;
@end
