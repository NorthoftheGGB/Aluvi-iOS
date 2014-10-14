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
#import "VCApiError.h"

@implementation VCDriverApi

+ (void) setup: (RKObjectManager *) objectManager {
    
    [Offer createMappings:objectManager];
    [Fare createMappings:objectManager];
    [Earning createMappings:objectManager];
    
    {
        RKObjectMapping * mapping = [VCFareDriverAssignment getMapping];
        RKObjectMapping * requestMapping = [mapping inverseMapping];
        RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCFareDriverAssignment class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptorPostData];
        
        
        
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                 method:RKRequestMethodPOST
                                                                                            pathPattern:API_POST_RIDE_DECLINED
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
        
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:API_POST_RIDE_ACCEPTED
                                                                                                 keyPath:nil
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor2];
        
        RKResponseDescriptor * responseDescriptor3 = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:API_POST_DRIVER_CANCELLED
                                                                                                 keyPath:nil
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor3];
    }
    

    
    {
        RKObjectMapping * mapping = [VCDriverRegistration getMapping];
        RKObjectMapping * requestMapping = [mapping inverseMapping];
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCDriverRegistration class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptor];

    }
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[VCFareIdentity class] pathPattern:API_GET_DRIVER_FARE_PATH_PATTERN method:RKRequestMethodGET]];

    
    {
        RKObjectMapping * mapping = [VCFare getMapping];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                     method:RKRequestMethodPOST
                                                                                                pathPattern:API_POST_FARE_COMPLETED
                                                                                                    keyPath:nil
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }

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
    {
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:[VCApiError getMapping]                                                                                             method:RKRequestMethodPOST
                                                                                             pathPattern:API_DRIVER_REGISTRATION
                                                                                                 keyPath:nil
                                                                                             statusCodes:[NSIndexSet indexSetWithIndex:400]];
        [objectManager addResponseDescriptor:responseDescriptor2];
    }
    {
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:
                                                      [RKObjectMapping mappingForClass:[NSObject class]]                                                                                           method:RKRequestMethodPOST
                                                                                             pathPattern:API_DRIVER_REGISTRATION
                                                                                                 keyPath:nil
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor2];
    }
    
}

+ (void) registerDriverWithLicenseNumber: (NSString *) driversLicenseNumber
                                carBrand: (NSString *) carBrand
                                carModel: (NSString *) carModel
                                 carYear: (NSString *) carYear
                         carLicensePlate: (NSString *) carLicensePlate
                            referralCode: (NSString *) referralCode
                                 success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure{
    VCDriverRegistration * driverRegistration = [[VCDriverRegistration alloc] init];
    driverRegistration.driversLicenseNumber = driversLicenseNumber;
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

+ (void) loadFareDetails: (NSNumber *) fareId success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    VCFareIdentity * fareIdentity = [[VCFareIdentity alloc] init];
    fareIdentity.id = fareId;
    [[RKObjectManager sharedManager] getObject:fareIdentity
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

+ (void) acceptFare: (NSNumber *) fareId
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCFareDriverAssignment * assignment = [[VCFareDriverAssignment alloc] init];
    assignment.fareId = fareId;
    [[RKObjectManager sharedManager] postObject:assignment
                                           path:API_POST_RIDE_ACCEPTED
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            success(operation, mappingResult);
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            failure(operation, error);
                                        }];
}

+ (void) declineFare: (NSNumber *) fareId
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCFareDriverAssignment * assignment = [[VCFareDriverAssignment alloc] init];
    assignment.fareId = fareId;
    
    [[VCDebug sharedInstance] apiLog:@"API: Driver cancel ride"];
    [[RKObjectManager sharedManager] postObject:assignment
                                           path:API_POST_RIDE_DECLINED parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [[VCDebug sharedInstance] apiLog:@"API: Driver cancel ride success"];
                                            success(operation, mappingResult);
                                            
                                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [[VCDebug sharedInstance] apiLog:@"API: Driver cancel ride failure"];
                                            
                                            if(operation.HTTPRequestOperation.response.statusCode == 404){
                                                // ride is actually assigned to this driver already, can't be decline
                                                [[VCDebug sharedInstance] apiLog:@"API: Driver cancel ride failure - already assigned to the logged in driver"];
                                                
                                                [WRUtilities criticalErrorWithString:@"This ride is already assigned to the logged in driver.  It cannot be declined and must be cancelled instead"];
                                                failure(operation, error);
                                                
                                            } else if(operation.HTTPRequestOperation.response.statusCode == 403){
                                                [[VCDebug sharedInstance] apiLog:@"API: Driver cancel ride failure - ride isn't available anymore anyway, just continue"];
                                                // ride isn't available anymore anyway, just continue
                                                success(operation, nil); // It's actually a success from the viewpoint of the caller
                                            } else {
                                                [WRUtilities criticalError:error];
                                            }
                                        }];
}

+ (void) ridersPickedUp: (NSNumber *) fareId
                success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure

{
    VCFareDriverAssignment * rideIdentity = [[VCFareDriverAssignment alloc] init];
    rideIdentity.fareId = fareId;
      [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_RIDE_PICKUP parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
          success(operation, mappingResult);
      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
          failure(operation, error);
      }];
}

+ (void) fareCancelledByDriver: (NSNumber *) fareId
                       success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCFareDriverAssignment * rideIdentity = [[VCFareDriverAssignment alloc] init];
    rideIdentity.fareId = fareId;
    
     [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_DRIVER_CANCELLED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         success(operation, mappingResult);
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         failure(operation, error);
     }];
}

+ (void) fareCompleted: (NSNumber *) fareId
                       success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCFareDriverAssignment * rideIdentity = [[VCFareDriverAssignment alloc] init];
    rideIdentity.fareId = fareId;
    
    [[RKObjectManager sharedManager] postObject:rideIdentity path:API_POST_FARE_COMPLETED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
    
}




+ (void) refreshActiveRidesWithSuccess: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                               failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    // Update all rides for this user using RestKit entity
    [[RKObjectManager sharedManager] getObjectsAtPath:API_GET_ACTIVE_FARES parameters:nil
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
