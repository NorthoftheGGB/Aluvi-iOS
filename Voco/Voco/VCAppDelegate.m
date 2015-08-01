//
//  VCAppDelegate.m
//  Voco
//
//  Created by Matthew Shultz on 5/20/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCAppDelegate.h"
#import <RestKit/RestKit.h>
#import <Stripe.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "VCRiderApi.h"
#import "VCDriverApi.h"
#import "VCPushReceiver.h"
#import "WRUtilities.h"
#import "VCApi.h"
#import "VCUserStateManager.h"
#import "VCDialogs.h"
#import "VCGeolocation.h"
#import "VCApi.h"
#import "VCInterfaceManager.h"
#import "VCMapQuestRouting.h"
#import "VCUsersApi.h"
#import "VCLocalNotificationReceiver.h"
#import "VCTicketViewController.h"
#import "VCDevicesApi.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface VCAppDelegate ()

@property (nonatomic) BOOL launching;

@end

@implementation VCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _launching = YES;

    [VCDebug sharedInstance];
#ifdef DEBUG
    [[VCDebug sharedInstance] enableAlerts];
#endif
    
    [VCApi setup];

    if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"Fabric"] != nil){
        [Fabric with:@[CrashlyticsKit]];
    }
    

    [VCDialogs instance];
    
    // GIS
    [VCGeolocation sharedGeolocation];
    [VCMapQuestRouting setup];
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1Ijoic25hY2tzIiwiYSI6Il83eXFHMzAifQ.M1ipZJb-b--TvC0vxHvPVg"];

    // Stripe
    [Stripe setDefaultPublishableKey:@"pk_test_4Gt6M02YRqmpk7yoBud7y5Ah"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    /*
        UIViewController * vc = [[ MyThing alloc] init];
        [self.window setRootViewController: vc];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
        return YES;
    */
    
#if DEBUG==12
    [[VCInterfaceModes instance] showDebugInterface];
#else
    [[VCInterfaceManager instance] showInterface];
#endif
    self.window.backgroundColor = [UIColor whiteColor];
    
// #warning bypassing interface mode setup in AppDelegate
    /*VCRideViewController * vc = [[VCRideViewController alloc] init];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window setRootViewController:nc];*/
    
   ///put background color and makeKeyVisible here
    
    NSLog(@"Registering for push notifications...");
#if !(TARGET_IPHONE_SIMULATOR)
    [VCPushReceiver registerForRemoteNotifications];
#endif
    
    if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil){
        [VCPushReceiver handleTappedRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    } else if( [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] != nil ) {
        UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        [VCLocalNotificationReceiver handleLocalNotification:localNotif];
    }
    
    // RKLogConfigureByName("RestKit/Network", RKLogLevelInfo);
    // RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    
    [self.window makeKeyAndVisible];

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
    
    if([[VCUserStateManager instance] isLoggedIn]){
        [[VCUserStateManager instance] synchronizeUserState];
    
        [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"%@", @"Refreshed Scheduled Rides");
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        }];

        [VCDevicesApi updateUserWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        }];

    }
    
    if(_launching == YES) {
        _launching = NO;
    } else {
    
#if !(TARGET_IPHONE_SIMULATOR)
        // Logic removed for triage
        BOOL pushTokenPublished = [[NSUserDefaults standardUserDefaults] boolForKey:kPushTokenPublishedKey];
        if(!pushTokenPublished){
            [VCPushReceiver registerForRemoteNotifications];
        }
#endif

    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [VCCoreData saveContext];
    
}



#pragma mark - Push Notifications
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [VCPushReceiver application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    [VCPushReceiver application:app didFailToRegisterForRemoteNotificationsWithError:err];
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // app is in foreground
    
    if ( application.applicationState == UIApplicationStateActive ) {
        [VCPushReceiver application:application didReceiveRemoteNotification:userInfo];
    } else {
        [VCPushReceiver handleTappedRemoteNotification:userInfo];
    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [VCLocalNotificationReceiver handleLocalNotification:notification];
}

-(BOOL)pushNotificationOnOrOff{
    
    BOOL pushEnabled=NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            pushEnabled=YES;
        }
        else
            pushEnabled=NO;
    }
    else
    {
        UIRemoteNotificationType types = [[UIApplication sharedApplication]        enabledRemoteNotificationTypes];
        if (types & UIRemoteNotificationTypeAlert)
            pushEnabled=YES;
        else
            pushEnabled=NO;
    }
    
    return pushEnabled;
}


@end
