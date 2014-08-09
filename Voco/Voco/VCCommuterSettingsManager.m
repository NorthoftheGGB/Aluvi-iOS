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
        instance.origin = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteOriginSettingKey]];
        instance.destination = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteDestinationSettingKey]];
        instance.pickupTime = [defaults objectForKey:kCommuteDepartureTimeSettingKey];
        instance.returnTime = [defaults objectForKey:kCommuteReturnTimeSettingKey];
        instance.driving = [defaults boolForKey:kCommuterDrivingSettingKey];
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
}

- (void) setDriving:(BOOL)driving {
    _driving = driving;
}

- (void) save {
    NSData * originArchive = [NSKeyedArchiver archivedDataWithRootObject:_origin];
    [[NSUserDefaults standardUserDefaults] setObject:originArchive forKey:kCommuteOriginSettingKey];
    NSData * destinationArchive = [NSKeyedArchiver archivedDataWithRootObject:_destination];
    [[NSUserDefaults standardUserDefaults] setObject:destinationArchive forKey:kCommuteDestinationSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_pickupTime forKey:kCommuteDepartureTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_returnTime forKey:kCommuteReturnTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setBool:_driving forKey:kCommuterDrivingSettingKey];
}

- (void) reset {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    instance.origin = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteOriginSettingKey]];
    instance.destination = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteDestinationSettingKey]];
    instance.pickupTime = [defaults objectForKey:kCommuteDepartureTimeSettingKey];
    instance.returnTime = [defaults objectForKey:kCommuteReturnTimeSettingKey];
}

- (BOOL) hasSettings {
    if( instance.origin == nil || instance.destination == nil || instance.pickupTime == nil || instance.returnTime == nil){
        return NO;
    } else {
        return YES;
    }
}


@end
