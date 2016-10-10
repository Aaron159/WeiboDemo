//
//  LocationViewController.h
//  HZ85_Weibo
//
//  Created by mac51 on 8/8/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^LocationResultBlock)(NSDictionary *result);

@interface LocationViewController : BaseViewController

@property (nonatomic ,copy) LocationResultBlock block;

-(void)addLocationResultBlock:(LocationResultBlock)block;


@end
