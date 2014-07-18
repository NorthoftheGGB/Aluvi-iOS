//
//  VCDriverApi.m
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverApi.h"
#import "VCApi.h"
#import "VCFareDriverAssignment.h"
#import "VCRideIdentity.h"
#import "Offer.h"
#import "VCGeoObject.h"
#import "VCDriverRegistration.h"
#import "Fare.h"
#import "VCFareIdentity.h"
#import "VCDriverGeoObject.h"
#import "VCFare.h"
#import "Earning.h"

@implementation VCDriverApi

+ (void) setup: (RKObjectManager *) objectManager {
    [VCFareDriverAssignment createMappings:objectManager];
    [VCRideIdentity createMappings:objectManager];
    [Offer createMappings:objectManager];
    [Fare createMappings:objectManager];
    [VCGeoObject createMappings:objectManager];
    [VCDriverGeoObject createMappings:objectManager];
    [VCDriverRegistration createMappings:objectManager];
    [VCFareIdentity createMappings:objectManager];
    [VCFare createMappings:objectManager];
    [Earning createMappings:objectManager];
    
    // Responses (some have not been moved here yet)
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSNull class]]
                                                     method:RKRequestMethodPOST
                                                pathPattern:API_DRIVER_CLOCK_ON
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSNull class]]
                                                     method:RKRequestMethodPOST
                                                pathPattern:API_DRIVER_CLOCK_OFF
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                              method:RKRequestMethodPOST
                                                                                         pathPattern:API_POST_RIDE_PICKUP
                                                                                             keyPath:nil
                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor2];
    }
    

}

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
                                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure{
    VCDriverRegistration * driverRegistration = [[VCDriverRegistration alloc] init];
    driverRegistration.driversLicenseNumber = driversLicenseNumber;
    driverRegistration.bankAccountName = bankAccountName;
    driverRegistration.bankAccountNumber = bankAccountNumber;
    driverRegistration.bankAccountRouting = bankAccountRouting;
    driverRegistration.carBrand = carBrand;
    driverRegistration.carModel = carModel;
    driverRegistration.carYear = carYear;
    driverRegistration.carLicensePlate = carLicensePlate;
    driverRegistration.referralCode = referralCode;
    [[RKObjectManager sharedManager] postObject:driverRegistration
                                           path:API_DRIVER_REGISTRATION
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            success(operation, mappingResult);
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            failure(operation, error);
                                        }];
    
}

+ (void) clockOnWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [[RKObjectManager sharedManager] postObject:nil path:API_DRIVER_CLOCK_ON parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            success(operation, mappingResult);
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            failure(operation, error);
                                        }];
}

+ (void) clockOffWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                     failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure{
    [[RKObjectManager sharedManager] postObject:nil path:API_DRIVER_CLOCK_OFF parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            success(operation, mappingResult);
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            failure(operation, error);
                                        }];
}

+ (void) loadDriveDetails: (NSNumber *) rideId success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    VCFareIdentity * rideIdentity = [[VCFareIdentity alloc] init];
    rideIdentity.id = rideId;
    //Drive * drive = [[Drive alloc] init];
    //drive.ride_id = rideId;
    [[RKObjectManager sharedManager] getObject:rideIdentity
                                          path:nil
                                    parameters:nil
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           NSLog(@"%@", @"Success");
                                           success(operation, mappingResult);
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           NSLog(@"%@", @"Failure");
                                           failure(operation, error);
                                       }];
}

+ (void) cancelRide: (NSNumber *) rideId
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCFareDriverAssignment * assignment = [[VCFareDriverAssignment alloc] init];
    assignment.rideId = rideId;
    
    [[RKObjectManager sharedManager] postObject:assignment
                                           path:API_POST_RIDE_DECLINED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            success(operation, mappingResult);
                                            
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            if(operation.HTTPRequestOperation.response.statusCode == 404){
                                                // ride is actually assigned to this driver already, can't be decline
                                                [WRUtilities criticalErrorWithString:@"This ride is already assigned to the logged in driver.  It cannot be declined and must be cancelled instead"];
                                                failure(operation, error);
                                                
                                            } else if(operation.HTTPRequestOperation.response.statusCode == 403){
                                                // ride isn't available anymore anyway, just continue
                                                success(operation, nil); // It's actually a success from the viewpoint of the caller
                                            } else {
                                                [WRUtilities criticalError:error];
                                            }
                                        }];
}

+ (void) refreshActiveRidesWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                               failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    // Update all rides for this user using RestKit entity
    [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_ACTIVE_RIDES parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  success(operation, mappingResult);
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  failure(operation, error);
                                                  
                                              }];
}

+ (void) earnings:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
          failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [[RKObjectManager sharedManager]  getObjectsAtPath:API_GET_EARNINGS
                                            parameters:nil
                                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                   success(operation, mappingResult);
                                               }
                                               failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                   failure(operation, error);
                                               }];
}

@end
