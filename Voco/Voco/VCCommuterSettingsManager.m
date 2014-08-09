//
//  VCCommuterSettingsManager.m
//  Voco
//
//  Created by Matthew Shultz on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuterSettingsManager.h"

#define kCommuteOriginSettingKey @"kCommuterOriginSettingKey"
#define kCommuteDestinationSettingKey @"kCommuteDestinationSettingKey"
#define kCommuteDepartureTimeSettingKey @"kCommuteDepartureTimeSettingKey"
#define kCommuteReturnTimeSettingKey @"kCommuteReturnTimeSettingKey"
#define kCommuterDrivingSettingKey @"kCommuterDrivingSettingKey"

static VCCommuterSettingsManager * instance;

@implementation VCCommuterSettingsManager

+ (VCCommuterSettingsManager *) instance {
    if(instance == nil) {
        instance = [[VCCommuterSettingsManager alloc] init];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        instance.origin = [defaults objectForKey:kCommuteOriginSettingKey];
        instance.destination = [defaults objectForKey:kCommuteDestinationSettingKey];
        instance.pickupTime = [defaults objectForKey:kCommuteDepartureTimeSettingKey];
        instance.returnTime = [defaults objectForKey:kCommuteReturnTimeSettingKey];
    }
    return instance;
}

- (void) setOrigin:(CLLocation *) origin {
    _origin = origin;
}

- (void) setDestination:(CLLocation *)destination {
    _destination = destination;
}

- (void) setPickupTime:(NSString *)departureTime {
    _pickupTime = departureTime;
}

- (void) setReturnTime:(NSString *)returnTime {
    _returnTime = returnTime;
    [[NSUserDefaults standardUserDefaults] setObject:returnTime forKey:kCommuteReturnTimeSettingKey];
}

- (void) setDriving:(BOOL)driving {
    _driving = driving;
    [[NSUserDefaults standardUserDefaults] setBool:driving forKey:kCommuterDrivingSettingKey];
}

- (void) save {
    [[NSUserDefaults standardUserDefaults] setObject:_origin forKey:kCommuteOriginSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_destination forKey:kCommuteDestinationSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_pickupTime forKey:kCommuteDepartureTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_returnTime forKey:kCommuteReturnTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setBool:_driving forKey:kCommuterDrivingSettingKey];
}

- (void) reset {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    instance.origin = [defaults objectForKey:kCommuteOriginSettingKey];
    instance.destination = [defaults objectForKey:kCommuteDestinationSettingKey];
    instance.pickupTime = [defaults objectForKey:kCommuteDepartureTimeSettingKey];
    instance.returnTime = [defaults objectForKey:kCommuteReturnTimeSettingKey];
}

@end
