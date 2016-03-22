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
#import "EMsgCilent.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
     [NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(245, 245, 245, 1), NSForegroundColorAttributeName, [UIFont fontWithName:@ "HelveticaNeue-CondensedBlack" size:19.0], NSFontAttributeName, nil]];
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
    [[EMsgCilent sharedInstance] logout];

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

- (void)autoLoginMsgCilent {
    ZXUser *userInfoModel = [ZXCommens fetchUser];
    if (userInfoModel.token) {
        //异步登陆账号
        EMsgCilent *client = [EMsgCilent sharedInstance];
        if (![client isAuthed]) {
            NSString *username =
            [NSString stringWithFormat:@"%@@%@/%@", userInfoModel.uid,
             userInfoModel.domain,
             [ZXCommens creatMSTimastmap]];
            
            BOOL successed =
            [client auth:username
            withPassword:userInfoModel.token
                withHost:userInfoModel.host
                withPort:[userInfoModel.port integerValue]];
            
            if (successed) //连接成功
            {
                
            } else { //连接失败
                [client autoReconnect];
            }
        }
    }
}

@end
