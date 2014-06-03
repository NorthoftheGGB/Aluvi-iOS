//
//  Offer.h
//  Voco
//
//  Created by Matthew Shultz on 6/2/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VCRestKitMappableObject.h"


@interface Offer : NSManagedObject <VCRestKitMappableObject>

@property (nonatomic, retain) NSNumber * ride_id;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * decided;
@property (nonatomic, retain) NSString * meetingPointPlaceName;
@property (nonatomic, retain) NSString * destinationPlaceName;
@end
