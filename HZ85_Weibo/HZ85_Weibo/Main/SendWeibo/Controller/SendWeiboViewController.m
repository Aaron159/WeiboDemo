
//
//  SendWeiboViewController.m
//  HZ85_Weibo
//
//  Created by mac51 on 8/8/16.
//  Copyright © 2016 ZhuJiaCong. All rights reserved.
//

#import "SendWeiboViewController.h"
#import "AppDelegate.h"
#import "MMDrawerController.h"
#import "HomeViewController.h"
#import "LocationViewController.h"
#import "SinaWeibo+SendWeibo.h"
#import "EmoticonInputView.h"

#define kToolViewHeight 40
#define kLocationViewHeight 20
#define kImageViewWidth 80
#define kSendWeiboAPI @"statuses/update.json"
#define kSendWeiboWithImageAPI @"statuses/upload.json"
@interface SendWeiboViewController ()<SinaWeiboRequestDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITextView *_inputTextView;//输入框
    UIView *_toolView;          //工具视图
    
    //定位相关视图
    UIView *_locationView;
    UIImageView *_locationIconImageView;
    ThemeLabel *_loactionNameLabel;
    ThemeButton *_locationCancelButton;
    
    //图片
    UIImageView *_imageView;
    ThemeButton *_imageCacelButton;
    
    //表情选择界面输入框
    EmoticonInputView *_emoticonView;
}
@property (nonatomic,strong) NSDictionary *locationDic;
@end

