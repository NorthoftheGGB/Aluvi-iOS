//
//  VCAppDelegate.m
//  Voco
//
//  Created by Matthew Shultz on 5/20/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCAppDelegate.h"
#import <RestKit.h>
#import <Crashlytics/Crashlytics.h>
#import "VCRiderApi.h"
#import "VCDriverApi.h"
#import "RiderViewController.h"
#import "DriverViewController.h"
#import "VCPushManager.h"
#import "WRUtilities.h"
#import "VCApi.h"
#import "VCUserState.h"
#import "VCDialogs.h"
#import "VCGeolocation.h"
#import "VCApi.h"
#import "VCInterfaceModes.h"
#import "VCMapQuestRouting.h"

@interface VCAppDelegate ()

@property (nonatomic, strong) RiderViewController * riderViewController;

@end

@implementation VCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [VCApi setup];

    [Crashlytics startWithAPIKey:@"f7d1a0eeca165a46710d606ff21a38fea3c9ec43"];
    
    [VCDialogs instance];
    
    // GIS
    [VCGeolocation sharedGeolocation];
    [VCMapQuestRouting setup];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    [VCInterfaceModes showInterface];
    
    /*
    if([[VCUserState instance].userId isEqualToNumber:[NSNumber numberWithInt:1]]){
        self.window.rootViewController = [[DriverViewController alloc] init];
    } else{
        if([VCUserState instance].userId == nil ||  ![[VCUserState instance].userId isEqualToNumber:[NSNumber numberWithInt:3]]){
            [VCUserState instance].userId = [NSNumber numberWithInt:3];
        }
        self.window.rootViewController = [[RiderViewController alloc] init];
    }
    */
        
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    NSLog(@"Registering for push notifications...");

#if !(TARGET_IPHONE_SIMULATOR)
    [VCPushManager registerForRemoteNotifications];
#endif
    
    if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil){
        [VCPushManager handleTappedRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [VCCoreData saveContext];
    
}






#pragma mark - Push Notifications
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [VCPushManager application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    [VCPushManager application:app didFailToRegisterForRemoteNotificationsWithError:err];
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // app is in foreground
    
    if ( application.applicationState == UIApplicationStateActive ) {
        [VCPushManager application:application didReceiveRemoteNotification:userInfo];
    } else {
        [VCPushManager handleTappedRemoteNotification:userInfo];
    }
    
}

/*
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    // app is in background
    [VCPushManager application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
}
*/

@end
