//
//  VCCommuterSettingsManager.m
//  Voco
//
//  Created by Matthew Shultz on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuteManager.h"
#import "Ride.h"

#define kCommuteOriginSettingKey @"kCommuterOriginSettingKey"
#define kCommuteDestinationSettingKey @"kCommuteDestinationSettingKey"
#define kCommuteDepartureTimeSettingKey @"kCommuteDepartureTimeSettingKey"
#define kCommuteReturnTimeSettingKey @"kCommuteReturnTimeSettingKey"
#define kCommuterDrivingSettingKey @"kCommuterDrivingSettingKey"
#define kCommuterOriginPlaceNameKey @"kCommuterOriginPlaceNameKey"
#define kCommuterDestinationPlaceNameKey @"kCommuterDestinationPlaceNameKey"

static VCCommuteManager * instance;

@implementation VCCommuteManager

+ (VCCommuteManager *) instance {
    if(instance == nil) {
        instance = [[VCCommuteManager alloc] init];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        instance.home = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteOriginSettingKey]];
        instance.work = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteDestinationSettingKey]];
        instance.homePlaceName = [defaults objectForKey:kCommuterOriginPlaceNameKey];
        instance.workPlaceName = [defaults objectForKey:kCommuterDestinationPlaceNameKey];
        instance.pickupTime = [defaults objectForKey:kCommuteDepartureTimeSettingKey];
        instance.returnTime = [defaults objectForKey:kCommuteReturnTimeSettingKey];
        instance.driving = [defaults boolForKey:kCommuterDrivingSettingKey];
    }
    return instance;
}

- (void) setHome:(CLLocation *) origin {
    _home = origin;
}

- (void) setWork:(CLLocation *)destination {
    _work = destination;
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
    NSData * originArchive = [NSKeyedArchiver archivedDataWithRootObject:_home];
    [[NSUserDefaults standardUserDefaults] setObject:originArchive forKey:kCommuteOriginSettingKey];
    NSData * destinationArchive = [NSKeyedArchiver archivedDataWithRootObject:_work];
    [[NSUserDefaults standardUserDefaults] setObject:destinationArchive forKey:kCommuteDestinationSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_pickupTime forKey:kCommuteDepartureTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_returnTime forKey:kCommuteReturnTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_homePlaceName forKey:kCommuterOriginPlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:_workPlaceName forKey:kCommuterDestinationPlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setBool:_driving forKey:kCommuterDrivingSettingKey];
}

- (void) reset {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    instance.home = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteOriginSettingKey]];
    instance.work = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:kCommuteDestinationSettingKey]];
    instance.homePlaceName = [defaults objectForKey:kCommuterOriginPlaceNameKey];
    instance.workPlaceName = [defaults objectForKey:kCommuterDestinationPlaceNameKey];
    instance.pickupTime = [defaults objectForKey:kCommuteDepartureTimeSettingKey];
    instance.returnTime = [defaults objectForKey:kCommuteReturnTimeSettingKey];
}

- (BOOL) hasSettings {
    if( instance.home == nil || instance.work == nil || instance.pickupTime == nil || instance.returnTime == nil){
        return NO;
    } else {
        return YES;
    }
}

- (void) requestRidesFor:(NSDate *) tomorrow {
    // Look for pre-existing request for tomorrow, error if it exists
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
    
    // start by retrieving day, weekday, month and year components for the given day
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *tomorrowComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:tomorrow];
    NSInteger theDay = [tomorrowComponents day];
    NSInteger theMonth = [tomorrowComponents month];
    NSInteger theYear = [tomorrowComponents year];
    
    // now build a NSDate object for the input date using these components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    // build a NSDate object for aDate next day
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    
    // build the predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"rideDate > %@ && rideDate < %@", thisDate, nextDate];
    [fetch setPredicate:predicate];
    
    NSError * error;
    NSArray * rides = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    if(error != nil){
        [WRUtilities criticalError:error];
    }
    if([rides count] == 2){
        [WRUtilities subcriticalErrorWithString:@"There are already rides scheduled for this day, this is a system error but can be recovered by canceling your commuter rides and requesting again"];
        return;
    };
    if([rides count] == 1){
        [WRUtilities subcriticalErrorWithString:@"Orphaned commuter ride found. Autocleaning the database, should be OK to continue"];
        [[VCCoreData managedObjectContext] deleteObject:rides[0]];
        [[VCCoreData managedObjectContext] save:&error];
        if(error != nil){
            [WRUtilities criticalError:error];
        }
    }
    
    // OK to proceed with ride creation and request
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    
    Ride * homeToWorkRide = (Ride *) [NSEntityDescription insertNewObjectForEntityForName:@"Ride" inManagedObjectContext:[VCCoreData managedObjectContext]];
    homeToWorkRide.rideDate = tomorrow;
    homeToWorkRide.originLatitude = [NSNumber numberWithDouble: instance.home.coordinate.latitude];
    homeToWorkRide.originLongitude = [NSNumber numberWithDouble: instance.home.coordinate.longitude];
    homeToWorkRide.originPlaceName = _homePlaceName;
    homeToWorkRide.originShortName = @"Home";
    homeToWorkRide.destinationLatitude = [NSNumber numberWithDouble: instance.work.coordinate.latitude];
    homeToWorkRide.destinationLongitude = [NSNumber numberWithDouble: instance.work.coordinate.longitude];
    homeToWorkRide.destinationPlaceName = _workPlaceName;
    homeToWorkRide.destinationShortName = @"Work";
    homeToWorkRide.forcedState = kCreatedState;
    NSArray * pickupTimeParts = [_pickupTime componentsSeparatedByString:@":"];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [components setHour:[[f numberFromString:pickupTimeParts[0]] intValue] ];
    [components setMinute:[[f numberFromString:pickupTimeParts[1]] intValue]];
    homeToWorkRide.pickupTime = [gregorian dateFromComponents:components];
    
    Ride * workToHomeRide = (Ride *) [NSEntityDescription insertNewObjectForEntityForName:@"Ride" inManagedObjectContext:[VCCoreData managedObjectContext]];
    workToHomeRide.rideDate = tomorrow;
    workToHomeRide.originLatitude =[NSNumber numberWithDouble: instance.work.coordinate.latitude];
    workToHomeRide.originLongitude = [NSNumber numberWithDouble: instance.work.coordinate.longitude];
    workToHomeRide.originPlaceName = _workPlaceName;
    workToHomeRide.originShortName = @"Work";
    workToHomeRide.destinationLatitude = [NSNumber numberWithDouble: instance.home.coordinate.latitude];
    workToHomeRide.destinationLongitude = [NSNumber numberWithDouble: instance.home.coordinate.longitude];
    workToHomeRide.destinationPlaceName = _homePlaceName;
    workToHomeRide.destinationShortName = @"Home";
    workToHomeRide.forcedState = kCreatedState;
    pickupTimeParts = [_returnTime componentsSeparatedByString:@":"];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [components setHour:[[f numberFromString:pickupTimeParts[0]] intValue] + 12 ];
    [components setMinute:[[f numberFromString:pickupTimeParts[1]] intValue]];
    workToHomeRide.pickupTime = [gregorian dateFromComponents:components];
    
    [[VCCoreData managedObjectContext] save:&error];
    if(error != nil){
        [WRUtilities criticalError:error];
    }
    
}



@end
