//
//  VCDebug.h
//  Voco
//
//  Created by Matthew Shultz on 7/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPushTokenUpdatedNotification @"kPushTokenUpdatedNotification"

@interface VCDebug : NSObject

+ (void) showTriage;

+ (VCDebug *) sharedInstance;

- (void) setLoggedInUserIdentifier: (NSString *) identifier;
- (void) clearLoggedInUserIdentifier;

- (void) log:(NSString *) string;
- (void) apiLog:(NSString *) string;
- (void) localNotificationLog:(NSString *) string;
- (void) remoteNotificationLog:(NSString *) string;

@end
