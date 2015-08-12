//
//  VCCommuterSettingsManager.m
//  Voco
//
//  Created by Matthew Shultz on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuteManager.h"
#import "Ticket.h"
#import "VCRiderApi.h"
#import "VCDriverApi.h"

// TODO refactor these out of this class
#import "VCApi.h"
#import <MBProgressHUD.h>

#define kCommuteOriginSettingKey @"kCommuterOriginSettingKey"
#define kCommuteDestinationSettingKey @"kCommuteDestinationSettingKey"
#define kCommutePickupZoneSettingKey @"kCommutePickupZoneSettingKey"
#define kCommuteDepartureTimeSettingKey @"kCommuteDepartureTimeSettingKey"
#define kCommuteReturnTimeSettingKey @"kCommuteReturnTimeSettingKey"
#define kCommuterDrivingSettingKey @"kCommuterDrivingSettingKey"
#define kCommuterOriginPlaceNameKey @"kCommuterOriginPlaceNameKey"
#define kCommuterDestinationPlaceNameKey @"kCommuterDestinationPlaceNameKey"
#define kCommuterPickupZonePlaceNameKey @"kCommuterPickupZonePlaceNameKey"
#define kCommuteRegionKey @"kCommuteRegionKey"
#define kCommutePolylineKey @"kCommutePolylineKey"

static VCCommuteManager * instance;

@implementation VCCommuteManager

+ (VCCommuteManager *) instance {
    if(instance == nil) {
        instance = [[VCCommuteManager alloc] init];
        
        RKObjectMapping * requestMapping = [Route getInverseMapping];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                                                                       objectClass:[Route class]
                                                                                       rootKeyPath:nil
                                                                                            method:RKRequestMethodPOST];
        [[RKObjectManager sharedManager] addRequestDescriptor:requestDescriptor];
        {
            RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[Route getMapping]
                                                                                                 method:RKRequestMethodPOST
                                                                                            pathPattern:API_ROUTE keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
            [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
        }
        {
            RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[Route getMapping]
                                                                                                     method:RKRequestMethodGET
                                                                                                pathPattern:API_ROUTE keyPath:nil
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
            [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
        }
        
        [instance load];

    }
    return instance;
}


// Load defaults and then load from web
- (void) load {
    _route = [[Route alloc] init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * home = [defaults objectForKey:kCommuteOriginSettingKey];
    if(home != nil) {
        _route.home = [NSKeyedUnarchiver unarchiveObjectWithData: home];
    }
    NSData * work = [defaults objectForKey:kCommuteDestinationSettingKey];
    if(work != nil) {
        _route.work = [NSKeyedUnarchiver unarchiveObjectWithData: work];
    }
    NSData * pickupZone = [defaults objectForKey:kCommutePickupZoneSettingKey];
    if(pickupZone != nil) {
        _route.pickupZoneCenter = [NSKeyedUnarchiver unarchiveObjectWithData: pickupZone];
    }
    _route.homePlaceName = [defaults objectForKey:kCommuterOriginPlaceNameKey];
    _route.workPlaceName = [defaults objectForKey:kCommuterDestinationPlaceNameKey];
    _route.pickupZoneCenterPlaceName = [defaults objectForKey:kCommuterPickupZonePlaceNameKey];
    _route.pickupTime = [defaults objectForKey:kCommuteDepartureTimeSettingKey];
    _route.returnTime = [defaults objectForKey:kCommuteReturnTimeSettingKey];
    _route.driving = [defaults boolForKey:kCommuterDrivingSettingKey];
    
    NSData * region = [defaults objectForKey:kCommuteRegionKey];
    if(region != nil) {
        _route.region = [NSKeyedUnarchiver unarchiveObjectWithData: region];
    }
    NSData * polyline = [defaults objectForKey:kCommutePolylineKey];
    if(polyline != nil) {
        _route.polyline = [NSKeyedUnarchiver unarchiveObjectWithData: polyline];
    }
    
    [self loadFromServer];
}

- (void) loadFromServer {
    
    /*TODO
     Refactor: move API call to a API library file
     */
    // overwrite if possible
    [[RKObjectManager sharedManager] getObject:nil
                                          path:API_ROUTE
                                    parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                        Route * storedRoute = mappingResult.firstObject;
                                        if( [storedRoute coordinatesDifferFrom: _route]  ){
                                            _route = storedRoute;
                                        } else {
                                            [_route copyNonCoordinateFieldsFrom: storedRoute];
                                        }
                                        [self store];

                                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                        // Woops!
                                    }];

}

- (void)store {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_route.home] forKey:kCommuteOriginSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_route.work] forKey:kCommuteDestinationSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_route.pickupZoneCenter] forKey:kCommutePickupZoneSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_route.pickupTime forKey:kCommuteDepartureTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_route.returnTime forKey:kCommuteReturnTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:_route.homePlaceName forKey:kCommuterOriginPlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:_route.workPlaceName forKey:kCommuterDestinationPlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:_route.pickupZoneCenterPlaceName forKey:kCommuterPickupZonePlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setBool:_route.driving forKey:kCommuterDrivingSettingKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_route.region] forKey:kCommuteRegionKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_route.polyline] forKey:kCommutePolylineKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) storeRoute: (NSArray *) polyline withRegion: (MBRegion *) region {
    _route.polyline = polyline;
    _route.region = region;
    [self store];
}


