//
//  Transport.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "Transit.h"

@class Rider;
@class Ticket;

@interface Fare : Transit

@property (nonatomic, retain) NSNumber * car_id;
@property (nonatomic, retain) NSNumber * driveTime;
@property (nonatomic, retain) NSNumber * estimatedEarnings;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSSet *riders;
@property (nonatomic, retain) Ticket *ticket; //TODO: Not used at the moment because of no good place to assign to graph

+ (RKEntityMapping *)createMappings:(RKObjectManager *)objectManager;


- (NSString *) routeDescription;



@end


@interface Fare (CoreDataGeneratedAccessors)

- (void)addRidesObject:(Rider *)value;
- (void)removeRidersObject:(Rider *)value;
- (void)addRiders:(NSSet *)values;
- (void)removeRiders:(NSSet *)values;

@end