//
//  VCUsersApi.h
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"

@interface VCUsersApi : NSObject

+ (void) setup: (RKObjectManager *) objectManager;

+ (void) login:( RKObjectManager *) objectManager phone:(NSString*) phone password: (NSString *) password
       success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) createUser:( RKObjectManager *) objectManager
               name:(NSString*) name
              email:(NSString*) email
           password:(NSString*) password
              phone:(NSString*) phone
       referralCode:(NSString*) referralCode
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) driverInterested:( RKObjectManager *) objectManager
                     name:(NSString*) name
                    email:(NSString*) email
                   region:(NSString*) region
                    phone:(NSString*) phone
       driverReferralCode:(NSString*) driverReferralCode
                  success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) forgotPassword:( RKObjectManager *) objectManager email:(NSString*) email phone: (NSString *) phone
                success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;
@end