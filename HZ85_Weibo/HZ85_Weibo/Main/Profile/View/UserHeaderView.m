//
//  UserHeaderView.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/6/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "UserHeaderView.h"

@interface UserHeaderView ()



@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet ThemeLabel *nameLabel;

@property (weak, nonatomic) IBOutlet ThemeLabel *subtitleLabel;


@property (weak, nonatomic) IBOutlet ThemeLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;

@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;


@property (weak, nonatomic) IBOutlet ThemeLabel *statusesLabel;


@end

@implementation UserHeaderView

- (void)awakeFromNib {
    _nameLabel.colorName = kHomeUserNameTextColor;
    _subtitleLabel.colorName = kHomeUserNameTextColor;
    _descriptionLabel.colorName = kHomeUserNameTextColor;
    _statusesLabel.colorName = kHomeUserNameTextColor;
    
}


- (void)setModel:(UserModel *)user {
    [_userImageView sd_setImageWithURL:user.profile_image_url];
    _nameLabel.text = user.name;
    _nameLabel.font = kWeiboTextFont;
    _descriptionLabel.text = user.des;
    _descriptionLabel.font = [UIFont systemFontOfSize:10];
    _followersLabel.text = [NSString stringWithFormat:@"%@", user.followers_count];
    _friendsLabel.text = [NSString stringWithFormat:@"%@", user.friends_count];
    _statusesLabel.text = [NSString stringWithFormat:@"微博数：%@", user.statuses_count];
    _statusesLabel.font = kReWeiboTextFont;
    NSString *sex;
    if ([user.gender isEqualToString:@"m"]) {
        sex = @"男";
    } else if ([user.gender isEqualToString:@"f"]) {
        sex = @"女";
    } else {
        sex = @"未知";
    }
    _subtitleLabel.text = [NSString stringWithFormat:@"%@ %@", sex, user.location];
    _subtitleLabel.font = kReWeiboTextFont;
}

@end
