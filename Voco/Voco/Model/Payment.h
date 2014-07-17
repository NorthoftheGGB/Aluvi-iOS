//
//  Payment.h
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Payment : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * amountCents;
@property (nonatomic, retain) NSDate * capturedAt;
@property (nonatomic, retain) NSNumber * fare_id;
@property (nonatomic, retain) NSNumber * driver_id;
@property (nonatomic, retain) NSString * stripeChargeStatus;

@end
