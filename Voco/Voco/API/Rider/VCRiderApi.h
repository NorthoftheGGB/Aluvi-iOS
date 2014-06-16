//
//  VCRiderApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/27/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>
#import "Ride.h"

@interface VCRiderApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager;

+ (void) requestRide:(Ride *) ride
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;
    

@end
