//
//  VCNotifications.h
//  Voco
//
//  Created by Matthew Shultz on 8/23/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotificationScheduleUpdated @"schedule_updated"
#define kNotificationTypeTripFulfilled @"trip_fulfilled"
#define kNotificationTypeTripUnfulfilled @"trip_unfulfilled"

@interface VCNotifications : NSObject

+ (void) scheduledUpdated;

@end