- (void) storeCommuterSettings: (Route *) route success:(void ( ^ ) ()) success failure:( void ( ^ ) (NSString * errorMessage)) failure {
    _route = route;

    /*TODO
     Refactor: move API call to a API library file
     Refactor local route persistance into Route class
     */
    [[RKObjectManager sharedManager] postObject:route
                                           path:API_ROUTE
                                     parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                         [self store];
                                         success();
                                         
                                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                         failure(@"Failed to store route,  please try again");
                                     }];
    
    


}

- (void) reset {
    [self load];
}

- (void) clear {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuteOriginSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuteDestinationSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommutePickupZoneSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuteDepartureTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuteReturnTimeSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuterOriginPlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuterDestinationPlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuterPickupZonePlaceNameKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCommuterDrivingSettingKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommuteRegionKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCommutePolylineKey];
    [[NSUserDefaults standardUserDefaults]  synchronize];
    _route = nil;
}



- (void) requestRidesFor:(NSDate *) tomorrow success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure  {
    // Look for pre-existing request for tomorrow, error if it exists
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    
    // start by retrieving day, weekday, month and year components for the given day
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"rideDate > %@ && rideDate < %@ && state IN %@ ", thisDate, nextDate, @[kCreatedState, kRequestedState, kScheduledState]];
    [fetch setPredicate:predicate];
    
    NSError * error;
    NSArray * rides = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    if(error != nil){
        [WRUtilities criticalError:error];
    }
    if([rides count] == 2){
        [WRUtilities subcriticalErrorWithString:@"There are already rides scheduled for this day, this is a system error but can be recovered by canceling your commuter rides and requesting again"];
        failure();
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
    
    Ticket * homeToWorkRide = (Ticket *) [NSEntityDescription insertNewObjectForEntityForName:@"Ticket" inManagedObjectContext:[VCCoreData managedObjectContext]];
    homeToWorkRide.rideDate = tomorrow;
    homeToWorkRide.originLatitude = [NSNumber numberWithDouble: _route.home.coordinate.latitude];
    homeToWorkRide.originLongitude = [NSNumber numberWithDouble: _route.home.coordinate.longitude];
    homeToWorkRide.originPlaceName = _route.homePlaceName;
    homeToWorkRide.originShortName = @"Home";
    homeToWorkRide.destinationLatitude = [NSNumber numberWithDouble: _route.work.coordinate.latitude];
    homeToWorkRide.destinationLongitude = [NSNumber numberWithDouble: _route.work.coordinate.longitude];
    homeToWorkRide.destinationPlaceName = _route.workPlaceName;
    homeToWorkRide.destinationShortName = @"Work";
    homeToWorkRide.rideType = kRideRequestTypeCommuter;
    homeToWorkRide.state = kCreatedState;
    homeToWorkRide.driving = [NSNumber numberWithBool:_route.driving];;
    NSArray * pickupTimeParts = [_route.pickupTime componentsSeparatedByString:@":"];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    components = [[NSDateComponents alloc] init];
    [components setHour:[[f numberFromString:pickupTimeParts[0]] intValue] ];
    [components setMinute:[[f numberFromString:pickupTimeParts[1]] intValue]];
    homeToWorkRide.pickupTime = [gregorian dateByAddingComponents:components toDate:thisDate options:0];
    
    Ticket * workToHomeRide = (Ticket *) [NSEntityDescription insertNewObjectForEntityForName:@"Ticket" inManagedObjectContext:[VCCoreData managedObjectContext]];
    workToHomeRide.rideDate = tomorrow;
    workToHomeRide.originLatitude =[NSNumber numberWithDouble: _route.work.coordinate.latitude];
    workToHomeRide.originLongitude = [NSNumber numberWithDouble: _route.work.coordinate.longitude];
    workToHomeRide.originPlaceName = _route.workPlaceName;
    workToHomeRide.originShortName = @"Work";
    workToHomeRide.destinationLatitude = [NSNumber numberWithDouble: _route.home.coordinate.latitude];
    workToHomeRide.destinationLongitude = [NSNumber numberWithDouble: _route.home.coordinate.longitude];
    workToHomeRide.destinationPlaceName = _route.homePlaceName;
    workToHomeRide.destinationShortName = @"Home";
    workToHomeRide.rideType = kRideRequestTypeCommuter;
    workToHomeRide.state = kCreatedState;
    workToHomeRide.driving = [NSNumber numberWithBool:_route.driving];
    pickupTimeParts = [_route.returnTime componentsSeparatedByString:@":"];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    components = [[NSDateComponents alloc] init];
    [components setHour:[[f numberFromString:pickupTimeParts[0]] intValue] + 12 ];
    [components setMinute:[[f numberFromString:pickupTimeParts[1]] intValue]];
    workToHomeRide.pickupTime = [gregorian dateByAddingComponents:components toDate:thisDate options:0];
    
    // And attempt to store the rides on the server
    // TODO: This will happen in single request to the server, which will create and supply the tickets
    [VCRiderApi requestRide:homeToWorkRide success:^(RKObjectRequestOperation *operation, VCRideRequestCreated * response) {
        homeToWorkRide.uploaded = [NSNumber numberWithBool:YES];
        homeToWorkRide.direction = @"a";
        homeToWorkRide.state = kRequestedState;
        
        workToHomeRide.trip_id = homeToWorkRide.trip_id;

        [VCRiderApi requestRide:workToHomeRide success:^(RKObjectRequestOperation *operation, VCRideRequestCreated * response) {
            workToHomeRide.uploaded = [NSNumber numberWithBool:YES];
            workToHomeRide.direction = @"b";
            homeToWorkRide.state = kRequestedState;

            [VCCoreData saveContext];
            
            [VCRiderApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                success();
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                // Not sure what to do here, the request has been posted, but the schedule failed to update
                failure();
            }];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            failure();
        }];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure();
    }];
    
}

