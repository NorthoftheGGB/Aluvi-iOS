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
#import "VCPushApi.h"
#import "VCCoreData.h"
#import "Offer.h"

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
    // App is in foreground

    for (id key in userInfo) {
        NSLog(@"recieved remote notification foreground key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    NSString * type = [userInfo objectForKey:VC_PUSH_TYPE_KEY];
    if([type isEqualToString:@"ride_offer"]) {
        if(true) { //condition
            [[RKObjectManager sharedManager] getObjectsAtPath:[VCApi getRideOffersPath:[VCUserState instance].userId]
                                                   parameters:nil
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                          // save in database - done automatically by Entity Mapping
                                                          
                                                          // check state of the application
                                                          // for now just assume in drive mode if we get here
                                                          if([VCUserState driverIsAvailable]
                                                             && [[VCDialogs instance].interfaceState isEqualToString:VC_INTERFACE_STATE_IDLE]){  // guard against invalid state
                                                              
                                                              [[VCDialogs instance] offerNextRideToDriver];
                                                          }
                                                          
                                                      }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                          NSLog(@"Failed send request %@", error);
                                                          [WRUtilities criticalError:error];
                                                          
                                                          // TODO Re-transmit push token later
                                                      }];
        }
    } else if([type isEqualToString:@"ride_offer_closed"]){
        [[VCDialogs instance] retractOfferDialog: [userInfo objectForKey:VC_PUSH_OFFER_ID_KEY]];
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

+ (void)handleRemoteNotification:(NSDictionary *)payload {
    NSString * type = [payload objectForKey:VC_PUSH_TYPE_KEY];
    if([type isEqualToString:@"ride_offer"]){
        NSNumber * offer_id = [payload objectForKey:VC_PUSH_OFFER_ID_KEY];
        [[RKObjectManager sharedManager] getObjectsAtPath:[VCApi getRideOffersPath:[VCUserState instance].userId]
                                               parameters:nil
                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                      
                                                      if([VCUserState driverIsAvailable]
                                                         && [[VCDialogs instance].interfaceState isEqualToString:VC_INTERFACE_STATE_IDLE]){  // guard against invalid state
                                                          
                                                          NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Offer"];
                                                          NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id = %@", offer_id];
                                                          [request setPredicate:predicate];
                                                          NSError * error;
                                                          
                                                          NSArray * offers = [[VCCoreData managedObjectContext] executeFetchRequest:request error:&error];
                                                          if(offers == nil){
                                                              [WRUtilities criticalError:error];
                                                          } else if ([offers count] == 0) {
                                                              [UIAlertView showWithTitle:@"Ride not longer available" message:@"Sorry, that ride is no longer available" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                  //do nothing
                                                              }];
                                                          } else {
                                                              Offer * offer = [offers objectAtIndex:0];
                                                              [[VCDialogs instance] offerRideToDriver:offer];
                                                          }
                                                          
                                                      }
                                                      
                                                  }
                                                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                      NSLog(@"Failed send request %@", error);
                                                      [WRUtilities criticalError:error];
                                                      
                                                      // TODO Re-transmit push token later
                                                  }];
    }
}




@end
