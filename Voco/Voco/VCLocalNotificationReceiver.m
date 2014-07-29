//
//  VCLocalNotificationReceiver.m
//  Voco
//
//  Created by Matthew Shultz on 7/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLocalNotificationReceiver.h"
#import <UIAlertView+Blocks.h>
#import "VCDialogs.h"
#import "VCUserState.h"

@implementation VCLocalNotificationReceiver

+ (void) handleLocalNotification: (UILocalNotification *) notification {
    
    [[VCDebug sharedInstance] localNotificationLog: @"alarm"];

    
    if([VCUserState instance].underwayFareId != nil){
        [UIAlertView showWithTitle:@"Warning!" message:@"A ride is already underway! Tell a programmer you are experiencing a state problem!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
    //else {
        NSNumber * requestId = [notification.userInfo objectForKey:@"request_id"];
        [VCUserState instance].underwayFareId = requestId;
        [[VCDialogs instance] commuterRideAlarm:requestId];
    //}
}

@end
