//
//  VCNotifications.m
//  Voco
//
//  Created by Matthew Shultz on 8/23/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCNotifications.h"

@implementation VCNotifications

+ (void) scheduleUpdated {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationScheduleUpdated object:nil userInfo:@{}];
}

+ (void) profileUpdated {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeProfileUpdated object:nil userInfo:@{}];
}

+ (void) userStateUpdated {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTypeUserStateUpdated object:nil userInfo:@{}];
}
@end
