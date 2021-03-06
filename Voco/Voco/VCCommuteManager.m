//
//  VCCommuterSettingsManager.m
//  Voco
//
//  Created by Matthew Shultz on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCommuteManager.h"
#import "Ticket.h"
#import "VCRidesApi.h"
#import "VCDriverApi.h"
#import "VCNotifications.h"
#import "VCUtilities.h"
#import "VCCommuterRideRequest.h"
#import "VCUserStateManager.h"

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

@interface VCCommuteManager ()
@property (nonatomic, strong) NSArray * activeTickets;

@end

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

- (id) init {
    self = [super init];
    if(self != nil){
        [self loadActiveTickets];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTickets:) name:kNotificationScheduleNeedsRefresh object:nil];
    }
    return self;
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
    if(![[VCUserStateManager instance] isLoggedIn]){
        return;
    }
    
    /*TODO
     Refactor: move API call to a API library file
     */
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
    [self refreshTickets];

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
    _activeTickets = nil;
}


- (void) refreshTickets:(NSNotification *) notifications {
    [self refreshTickets];
}

- (void) refreshTickets {
    [self refreshTicketsWithSuccess:nil failure:nil];
}

- (void) refreshTicketsWithSuccess:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure  {
    [VCRidesApi refreshScheduledRidesWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadActiveTickets];
        [VCNotifications scheduleUpdated];
        if(success != nil){
            success();
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure != nil){
            failure();
        }
    }];
}




- (void) requestRidesFor:(NSDate *) tomorrow success:(void ( ^ ) ()) success conflict:( void ( ^ ) ()) conflict paymentRequired:( void ( ^ ) ()) paymentRequired failure:( void ( ^ ) ()) failure {
    
    // Look for pre-existing request for tomorrow, error if it exists
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    
    // start by retrieving day, weekday, month and year components for the given day
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSDateComponents *tomorrowComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:tomorrow];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"rideDate > %@ && rideDate < %@ && state IN %@ ", thisDate, nextDate, @[kRequestedState, kScheduledState]];
    [fetch setPredicate:predicate];
    
    NSError * error;
    NSArray * rides = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    if(error != nil){
        [WRUtilities criticalError:error];
    }
    if([rides count] == 2){
        [UIAlertView showWithTitle:@"Recoverable Error" message:@"There are already rides scheduled for this day, this is a system error but can be recovered by canceling your commuter rides and requesting again" cancelButtonTitle:@"Do Nothing" otherButtonTitles:@[@"Clear"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex == 1){
                
                [self cancelTrip: ((Ticket *)rides[0]).trip_id success:^{
                     [UIAlertView showWithTitle:@"OK" message:@"OK" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                } failure:^{
                }];
               
            }
        }];
        failure();
    };
    if([rides count] == 1){
        [WRUtilities subcriticalErrorWithString:@"Orphaned commuter ride found. Autocleaning the database, should be OK to continue"];
        Ticket * ticket = rides[0];
        NSLog(@"%ld", (long)[ticket.ride_id integerValue]);
        [[VCCoreData managedObjectContext] deleteObject:rides[0]];
        [[VCCoreData managedObjectContext] save:&error];
        if(error != nil){
            [WRUtilities criticalError:error];
        }
    }
    
    // OK to proceed with ride creation and request
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    
    NSArray * pickupTimeParts = [_route.pickupTime componentsSeparatedByString:@":"];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    components = [[NSDateComponents alloc] init];
    [components setHour:[[f numberFromString:pickupTimeParts[0]] intValue] ];
    [components setMinute:[[f numberFromString:pickupTimeParts[1]] intValue]];
    [components setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate * homeToWorkRidePickupTime = [gregorian dateByAddingComponents:components toDate:thisDate options:0];
    
    pickupTimeParts = [_route.returnTime componentsSeparatedByString:@":"];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    components = [[NSDateComponents alloc] init];
    [components setHour:[[f numberFromString:pickupTimeParts[0]] intValue] + 12 ];
    [components setMinute:[[f numberFromString:pickupTimeParts[1]] intValue]];
    [components setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate * workToHomeRidePickupTime = [gregorian dateByAddingComponents:components toDate:thisDate options:0];
    
    VCCommuterRideRequest * request = [[VCCommuterRideRequest alloc] init];
    request.departureLatitude = [NSNumber numberWithDouble: [_route getDefaultOrigin].coordinate.latitude];
    request.departureLongitude = [NSNumber numberWithDouble: [_route getDefaultOrigin].coordinate.longitude];
    request.departurePlaceName = @"Pickup";
    request.destinationLatitude = [NSNumber numberWithDouble: _route.work.coordinate.latitude];
    request.destinationLongitude = [NSNumber numberWithDouble: _route.work.coordinate.longitude];
    request.destinationPlaceName = @"Work";
    request.pickupTime = homeToWorkRidePickupTime;
    request.returnPickupTime = workToHomeRidePickupTime;
    request.driving = [NSNumber numberWithBool:_route.driving];

    
    // And attempt to store the rides on the server
    // TODO: This will happen in single request to the server, which will create and supply the tickets
    [VCRidesApi requestRide:request
                    success:^(RKObjectRequestOperation *operation, RKMappingResult * response) {
                        [self loadActiveTickets];
                        [VCNotifications scheduleUpdated];
                        success();
    }
                    failure:^(RKObjectRequestOperation *operation, NSError *error) {

            NSInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            switch(statusCode){
                case 405:
                    conflict();
                    break;
                case 402:
                    paymentRequired();
                    break;
                default:
                    failure();
                    break;
            }
    }];
    
}

- (void) cancelRide:(Ticket *) ride success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    
    [VCRidesApi cancelRide:ride success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadActiveTickets];
        [VCNotifications scheduleUpdated];
        success();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (void) cancelTrip:(NSNumber *) tripId success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    [VCRidesApi cancelTrip:tripId success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadActiveTickets];
        [VCNotifications scheduleUpdated];
        success();
    } failure:failure];

}

