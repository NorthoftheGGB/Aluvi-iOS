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
#import "VCRidesApi.h"
#import "VCNotifications.h"
#import "VCInterfaceManager.h"
#import <MBProgressHUD.h>

#import "VCDevice.h"
#import "WRUtilities.h"
#import "VCDialogs.h"
#import "VCUserStateManager.h"
#import "VCCoreData.h"
#import "VCCommuteManager.h"

#import "VCDebug.h"


@implementation VCPushReceiver

+ (void) registerForRemoteNotifications {
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:kPushTokenPublishedKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPushTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil ]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication]
         registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert |
          UIRemoteNotificationTypeBadge |
          UIRemoteNotificationTypeSound)];
    }
    
#else
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
    
#endif
    
}

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    // send PATCH
    NSString * pushToken = [self stringFromDeviceTokenData: deviceToken];
    if(pushToken == nil || [pushToken isEqualToString:@""]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self registerForRemoteNotifications];
        });
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:kPushTokenKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [VCPushReceiver publishPushToken: pushToken];
    }
}

+ (void) publishPushToken: (NSString *) pushToken {
    [VCDevicesApi updatePushToken:pushToken success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:kPushTokenPublishedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushTokenUpdatedNotification object:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure to save push token to server");
        // and send again later
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:kPushTokenPublishedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self republishPushToken];
        });
    }];
}

+ (void) republishPushToken {
    NSString * pushToken = [[NSUserDefaults standardUserDefaults] stringForKey:kPushTokenKey];
    [self publishPushToken:pushToken];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self registerForRemoteNotifications];
    });
}



+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App is in foreground
    for (id key in userInfo) {
        NSLog(@"recieved remote notification foreground key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    NSString * type = [userInfo objectForKey:VC_PUSH_TYPE_KEY];
    
    [[VCDebug sharedInstance] remoteNotificationLog: type];
    
    
    [self handleRemoteNotification:userInfo];
    
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
    [self handleRemoteNotification:payload];
    
}

+ (void) handleRemoteNotification:(NSDictionary *) payload {
    
    if([VCDebug sharedInstance].blockPushMessages){
        // allow triage to block push messages
        return;
    }
    
    // Any remote notification should trigger a sync on the schedule
    // TODO: should refactor the below if/else to provide a block used in the Success of this
    // TODO: or perhaps refreshScheduledRides should not a take a success at all.
    // TODO: Or wait for sync for ANY handling of push
    
    NSString * type = [payload objectForKey:VC_PUSH_TYPE_KEY];
    MBProgressHUD * hud;
    if([@[kPushTypeTripFulfilled, kPushTypeTripUnfulfilled] containsObject:type]){
        hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [hud show:YES];
    }
    
    [[VCCommuteManager instance] refreshTicketsWithSuccess:^{
        [VCNotifications scheduleUpdated];
        if(hud != nil){
            hud.hidden = YES;
        }
        
        if ([type isEqualToString:kPushTypeFareCancelledByRider]){
            [[VCDialogs instance] rideCancelledByRider];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushTypeFareCancelledByRider object:payload userInfo:@{}];
            

        } else if([type isEqualToString:kPushTypeFareCancelledByDriver]){
            [[VCDialogs instance] rideCancelledByDriver];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushTypeFareCancelledByDriver object:payload userInfo:@{}];
            
           
        } else if([type isEqualToString:kPushTypeRidePaymentProblems]){
            NSNumber * rideId = [payload objectForKey:VC_PUSH_FARE_ID_KEY];
            [[VCDialogs instance] showRidePaymentProblem:rideId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeFareComplete object:payload userInfo:@{}];
            
        } else if([type isEqualToString:kPushTypeUserStateChanged]){
            [[VCUserStateManager instance] synchronizeUserState];
        } else if([type isEqualToString:kPushTypeTripFulfilled]){
            
            [[VCDialogs instance] commuteFulfilled];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeTripFulfilled object:payload];
            
        } else if([type isEqualToString:kPushTypeTripUnfulfilled]){
            
            [[VCDialogs instance] commuteUnfulfilled];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeTripUnfulfilled object:payload];
            
        } else if([type isEqualToString:kPushTypeGeneric]){
            NSString * message =[[payload objectForKey:@"aps" ] objectForKey:@"alert"];
            [UIAlertView showWithTitle:@"Message from Aluvi" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            
        } else if ([type isEqualToString:kPushTypeCommuteReminder]){
            
            [UIAlertView showWithTitle:@"Reminder!" message:@"Would you like to schedule a commute for tomorrow?" cancelButtonTitle:@"No" otherButtonTitles:@[@"YES!"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                switch(buttonIndex){
                    case 1:
                        [[VCInterfaceManager instance] showRiderInterface];
                        break;
                    default:
                        break;
                }
            }];
        } else if ([type isEqualToString:kPushTypeRideCompleted]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeFareComplete object:payload userInfo:@{}];
            
        } else if ([type isEqualToString:kPushTypeRiderWithdrew]) {
            
            NSString * message =[[payload objectForKey:@"aps" ] objectForKey:@"alert"];
            [UIAlertView showWithTitle:@"Rider Withdrew" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            
        } else {
#ifdef DEBUG
            [UIAlertView showWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid push type: %@", type] cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
#endif
        }
        

    } failure:^{
        if(hud != nil){
            hud.hidden = YES;
        }
    }];
}


+ (void) handleRideFoundNotification:(NSDictionary *) payload {
    [[VCCommuteManager instance] refreshTicketsWithSuccess:^{
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
            Ticket * request = [rides objectAtIndex:0];
            
            if ([request.rideType isEqualToString:kRideRequestTypeCommuter]){
                [[VCDialogs instance] commuterRideFound: request];
            }
            
            
        } else {
            [WRUtilities stateErrorWithString:@"Ride no longer exists"];
            
        }
    } failure:^{
        // nothing
    }];
    

}





@end
