//
//  VCDriverApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Car.h"

@interface VCDriverApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager ;



+ (void) ridersPickedUp: (NSNumber *) fareId
                success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;


+ (void) ticketCompleted: (NSNumber *) ticketId
                 success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;


@end