@implementation SendWeiboViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"写微博";
    //创建导航栏按钮
    [self createNavigationBarButton];
    [self createInputView];
    [self createToolView];
    
    [self createLocationViews];
    
    //图片
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kImageViewWidth, kImageViewWidth)];
    _imageView.userInteractionEnabled = YES;
    _imageView.backgroundColor  = [UIColor greenColor];
    [self.view addSubview:_imageView];
    _imageView.bottom = _locationView.top - 5;
    _imageCacelButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
    _imageCacelButton.frame = CGRectMake(kImageViewWidth - kLocationViewHeight, 0, kLocationViewHeight, kLocationViewHeight);
    _imageCacelButton.backgroundImageName = @"compose_toolbar_clear.png";
    [_imageCacelButton addTarget:self action:@selector(imageCacelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_imageCacelButton];
    _imageView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emoticonsAction:) name:kEmoticonViewNoti object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jpgAction:) name:@"kJpg" object:nil];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter ]  removeObserver:self];
}
-(void)createInputView {
    //创建输入框
    _inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight - 64 - kToolViewHeight)];
    _inputTextView.font = [UIFont systemFontOfSize:25];
    _inputTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_inputTextView];
    
    //监听键盘的改变
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [center addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
    
}
-(void)createToolView {
    _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kToolViewHeight)];
    _toolView.top  = _inputTextView.bottom;
    [self.view addSubview:_toolView];
    
    _toolView.backgroundColor = [UIColor clearColor];
    
    CGFloat buttonWidth = kScreenWidth / 5;
    CGFloat buttonHeight = 40;
    for (int i = 0; i < 5; i++) {
        //计算frame
        CGRect frame = CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight);
        //创建按钮
        ThemeButton *button = [[ThemeButton alloc]initWithFrame:frame];
        NSString *imageName = nil;
        if (i == 0) {
            imageName = [NSString stringWithFormat:@"compose_toolbar_%i.png", i+1];
        }else {
         imageName = [NSString stringWithFormat:@"compose_toolbar_%i.png", i+2];
        }
        button.imageName = imageName;
        [_toolView addSubview:button];
        //按钮的点击
        [button addTarget:self action:@selector(toolBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
    }
    
}
#pragma mark - ToolButton
//工具栏按钮点击事件
-(void)toolBarButtonAction:(UIButton *)button {
    if (button.tag == 3) {
        //打开定位界面
        LocationViewController *locaiton = [[LocationViewController alloc] init];
        //设置获取定位数据的Block回调
        [locaiton addLocationResultBlock:^(NSDictionary *result) {
            //保存位置数据
            self.locationDic = result;
        }];
        [self.navigationController pushViewController:locaiton animated:YES];
        
    }else if (button.tag == 0) {
        //相册选取图片
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        //设置资源类型
        picker.mediaTypes = @[@"public.image"]; //public.movie
        //设置资源来源
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }else if (button.tag == 4) {
        //表情界面
        //表情界面懒加载
        if (_emoticonView == nil) {
            _emoticonView = [[EmoticonInputView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, 0)];
        }
        
        //获取输入框,将输入视图设置为表情视图
        //两个键盘之间的切换
//        _inputTextView.inputView = _emoticonView;
//        if (_inputTextView.inputView) {
//            _inputTextView.inputView = nil;
//        } else {
//        _inputTextView.inputView = _emoticonView;
//        }
        //三目运算符
        _inputTextView.inputView = _inputTextView.inputView ? nil : _emoticonView;
        //重新加载输入视图
        [_inputTextView reloadInputViews];
        //强制弹出键盘
        [_inputTextView becomeFirstResponder];
        
        NSLog(@"%@",_inputTextView.text);
    }
}
-(void)createLocationViews {
   
    //创建父视图
    _locationView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-10, kLocationViewHeight)];
    _locationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_locationView];
    _locationView.bottom = _toolView.top;
    
    //icon
    _locationIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kLocationViewHeight, kLocationViewHeight)];
    [_locationView addSubview:_locationIconImageView];
    
    //Label
    _loactionNameLabel = [[ThemeLabel alloc] initWithFrame:CGRectMake(kLocationViewHeight, 0, 200, kLocationViewHeight)];
    _loactionNameLabel.colorName = kMoreItemTextColor;
    _loactionNameLabel.text = @"中国计量大学";
    [_locationView addSubview:_loactionNameLabel];
    
    //Button
    _locationCancelButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
    _locationCancelButton.frame = CGRectMake(0, 0, kLocationViewHeight, kLocationViewHeight);
    _locationCancelButton.left = _loactionNameLabel.right;
    _locationCancelButton.backgroundImageName = @"compose_toolbar_clear.png";
    [_locationView addSubview:_locationCancelButton];
    //添加点击
    [_locationCancelButton addTarget:self action:@selector(locationCancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //默认隐藏
    _locationView.hidden = YES;
    
}
-(void)emoticonsAction:(NSNotification *)userInfo {
//    NSLog(@"%@",userInfo[@"userInfo"]);
    NSDictionary *dic =userInfo.userInfo;
    _inputTextView.text = [NSString stringWithFormat:@"%@%@",_inputTextView.text,dic[@"chs"]];
    
}
//-(void)jpgAction:(NSNotification *)userInfo {
//    NSDictionary *dic =userInfo.userInfo;
//    NSString *s  =dic[@"jpg"];
//    NSLog(@"%@",s);
//    UIImage *image = [UIImage imageWithContentsOfFile:s];
//    if (!_imageView.image) {
//        _imageView.image =image;
//    }
//}
- (void)createNavigationBarButton {
    //取消
    ThemeButton *leftButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 60, 40);
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    leftButton.backgroundImageName = @"titlebar_button_9.png";
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    //发送
    ThemeButton *sendButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0, 0, 60, 40);
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.backgroundImageName = @"titlebar_button_9.png";
    [sendButton addTarget:self action:@selector(sendWeiboAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}
#pragma mark - UIpickControllerDelegate
//获取到选中的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _imageView.image = image;
    _imageView.hidden = NO;
    //返回界面
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma  mark - Action
//取消定位
- (void)locationCancelButtonAction {
    self.locationDic = nil;
}
-(void)imageCacelButtonAction {
    _imageView.hidden = YES;
    _imageView.image = nil;
}
- (void)sendWeiboAction {

    //去除文本中的空白字符
    NSString *text = [_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //判断输入框是否有文字
    if (text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"没有输入微博正文" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
//    text = [NSString stringWithFormat:@"%@\n%@",text,self.locationDic[@"title"]];
     //发微博之前显示HUD
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view.window];
    //添加hud到window中(发微博时正在跳转，只有window一直在，所以显示到window上)
    [self.view.window addSubview:hud];
    //显示文本内容
    hud.labelText = @"正在发送";
    //设置背景颜色 变暗效果
    hud.dimBackground = YES;
    //显示HUD
    [hud show:YES];
    
    //获取微博对象
    SinaWeibo *wb = kSinaWeiboObject;
    NSMutableDictionary *params = [@{@"status": text } mutableCopy];
    
    //帕努单当前是否有定位信息，如果有则添加
    if (self.locationDic) {
        NSString *lon = self.locationDic[@"lon"];
        NSString *lat = self.locationDic[@"lat"];
        
        //添加数据
        [params setObject:lon forKey:@"long"];
        [params setObject:lat forKey:@"lat"];
//        [params setValue:<#(nullable id)#> forKey:<#(nonnull NSString *)#>] //KVC里面的方法
    }
    
//    [wb requestWithURL:kSendWeiboAPI params:[params mutableCopy] httpMethod:@"POST" delegate:self];
    UIImage *image = nil;
    if (_imageView.image) {
        image = _imageView.image;
    }
    [wb sendWeiboWithText:text image:image params:params success:^(id result) {
        [_inputTextView resignFirstResponder];//放弃第一响应者
        //返回前页面
        [self dismissViewControllerAnimated:YES completion:^{
            //刷新微博
            //发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kHomeViewController object:nil];
        }];
        hud.labelText = @"发送成功";
        //隐藏hud
        [hud hide:YES afterDelay:1.5];
    } fail:^(NSError *error) {
        NSLog(@"失败");
        hud.labelText = @"发送失败";
        //隐藏hud
        [hud hide:YES afterDelay:2];
    }];
    
}
-(void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 键盘改变监听
-(void)keyboardFrameChanged:(NSNotification *)notification {
    
    //获取键盘状态
//    NSLog(@"键盘展开 %@", notification.userInfo);
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [value CGRectValue];
    
    //根据键盘的位置，来改变视图的位置
    _inputTextView.height = kScreenHeight - 64 - kToolViewHeight -keyboardFrame.size.height;
    //工具栏
    _toolView.top = _inputTextView.bottom;
    _locationView.bottom = _toolView.top;
    _imageView.bottom = _locationView.top-5;
}
-(void)keyboardHide:(NSNotification *)notification {
//    NSLog(@"键盘隐藏 %@", notification.userInfo);
    _inputTextView.height = kScreenHeight - 64 - kToolViewHeight;
    _toolView.top = _inputTextView.bottom;
    _locationView.bottom = _toolView.top;
    _imageView.bottom = _locationView.top-5;
}
/*
#pragma mark - SinaWeiboRequestDelegate
//- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response {
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
////    NSLog(@"状态码:%li",httpResponse.statusCode);
//    if (httpResponse.statusCode == 200) {
//        //收起键盘
//        [_inputTextView resignFirstResponder];//放弃第一响应者
//        //返回前页面
//        [self dismissViewControllerAnimated:YES completion:^{
            //刷新微博
//            UIApplication *app = [UIApplication sharedApplication];
//            AppDelegate *delegate = (AppDelegate *)app.delegate;
//            MMDrawerController *mmd = (MMDrawerController *)delegate.window.rootViewController;
//            UITabBarController *tabbar = (UITabBarController *)mmd.centerViewController;
//            UINavigationController *navi = (UINavigationController *)[tabbar.viewControllers firstObject];
//            HomeViewController *home = (HomeViewController *)navi.topViewController;
//            [home reloadNewWeibo];
            //发送通知
//            [[NSNotificationCenter defaultCenter] postNotificationName:kHomeViewController object:nil];
//        }];
//    }
//}
*/
#pragma mark - 位置信息填充
//在locationDic的SET方法中 来设置显示的位置数据
- (void)setLocationDic:(NSDictionary *)locationDic {
    
    
    
    if (_locationDic != locationDic) {
        _locationDic = [locationDic copy];
        if (_locationDic == nil) {
            //点击取消按钮  将LocationDic设置为空
            _locationView.hidden = YES;
        } else {
            _locationView.hidden = NO;
            //设置数据
            _loactionNameLabel.text = _locationDic[@"title"];
            [_locationIconImageView sd_setImageWithURL:[NSURL URLWithString:_locationDic[@"icon"]]];
            
            //改变Label宽度
            NSDictionary *attributes = @{NSFontAttributeName : _loactionNameLabel.font};
            CGRect rect = [_loactionNameLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 10 - kLocationViewHeight * 2, kLocationViewHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
            CGFloat width = rect.size.width;
            
            _loactionNameLabel.width = width;
            _locationCancelButton.left = _loactionNameLabel.right;
        }
        
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
