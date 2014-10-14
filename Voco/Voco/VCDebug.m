//
//  VCDebug.m
//  Voco
//
//  Created by Matthew Shultz on 7/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDebug.h"
#import "lelib.h"


#define kLoggedInUserIdentifier @"DEBUG_LOGGED_IN_USER_IDENTIFIER"

static VCDebug * instance;

@interface VCDebug ()

@property (nonatomic, strong) NSString * userIdentifier;

@end

@implementation VCDebug

+ (VCDebug *) sharedInstance {
    if (instance == nil){
        instance = [[VCDebug alloc] init];
    }
    return instance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        self.userIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserIdentifier];
    }
    return self;
}

- (void) setLoggedInUserIdentifier: (NSString *) identifier {
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:kLoggedInUserIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) clearLoggedInUserIdentifier {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoggedInUserIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) log:(NSString *) string {
    NSLog(@"Log: %@", string);
    //[[LELog sharedInstance] log:[NSString stringWithFormat:@"%@: %@", _userIdentifier, string]];
}

- (void) apiLog:(NSString *) string {
    [self log:[NSString stringWithFormat:@"API: %@", string]];
}

- (void) localNotificationLog:(NSString *) string {
    [self log:[NSString stringWithFormat:@"Local Notification: %@", string]];
}

- (void) remoteNotificationLog:(NSString *) string {
    [self log:[NSString stringWithFormat:@"Remote Notification: %@", string]];
}


@end
