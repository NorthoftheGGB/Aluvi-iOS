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

@property (nonatomic, strong) Route * route;


+ (VCCommuteManager *) instance;

- (void) storeCommuterSettings: (Route *) route success:(void ( ^ ) ()) success failure:( void ( ^ ) (NSString * errorMessage)) failure;
- (void) storeRoute: (NSArray *) polyline withRegion: (MBRegion *) region;

- (void) reset;
- (void) load;
- (void) loadFromServer;
- (void) clear;


- (void) requestRidesFor:(NSDate *) tomorrow success:(void ( ^ ) ()) success conflict:( void ( ^ ) ()) conflict paymentRequired:( void ( ^ ) ()) paymentRequired failure:( void ( ^ ) ()) failure;
- (void) cancelRide:(Ticket *) ride success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;
- (void) cancelTrip:(NSNumber *) tripId success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;
- (void) ridesPickedUp:(Ticket *) ticket success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;
- (void) ridesDroppedOff:(Ticket *) ticket success:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;
- (void) refreshTickets;
- (void) refreshTicketsWithSuccess:(void ( ^ ) ()) success failure:( void ( ^ ) ()) failure;


- (BOOL) scheduledCommuteAvailable;
- (BOOL) returnTicketValid;
- (Ticket *) getRequestedTripTicket;
- (Ticket *) getTicketToWork;
- (Ticket *) getTicketBackHome;
- (Ticket *) getDefaultTicket;


@end
