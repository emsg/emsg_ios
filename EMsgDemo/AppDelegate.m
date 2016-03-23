//
//  AppDelegate.m
//  EMsgDemo
//
//  Created by Hawk on 16/3/16.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "AppDelegate.h"
#import "EMDMainViewController.h"
#import "EMDLoginViewController.h"
#import "EMDEngineManger.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //注册推送
    [self registerRemoteNotification];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    [self configNavigationBar];
    [self loginStateChange:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:LOGIN_STATE object:nil];
    // Override point for customization after application launch.
    return YES;
}

- (void)configNavigationBar{
    [[UINavigationBar appearance] setBarTintColor:BASE_COLOR];
    [[UINavigationBar appearance] setTintColor:RGBACOLOR(245, 245, 245, 1)];  
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(245, 245, 245, 1), NSForegroundColorAttributeName, [UIFont systemFontOfSize:19.f], NSFontAttributeName, nil]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)loginStateChange:(NSNotification *)notification{
    if (notification == nil) {
        if ([ZXCommens isLogin]) {
            EMDMainViewController * mainVC = [[EMDMainViewController alloc] init];
            self.window.rootViewController = mainVC;
        }
        else{
            self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[EMDLoginViewController alloc] init]];
        }
        return ;
    }
    BOOL isState = [notification.object boolValue];
    [ZXCommens putLoginState:isState];
    if (isState) {
        EMDMainViewController * mainVC = [[EMDMainViewController alloc] init];
        self.window.rootViewController = mainVC;
    }
    else{
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[EMDLoginViewController alloc] init]];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMDEngineManger sharedInstance] logout];
    application.applicationIconBadgeNumber = 0;

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self autoLoginMsgCilent];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//如果注册APNs成功，此代理方法则会返回DeviceToken
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //获取device，放在本地
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    [ZXCommens putDeviceToken:token];
}

// 注册deviceToken失败，一般是环境配置或者证书配置有误
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"apns.failToRegisterApns",
                                                          Fail to register apns)
                          message:error.description
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                          otherButtonTitles:nil];
    [alert show];
}

// 注册APNs的方法
- (void)registerRemoteNotification {
#if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    // iOS8 注册APNS
    if ([application
         respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:notificationTypes
                                          categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication]
         registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
}

//#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //点击消息tabbar，就把icon的计数清零
//    UIApplication *application1 = [UIApplication sharedApplication];
//    application1.applicationIconBadgeNumber = application1.applicationIconBadgeNumber + 1;
    
    /**
     *  sholdPush 设置为YES 不显示友盟弹出框，  设置为NO 显示退推送弹出框
     */
    //    [[UMFeedback sharedInstance] setFeedbackViewController:nil shouldPush:NO];
    
    //友盟推送
    //    [UMessage didReceiveRemoteNotification:userInfo];
    
    //友盟反馈
    //    [UMFeedback didReceiveRemoteNotification:userInfo];
    
    if (application.applicationState == UIApplicationStateActive) {
        //程序当前正处于前台
    }
    else if(application.applicationState == UIApplicationStateInactive)
    {
        //程序处于后台
        
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
    if (application.applicationState !=UIApplicationStateActive)
    {
        
    }
    
}
//#endif

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

- (void)autoLoginMsgCilent {
    ZXUser *userInfoModel = [ZXCommens fetchUser];
    if (userInfoModel.token) {
        //异步登陆账号
        EMDEngineManger * engine = [EMDEngineManger sharedInstance];
        if (![engine isAuthed]) {
            NSString *username =
            [NSString stringWithFormat:@"%@@%@/%@", userInfoModel.uid,
             userInfoModel.domain,
             userInfoModel.uid];
            
            BOOL successed =
            [engine auth:username
            withPassword:userInfoModel.token
                withHost:userInfoModel.host
                withPort:[userInfoModel.port integerValue]];
            
            if (successed) //连接成功
            {
                
            } else { //连接失败
                [engine autoReconnect];
            }
        }
    }
}

@end