- (void) ridesPickedUp:(Ticket *) ticket success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    [VCDriverApi ridersPickedUp:ticket.ride_id success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadActiveTickets];
        [VCNotifications scheduleUpdated];
        success();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [WRUtilities subcriticaError:error];
        failure();
    }];
}

- (void) ridesDroppedOff:(Ticket *) ticket success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure {
    [VCDriverApi ticketCompleted:ticket.ride_id success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadActiveTickets];
        [VCNotifications scheduleUpdated];
        success();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure();
    }];
}

///////////
///////////  Methods for Viewing Active Tickets
///////////


- (void) loadActiveTickets {
    if(![[VCUserStateManager instance] isLoggedIn]){
        _activeTickets = [NSArray array];
        return;
    }
    
    //set up filter by date > today at midnight.
    NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Ticket"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"( trip_state IN %@  \
                               AND pickupTime > %@ \
                               )",
                               @[kTripRequestedState, kTripFulfilledState],
                               [VCUtilities beginningOfToday]  ];
    [fetch setPredicate:predicate];
    NSSortDescriptor * sortTrip = [NSSortDescriptor sortDescriptorWithKey:@"trip_id" ascending:YES];
    NSSortDescriptor * sortTime = [NSSortDescriptor sortDescriptorWithKey:@"pickupTime" ascending:YES];
    [fetch setSortDescriptors:@[sortTrip, sortTime]];
    NSError * error;
    _activeTickets = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
    
    
    
}

- (BOOL) scheduledCommuteAvailable {
    if([_activeTickets count] > 0
       &&  [((Ticket *) _activeTickets[0]).trip_state isEqualToString:kTripFulfilledState]){
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) returnTicketValid {
    if([_activeTickets count] < 2){
        return false;
    }
    
    if( [((Ticket *) _activeTickets[0]).trip_id isEqualToNumber:((Ticket *) _activeTickets[1]).trip_id]){
        return YES;
    } else {
        [WRUtilities warningWithString:@"Mismatched trip ids"];
        return NO;
    }
}

- (Ticket *) getRequestedTripTicket {
    return _activeTickets[0];
}

- (Ticket *) getTicketToWork {
    return _activeTickets[0];
}

- (Ticket *) getTicketBackHome {
    return _activeTickets[1];
}

- (Ticket *) getDefaultTicket {
    if([self scheduledCommuteAvailable]){
        return _activeTickets[0];
    } else if([_activeTickets count] > 0) {
        return [self getRequestedTripTicket];
    } else {
        return nil;
    }
}



@end
