//
//  VCPushManager.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPushManager.h"
#import "VCDevice.h"
#import "WRUtilities.h"
#import "VCRideOffer.h"
#import "VCDialogs.h"
#import "VCUserState.h"

@implementation VCPushManager

+ (void) registerForRemoteNotifications {
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
}

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *str = [NSString
                     stringWithFormat:@"Device Token=%@",deviceToken];
    NSLog(@"%@", str);
    
    // update device registration
    NSUUID *uuidForVendor = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuid = [uuidForVendor UUIDString];
    
    // send PATCH
    
    VCDevice * device = [[VCDevice alloc] init];
    device.pushToken = [self stringFromDeviceTokenData: deviceToken];
    //device.userId = [NSNumber numberWithInt:1]; // TODO get the current logged in user
    // TODO once user logs in, need to update this as well
    [[RKObjectManager sharedManager] patchObject:device
                                            path: [NSString stringWithFormat:@"%@%@", API_DEVICES, uuid]
                                      parameters:nil
                                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                             NSLog(@"Push token accepted by server!");
                                             
                                         }
                                         failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                             NSLog(@"Failed send request %@", error);
                                             [WRUtilities criticalError:error];
                                             
                                             // TODO Re-transmit push token later
                                         }];
    
    
}


+ (NSString*) stringFromDeviceTokenData: (NSData *) deviceToken
{
    const char *data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy];
}


+ (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    // Need to keep trying to register somehow..
    NSString *str = [NSString stringWithFormat: @"Push Registration Error: %@", err];
    NSLog(@"%@", str);
    
    // try again
    [self performSelector:@selector(registerForRemoteNotifications) withObject:nil afterDelay:10 * NSEC_PER_SEC];
    [VCPushManager registerForRemoteNotifications];
}



+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSDictionary * aps = [userInfo objectForKey:@"aps"];
    for (id key in userInfo) {
        NSLog(@"recieved remote notification foreground key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    // App is in foreground
    //  Get offers
    if(true) { //condition
        [[RKObjectManager sharedManager] getObjectsAtPath:[VCApi getRideOffersPath:[VCUserState instance].userId]
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSLog(@"Got ride offers!");
                                                  
                                                  // save in database - done automatically by Entity Mapping
                                                  
                                                  // check state of the application
                                                  // for now just assume in drive mode if we get here
                                                  if([VCUserState driverIsAvailable]
                                                     && [[VCUserState instance].interfaceState isEqualToString:VC_INTERFACE_STATE_IDLE]){  // guard against invalid state
                                                      
                                                      [VCDialogs offerNextRideToDriver];
                                                  } 
                                                  
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Failed send request %@", error);
                                                  [WRUtilities criticalError:error];

                                                  // TODO Re-transmit push token later
                                              }];
    }
    
    
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    
    // start the process to update state
    // which for now will check BOTH the driver and rider state paths
    
    for (id key in userInfo) {
        NSLog(@"background key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    
    handler(UIBackgroundFetchResultNewData);
}



@end
