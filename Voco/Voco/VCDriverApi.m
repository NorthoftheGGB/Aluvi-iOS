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
#import "VCTicketPayload.h"
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
    
    [Fare createMappings:objectManager];
    [Earning createMappings:objectManager];
    
    {
        RKObjectMapping * mapping = [VCFareDriverAssignment getMapping];
        RKObjectMapping * requestMapping = [mapping inverseMapping];
        RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCFareDriverAssignment class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptorPostData];
    }
    {
        RKObjectMapping * mapping = [VCTicketPayload getMapping];
        RKObjectMapping * requestMapping = [mapping inverseMapping];
        RKRequestDescriptor *requestDescriptorPostData = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[VCTicketPayload class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptorPostData];
    }
    
    
        
    {
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
    
    
    {
        RKObjectMapping * mapping = [VCFare getMapping];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                                     method:RKRequestMethodPOST
                                                                                                pathPattern:API_POST_RIDE_COMPLETED
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



+ (void) ridersPickedUp: (NSNumber *) ticketId
                success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure

{
    VCTicketPayload * ticketPayload = [[VCTicketPayload alloc] init];
    ticketPayload.ticketId = ticketId;
      [[RKObjectManager sharedManager] postObject:ticketPayload path:API_POST_RIDE_PICKUP parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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

+ (void) ticketCompleted: (NSNumber *) ticketId
                       success: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCTicketPayload * ticketPayload = [[VCTicketPayload alloc] init];
    ticketPayload.ticketId = ticketId;
    
    [[RKObjectManager sharedManager] postObject:ticketPayload path:API_POST_RIDE_COMPLETED parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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
