//
//  AppDelegate.m
//  HZ85_Weibo
//
//  Created by ZhuJiaCong on 16/7/29.
//  Copyright © 2016年 ZhuJiaCong. All rights reserved.
//

/*
 集成SinaWeiboSDK 解决所产生的错误
 1.旧版本的SDK，部分文件是使用非ARC环境写的。需要标记非ARC文件，来解决错误。
        将非ARC文件，添加 -fno-objc-arc 标记
 2.低版本的系统方法被弃用，需要使用新的方法来替代。
 
 */


/*
 登陆流程
 1.读取当前的磁盘中的登陆信息
 2.如果已有登陆信息，则直接将登陆信息，读取到内存中；如果没有登陆信息，则需要打开登陆界面。
 3.登陆界面关闭后，获取登陆信息，并且保存到本地磁盘
 */




#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "MMDrawerController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "BaseNavigationController.h"

@class BaseNavigationController;
@class LeftViewController;
@class RightViewController;
@class MMDrawerController;


#define kWeiboAuthDataKey @"kWeiboAuthDataKey"

@interface AppDelegate () <SinaWeiboDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"%@", NSHomeDirectory());
    
    //创建window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    //创建标签控制器
    MainTabBarController *tab = [[MainTabBarController alloc] init];
    //左边
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    
    //右边
    RightViewController *rightVC = [[RightViewController alloc] init];
    
    //导航
    BaseNavigationController *leftNavi = [[BaseNavigationController alloc] initWithRootViewController:leftVC];
    BaseNavigationController *rightNavi = [[BaseNavigationController alloc] initWithRootViewController:rightVC];
    
    //创建MMDraw
    MMDrawerController *mmd = [[MMDrawerController alloc] initWithCenterViewController:tab leftDrawerViewController:leftNavi rightDrawerViewController:rightNavi];
    
    //设置侧滑宽度
    mmd.maximumLeftDrawerWidth = 180;
    mmd.maximumRightDrawerWidth = 80;
    
    //设置打开方式
    [mmd setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [mmd setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
     //设置滑动动画的Block
    [mmd setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        //动画要执行的内容    
        //每一次需要执行滑动动画时，到Manager中获取相应的Block
        MMExampleDrawerVisualStateManager *manager = [MMExampleDrawerVisualStateManager sharedManager];
        //获取Block
        MMDrawerControllerDrawerVisualStateBlock block = [manager drawerVisualStateBlockForDrawerSide:drawerSide];
        //执行Block
        if (block) {
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    
    
    //设置根视图控制器
    self.window.rootViewController = mmd;
    
    //初始化微博SDK
    _sinaWeibo = [[SinaWeibo alloc] initWithAppKey:@"3619407204"
                                         appSecret:@"1a99b9f6ea6d8b240ea69f55b4829c02"
                                    appRedirectURI:@"http://www.baidu.com"
                                       andDelegate:self];
    
    //1.读取登陆信息
    BOOL isAuth = [self readAuthData];
    //2.判断是否已登陆
    if (isAuth == NO) {
        //执行登陆操作
        [self.sinaWeibo logIn];
        NSLog(@"从未登陆过微博，需要重新登陆");
    } else {
        NSLog(@"已登陆过微博access_token:%@,%@", self.sinaWeibo.accessToken,self.sinaWeibo.userID);
    }
    
    
    return YES;
}


#pragma mark - 登陆/登出
//登陆成功
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo {
    NSLog(@"登陆成功:%@", sinaweibo.accessToken);
    
    [self saveAuthData];
    
    
}
//登陆失败
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error {
    NSLog(@"登录失败");
}

//登陆信息过期
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error {
    //登出微博
    [self.sinaWeibo logOut];
    //删除本地登陆信息
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWeiboAuthDataKey];
    //重新登陆微博
    [self.sinaWeibo logIn];
}


//注销微博
- (void)logoutWeibo {
    //登出微博
    [_sinaWeibo logOut];
    
}

//注销之后 所调用的方法
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo {
    NSLog(@"注销成功");
    //删除登陆信息
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kWeiboAuthDataKey];
    
}


#pragma mark - 保持登陆状态
//将登陆后的数据，保存到本地磁盘。token,uid
//保存认证信息
- (void)saveAuthData {
    
    //用户令牌 token
    NSString *token = _sinaWeibo.accessToken;
    //用户ID uid
    NSString *uid = _sinaWeibo.userID;
    //认证的有效期限 长期不使用，会导致token失效
    NSDate *date = _sinaWeibo.expirationDate;
    
    //使用属性列表，保存登陆数据到本地
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dic = @{@"accessToken" : token,
                          @"uid" : uid,
                          @"expirationDate" : date};
    //将认证数据 保存到属性列表中
    [userDef setObject:dic forKey:kWeiboAuthDataKey];
    //数据同步
    [userDef synchronize];
    
}

//读取登陆信息
- (BOOL)readAuthData {
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    //读取数据
    NSDictionary *dic = [userDef objectForKey:kWeiboAuthDataKey];
    //判断是否读取成功
    if (dic == nil) {
        //读取数据失败，没有登陆
        return NO;
    }
    
    //获取保存的数据
    NSString *token = dic[@"accessToken"];
    NSString *uid = dic[@"uid"];
    NSDate *date = dic[@"expirationDate"];
    if (token == nil || uid == nil || date == nil) {
        //保存的数据有误 重新登陆
        return NO;
    }
    
    //读取成功，使用保存过的数据
    _sinaWeibo.accessToken = token;
    _sinaWeibo.userID = uid;
    _sinaWeibo.expirationDate = date;
    
    return YES;
}



#pragma mark -
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

//#pragma mark - Core Data stack
//
//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//
//- (NSURL *)applicationDocumentsDirectory {
//    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.wxhl.HZ85_Weibo" in the application's documents directory.
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
//
//- (NSManagedObjectModel *)managedObjectModel {
//    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HZ85_Weibo" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return _managedObjectModel;
//}
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
//    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    // Create the coordinator and store
//    
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HZ85_Weibo.sqlite"];
//    NSError *error = nil;
//    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        // Report any error we got.
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
//        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
//        dict[NSUnderlyingErrorKey] = error;
//        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        // Replace this with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//
//- (NSManagedObjectContext *)managedObjectContext {
//    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (!coordinator) {
//        return nil;
//    }
//    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    return _managedObjectContext;
//}
//
//#pragma mark - Core Data Saving support
//
//- (void)saveContext {
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        NSError *error = nil;
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

@end