- (void) cancelRide:(Ticket *) ride success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    
    void ( ^ deleteRide )( Ticket * );
    deleteRide = ^( Ticket * ride )
    {
        [[VCCoreData managedObjectContext] deleteObject:ride];
        NSError * error;
        [[VCCoreData managedObjectContext] save:&error];
        if(error != nil){
            [WRUtilities criticalError:error];
        }
    };
    
    
    if(ride.ride_id != nil) {
        if(ride.fare_id != nil && [ride.driving boolValue] ){
            [VCDriverApi fareCancelledByDriver:ride.fare_id success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                deleteRide(ride);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"schedule_updated" object:nil userInfo:@{}];
                success();
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [WRUtilities criticalError:error];
                failure();
            }];
        } else {
            [VCRiderApi cancelRide:ride success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                deleteRide(ride);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"schedule_updated" object:nil userInfo:@{}];
                success();
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [WRUtilities criticalError:error];
                failure();
            }];
        }
    } else {
        deleteRide(ride);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"schedule_updated" object:nil userInfo:@{}];
        success();
    }
}

- (void) cancelTrip:(NSNumber *) tripId success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    [VCRiderApi cancelTrip:tripId success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"schedule_updated" object:nil userInfo:@{}];
        success();
    } failure:failure];

}

- (void) ridesPickedUp:(Ticket *) ticket success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    [VCDriverApi ridersPickedUp:ticket.ride_id success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities subcriticaError:error];
        failure();
    }];
}



@end
