//
//  VCLocalNotificationReceiver.h
//  Voco
//
//  Created by Matthew Shultz on 7/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCLocalNotificationReceiver : NSObject

+ (void) handleLocalNotification: (UILocalNotification *) notification;

@end
