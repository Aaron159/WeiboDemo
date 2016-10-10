//
//  RightViewController.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/8/1.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

#import "RightViewController.h"
#import "SendWeiboViewController.h"
#import "BaseNavigationController.h"
#import "UIViewController+MMDrawerController.h"
@interface RightViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"mask_bg.jpg";
    
    [self.view insertSubview:bgImageView atIndex:0];

    [self createButtons];
}

-(void)createButtons {
  
    CGFloat buttonWidth = 50;
    CGFloat space = 15;
    
    for (int i = 0; i < 5; i++) {
        //计算frame
        CGRect frame = CGRectMake(space, i*(space +buttonWidth), buttonWidth, buttonWidth);
        //创建按钮
        ThemeButton *button = [[ThemeButton alloc]initWithFrame:frame];
//        button.backgroundColor = [UIColor yellowColor];
        NSString *imageName = [NSString stringWithFormat:@"newbar_icon_%i.png", i+1];
        button.imageName = imageName;
        [self.view addSubview:button];
        //按钮的点击
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
    }
    
    //下面两个按钮
    //地图
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapButton.frame = CGRectMake(space, 0, buttonWidth, buttonWidth);
    [mapButton setImage:[UIImage imageNamed:@"btn_map_location"] forState:UIControlStateNormal];
    [self.view addSubview:mapButton];
    
    //二维码
    UIButton *qrButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qrButton.frame = CGRectMake(space, 0, buttonWidth, buttonWidth);
    [qrButton setImage:[UIImage imageNamed:@"qr_btn"] forState:UIControlStateNormal];
    [self.view addSubview:qrButton];
    
    qrButton.bottom = kScreenHeight - 64 -space;
    mapButton.bottom = qrButton.top;
    
}

#pragma  mark - 按钮点击
-(void)buttonAction:(UIButton *)button {

    if (button.tag == 0) {
        //发微博
        //创建发微博界面
        SendWeiboViewController *sendWeiboVC = [[SendWeiboViewController alloc] init];
        BaseNavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:sendWeiboVC];
        //模态视图弹出
        navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navi animated:YES completion:^{
            //获取MMDrawController
            MMDrawerController *mmd = self.mm_drawerController;
            //关闭侧边栏
            [mmd closeDrawerAnimated:YES completion:nil];
        }];
    }else if (button.tag == 1){
         if ([ UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        //相册选取图片
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        //设置资源类型
//        picker.mediaTypes = @[@"public.image"]; //public.movie
        //设置资源来源
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    
         }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //获取需要配置的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, self,nil, nil);
    // 保存图片到指定的路径
//    NSData *imageData = UIImageJPEGRepresentation(image, 1);
//    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
//    [imageData writeToFile:[savePath stringByAppendingPathComponent:@"image.jpg"] atomically:YES];
//    NSString *s = [NSString stringWithFormat:@"%@/image.jpg",savePath];
//    
//    NSDictionary *d = @{@"jpg" : s};
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kJpg" object:nil userInfo:d];
    
//    NSLog(@"保存成功");
    SendWeiboViewController *sendWeiboVC = [[SendWeiboViewController alloc] init];
    BaseNavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:sendWeiboVC];
    //模态视图弹出
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navi animated:YES completion:^{
        //获取MMDrawController
        MMDrawerController *mmd = self.mm_drawerController;
        //关闭侧边栏
        [mmd closeDrawerAnimated:YES completion:nil];
    }];
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
