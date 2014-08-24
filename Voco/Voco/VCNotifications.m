//
//  VCNotifications.m
//  Voco
//
//  Created by Matthew Shultz on 8/23/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCNotifications.h"

@implementation VCNotifications

+ (void) scheduledUpdated {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationScheduleUpdated object:nil userInfo:@{}];
}
@end
