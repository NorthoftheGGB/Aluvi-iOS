//
//  VCCommuterSettingsManager.h
//  Voco
//
//  Created by Matthew Shultz on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "Ticket.h"
#import "Route.h"

@interface VCCommuteManager : NSObject

@property (nonatomic, strong) CLLocation * home;
@property (nonatomic, strong) CLLocation * work;
@property (nonatomic, strong) NSString * homePlaceName;
@property (nonatomic, strong) NSString * workPlaceName;
@property (nonatomic, strong) NSString * pickupTime;
@property (nonatomic, strong) NSString * returnTime;
@property (nonatomic) BOOL driving;

+ (VCCommuteManager *) instance;

- (void) save:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;
- (void) reset;
- (void) load;
- (void) loadFromServer;
- (void) clear;
- (BOOL) hasSettings;

- (void) requestRidesFor:(NSDate *) tomorrow success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;
- (void) cancelRide:(Ticket *) ride success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;
- (void) cancelTrip:(NSNumber *) tripId success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;

@end
