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
#import "VCPushManager.h"
#import "WRUtilities.h"
#import "VCApi.h"
#import "VCUserState.h"
#import "VCDialogs.h"
#import "VCGeolocation.h"
#import "VCApi.h"
#import "VCInterfaceModes.h"
#import "VCMapQuestRouting.h"
#import "VCUsersApi.h"

@interface VCAppDelegate ()

@end

@implementation VCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [VCApi setup];

#if RELEASE==1
    [Crashlytics startWithAPIKey:@"f7d1a0eeca165a46710d606ff21a38fea3c9ec43"];
#endif
    
#if TESTING==1
    [Crashlytics startWithAPIKey:@"f7d1a0eeca165a46710d606ff21a38fea3c9ec43"];
#endif
    
    [VCDialogs instance];
    
    // GIS
    [VCGeolocation sharedGeolocation];
    [VCMapQuestRouting setup];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
#if DEBUG==12
    [[VCInterfaceModes instance] showDebugInterface];
#else
    [[VCInterfaceModes instance] showInterface];
#endif
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    NSLog(@"Registering for push notifications...");

#if !(TARGET_IPHONE_SIMULATOR)
    [VCPushManager registerForRemoteNotifications];
#endif
    
    if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil){
        [VCPushManager handleTappedRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    } else if( [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] != nil ) {
        UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        NSNumber * requestId = [localNotif.userInfo objectForKey:@"request_id"];
        [[VCDialogs instance] commuterRideAlarm:requestId];
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

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if([[VCUserState instance] isLoggedIn]){
        [[VCUserState instance] synchronizeUserState];
    
        [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"%@", @"Refreshed Scheduled Rides");
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        }];
    }
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSNumber * requestId = [notification.userInfo objectForKey:@"request_id"];
    [[VCDialogs instance] commuterRideAlarm:requestId];
}



@end
