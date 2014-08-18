//
//  VCPushManager.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCPushReceiver.h"
#import "VCApi.h"
#import "VCDevicesApi.h"
#import "VCPushApi.h"
#import "VCRiderApi.h"
#import "VCDriverApi.h"
#import "VCNotifications.h"

#import "VCDevice.h"
#import "WRUtilities.h"
#import "VCDialogs.h"
#import "VCUserStateManager.h"
#import "VCCoreData.h"
#import "Offer.h"

@implementation VCPushReceiver

+ (void) registerForRemoteNotifications {
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
}

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    // send PATCH
    NSString * pushToken = [self stringFromDeviceTokenData: deviceToken];
    [VCDevicesApi updatePushToken:pushToken success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //TODO need to save and send again later
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
    [VCPushReceiver registerForRemoteNotifications];
}



+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App is in foreground
    for (id key in userInfo) {
        NSLog(@"recieved remote notification foreground key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    NSString * type = [userInfo objectForKey:VC_PUSH_TYPE_KEY];
    
    [[VCDebug sharedInstance] remoteNotificationLog: type];
    
    if([type isEqualToString:kPushTypeRideOffer]) {
        
        [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_FARE_OFFERS
                                               parameters:nil
                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                      // save in database - done automatically by Entity Mapping
                                                      
                                                      // check state of the application
                                                      // for now just assume in drive mode if we get here
                                                      if([VCUserStateManager driverIsAvailable]
                                                         && [[VCDialogs instance].interfaceState isEqualToString:VC_INTERFACE_STATE_IDLE]){  // guard against invalid state
                                                          
                                                          [[VCDialogs instance] offerNextFareToDriver];
                                                      }
                                                      
                                                  }
                                                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                      NSLog(@"Failed send request %@", error);
                                                      [WRUtilities criticalError:error];
                                                      
                                                      // TODO Re-transmit push token later
                                                  }];
        
    } else if([type isEqualToString:kPushTypeRideOfferClosed]){
        [[VCDialogs instance] retractOfferDialog: [userInfo objectForKey:VC_PUSH_OFFER_ID_KEY]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushTypeRideOfferClosed object:[userInfo objectForKey:VC_PUSH_FARE_ID_KEY] userInfo:@{}];
    } else {
        [self handleRemoteNotification:userInfo];
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

// Called when the user selected a remote notification from outside the application
+ (void)handleTappedRemoteNotification:(NSDictionary *)payload {
    NSString * type = [payload objectForKey:VC_PUSH_TYPE_KEY];
    if([type isEqualToString:kPushTypeRideOffer]){
        NSNumber * offer_id = [payload objectForKey:VC_PUSH_OFFER_ID_KEY];
        [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_FARE_OFFERS
                                               parameters:nil
                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                      
                                                      if([VCUserStateManager driverIsAvailable]
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
                                                              [[VCDialogs instance] offerFareToDriver:offer];
                                                          }
                                                          
                                                      }
                                                      
                                                  }
                                                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                      NSLog(@"Failed send request %@", error);
                                                      [WRUtilities criticalError:error];
                                                      
                                                      // TODO Re-transmit push token later
                                                  }];
    } else if ([type isEqualToString:kPushTypeRideFound]){
        [self handleRideFoundNotification:payload];
    } else {
        [self handleRemoteNotification:payload];
    }
}

