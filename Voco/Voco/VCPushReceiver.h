//
//  VCPushManager.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPushTokenKey @"PUSH_TOKEN_KEY"
#define kPushTokenPublishedKey @"PUSH_TOKEN_PUBLISHED"

@interface VCPushReceiver : NSObject

+ (void)registerForRemoteNotifications;
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler;
+ (void)handleTappedRemoteNotification:(NSDictionary *)payload;

@end
