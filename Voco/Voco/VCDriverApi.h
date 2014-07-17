//
//  VCDriverApi.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>


@interface VCDriverApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager ;
+ (void) registerDriverWithLicenseNumber: (NSString *) driversLicenseNumber
                         bankAccountName: (NSString *) bankAccountName
                       bankAccountNumber: (NSString *) bankAccountNumber
                      bankAccountRouting: (NSString *) bankAccountRouting
                                carBrand: (NSString *) carBrand
                                carModel: (NSString *) carModel
                                 carYear: (NSString *) carYear
                         carLicensePlate: (NSString *) carLicensePlate
                            referralCode: (NSString *) referralCode
                                 success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;
+ (void) clockOnWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;
+ (void) clockOffWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;
+ (void) loadDriveDetails: (NSNumber *) rideId
                  success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;
+ (void) cancelRide: (NSNumber *) rideId
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;
+ (void) refreshActiveRidesWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                               failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

@end