+ (void) handleRemoteNotification:(NSDictionary *) payload {
    
    
    
    NSString * type = [payload objectForKey:VC_PUSH_TYPE_KEY];
    if ([type isEqualToString:kPushTypeRideFound]){
        [self handleRideFoundNotification: payload];
    } else if ([type isEqualToString:kPushTypeFareAssigned]){
        [self handleFareAssignedNotification: payload];
    } else if ([type isEqualToString:kPushTypeFareCancelledByRider]){
        NSNumber * rideId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
        if([[VCUserStateManager instance].underwayFareId isEqualToNumber:rideId]){
            [[VCDialogs instance] rideCancelledByRider];
            [VCUserStateManager instance].underwayFareId = nil;
            [VCUserStateManager instance].driveProcessState = kUserStateIdle;
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushTypeFareCancelledByRider object:rideId userInfo:@{}];
        }
    } else if([type isEqualToString:kPushTypeFareCancelledByDriver]){
        NSNumber * rideId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
        if([[VCUserStateManager instance].underwayFareId isEqualToNumber:rideId]){
            [[VCDialogs instance] rideCancelledByDriver];
            [VCUserStateManager instance].underwayFareId = nil;
            [VCUserStateManager instance].rideProcessState = kUserStateIdle;
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushTypeFareCancelledByDriver object:payload userInfo:@{}];
        }
    } else if([type isEqualToString:kPushTypeRideReceipt]){
        NSNumber * rideId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
        NSNumber * amount = [payload objectForKey:VC_PUSH_AMOUNT_KEY];
        if([[VCUserStateManager instance].underwayFareId isEqualToNumber:rideId]){
            [VCUserStateManager instance].underwayFareId = nil;
            [VCUserStateManager instance].rideProcessState = kUserStateIdle;
            [[VCDialogs instance] showRideReceipt:rideId amount:amount];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeFareComplete object:payload userInfo:@{}];
        }
    } else if([type isEqualToString:kPushTypeRidePaymentProblems]){
        NSNumber * rideId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
        if([[VCUserStateManager instance].underwayFareId isEqualToNumber:rideId]){
            [VCUserStateManager instance].underwayFareId = nil;
            [VCUserStateManager instance].rideProcessState = kUserStateIdle;
            [[VCDialogs instance] showRidePaymentProblem:rideId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeFareComplete object:payload userInfo:@{}];
        }
    } else if([type isEqualToString:kPushTypeNoDriversAvailable]){
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushTypeNoDriversAvailable object:payload userInfo:@{}];
    } else if([type isEqualToString:kPushTypeUserStateChanged]){
        [[VCUserStateManager instance] synchronizeUserState];
    } else if([type isEqualToString:kPushTypeTripFulfilled]){
        
        [[VCDialogs instance] commuteFulfilled];
        [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeTripFulfilled object:payload];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            //
        }];

    } else if([type isEqualToString:kPushTypeTripUnfulfilled]){
        
        [[VCDialogs instance] commuteUnfulfilled];
        [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            //
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            //
        }];

    } else {
#ifdef DEBUG
        [UIAlertView showWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid push type: %@", type] cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
#endif
    }
}

+ (void) handleRideFoundNotification:(NSDictionary *) payload {
    
    [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSNumber * rideId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
        NSFetchRequest * fetch = [[NSFetchRequest alloc] initWithEntityName:@"Ride"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ride_id = %@", rideId];
        [fetch setPredicate:predicate];
        NSError * error;
        NSArray * rides = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(rides == nil){
            [WRUtilities criticalError:error];
            return;
        }
        if([rides count] > 0){
            Ride * request = [rides objectAtIndex:0];
            
            if([request.rideType isEqualToString:kRideRequestTypeOnDemand]) {
                [[VCDialogs instance] rideFound: [payload objectForKey:VC_PUSH_RIDE_ID_KEY]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kPushTypeRideFound object:payload userInfo:@{}];
                [VCUserStateManager instance].underwayFareId = rideId;
            } else if ([request.rideType isEqualToString:kRideRequestTypeCommuter]){
                [[VCDialogs instance] commuterRideFound: request];
            }
            
            // TODO Any commuter ride that has not had an alarm set needs to have an alarm set here
            //      And additionally, any commuter ride that has not been delivered needs to be popped up as well
            if ([request.rideType isEqualToString:kRideRequestTypeCommuter]) {
                /*
                UILocalNotification * localNotif = [[UILocalNotification alloc] init];
                [localNotif setFireDate:[[NSDate date] dateByAddingTimeInterval:60]]; // demo/debug mode
                [localNotif setAlertBody:@"Commuter Pickup in 1 hour!"];
                [localNotif setAlertAction:@"View Map"];
                [localNotif setSoundName:UILocalNotificationDefaultSoundName];
                [localNotif setUserInfo:@{@"notification_type" : @"commuter_ride", @"request_id" : request.request_id}];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                 */
            }
        } else {
            [WRUtilities stateErrorWithString:@"Ride no longer exists"];
            
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities criticalError:error];
    }];
}

+ (void) handleFareAssignedNotification:(NSDictionary *) payload {
    [VCDriverApi refreshActiveRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSNumber * fareId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
        NSFetchRequest * fetch = [[NSFetchRequest alloc] initWithEntityName:@"Fare"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fare_id = %@", fareId];
        [fetch setPredicate:predicate];
        NSError * error;
        NSArray * rides = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(rides == nil){
            [WRUtilities criticalError:error];
            return;
        }
        if([rides count] > 0) {
            Fare * ride = rides.firstObject;
            [[VCDialogs instance] rideAssigned: ride];
            
        } else {
            [WRUtilities stateErrorWithString:@"Ride no longer exists"];
        }
        
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    
    }];
}




@end
