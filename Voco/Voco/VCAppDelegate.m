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
#import "VCRidesApi.h"
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
#import "VCTicketViewController.h"
#import "VCDevicesApi.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "VCCommuteManager.h"


@interface VCAppDelegate ()

@property (nonatomic) BOOL launching;

@end

@implementation VCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Font debugging
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"FONT %@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
     */
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    
    _launching = YES;

    [VCDebug sharedInstance];

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
    [Stripe setDefaultPublishableKey:@"pk_test_qebkNcGfOXsQJ6aSrimJt3mf"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


    [[VCInterfaceManager instance] showInterface];
    self.window.backgroundColor = [UIColor whiteColor];
    

    
   ///put background color and makeKeyVisible here
    
    NSLog(@"Registering for push notifications...");
#if !(TARGET_IPHONE_SIMULATOR)
    [VCPushReceiver registerForRemoteNotifications];
#endif
    
    if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil){
        [VCPushReceiver handleTappedRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
#if DEBUG
    //RKLogConfigureByName("RestKit/Network", RKLogLevelInfo);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif
    
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
        
        [[VCCommuteManager instance] refreshTicketsWithSuccess:^{
            NSLog(@"%@", @"Refreshed Scheduled Rides");
        } failure:^{}];
    

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

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [VCPushReceiver handleTappedRemoteNotification:userInfo];
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
