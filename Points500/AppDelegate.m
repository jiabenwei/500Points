//
//  AppDelegate.m
//  Points500
//
//  Created by jiabenwei on 2017/10/23.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "AppDelegate.h"
#import "JWGuideViewController.h"
#import "JWMainViewController.h"
#import <JPUSHService.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerThirdPaty:application didFinishLaunchingWithOptions:launchOptions];
    JWMainViewController *mainVC = [[JWMainViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [self getData];
    [self.window setRootViewController:navigationController];
    return YES;
}

- (void)getData {
    BmobQuery *query = [[BmobQuery alloc] initWithClassName:@"Wanli"];
    [query getObjectInBackgroundWithId:@"UW64999O" block:^(BmobObject *object, NSError *error) {
        NSString *urlStr = [object objectForKey:@"wlpath"];
        NSString *isOn = [object objectForKey:@"fort"];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        if ([isOn isEqualToString:@"T"]) {
            [user setValue:urlStr forKey:@"Toggle"];
        }else {
            [user setValue:@"false" forKey:@"Toggle"];
        }
        if ([user synchronize]) {
            //发出通知
            NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
            [ns postNotificationName:@"JW" object:nil];
        }
    }];
}

- (void)registerThirdPaty:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Bmob registerWithAppKey:@"c32fac61acc5f8377eb6f5e48af64209"];
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = 0|1|2;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:nil];
    [JPUSHService setupWithOption:launchOptions appKey:@"9f04f2cc5427dc9f6c82290c" channel:@"jpush" apsForProduction:YES];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
