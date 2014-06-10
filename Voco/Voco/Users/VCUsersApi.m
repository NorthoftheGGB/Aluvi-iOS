//
//  VCUsersApi.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUsersApi.h"
#import "VCLogin.h"
#import "VCNewUser.h"
#import "VCForgotPasswordRequest.h"
#import "VCTokenResponse.h"
#import "VCDriverInterestedRequest.h"

@implementation VCUsersApi
+ (void) setup: (RKObjectManager *) objectManager {
   
    RKObjectMapping * loginMapping = [VCLogin getMapping];
    RKObjectMapping * loginRequestMapping = [loginMapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:loginRequestMapping objectClass:[VCLogin class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[VCTokenResponse getMapping]
                                                                                             method:RKRequestMethodPUT
                                                                                        pathPattern:API_LOGIN
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKObjectMapping * newUserMapping = [VCNewUser getMapping];
    RKObjectMapping * newUserRequestMapping = [newUserMapping inverseMapping];
    RKRequestDescriptor *newUserRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:newUserRequestMapping objectClass:[VCNewUser class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:newUserRequestDescriptor];
    
    
    RKResponseDescriptor * newUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                             method:RKRequestMethodPUT
                                                                                        pathPattern:API_USERS
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:newUserResponseDescriptor];
    
    RKRequestDescriptor *forgotPasswordRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[VCForgotPasswordRequest getMapping] objectClass:[VCForgotPasswordRequest class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:forgotPasswordRequestDescriptor];
    
    RKRequestDescriptor * driverInterestedRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[VCDriverInterestedRequest getMapping]
                                                                                                    objectClass:[VCDriverInterestedRequest class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:driverInterestedRequestDescriptor];

    
}

+ (void) login:( RKObjectManager *) objectManager email:(NSString*) email password: (NSString *) password
       success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCLogin * login = [[VCLogin alloc] init];
    login.email = email;
    login.password = password;
    [objectManager postObject:login path:API_LOGIN parameters:nil success:success failure:failure];
}

+ (void) createUser:( RKObjectManager *) objectManager
               name:(NSString*) name
              email:(NSString*) email
           password:(NSString*) password
              phone:(NSString*) phone
      referralCode:(NSString*) referralCode
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    
    VCNewUser * newUser = [[VCNewUser alloc] init];
    newUser.name = name;
    newUser.email = email;
    newUser.password = password;
    newUser.phone = phone;
    newUser.referralCode = referralCode;
    [objectManager postObject:newUser path:API_USERS parameters:nil success:success failure:failure];
}

+ (void) forgotPassword:( RKObjectManager *) objectManager email:(NSString*) email phone: (NSString *) phone
       success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCForgotPasswordRequest * forgotPasswordRequest = [[VCForgotPasswordRequest alloc] init];
    forgotPasswordRequest.email = email;
    forgotPasswordRequest.phone = phone;
    [objectManager postObject:forgotPasswordRequest path:API_FORGOT_PASSWORD parameters:nil
                      success:success failure:failure];
}

+ (void) driverInterested:( RKObjectManager *) objectManager
               name:(NSString*) name
              email:(NSString*) email
           region:(NSString*) region
              phone:(NSString*) phone
       driverReferralCode:(NSString*) driverReferralCode
            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    VCDriverInterestedRequest * driverInterestedRequest = [[VCDriverInterestedRequest alloc] init];
    driverInterestedRequest.email = email;
    driverInterestedRequest.name = name;
    driverInterestedRequest.phone = phone;
    driverInterestedRequest.region = region;
    driverInterestedRequest.driverReferralCode = driverReferralCode;
    [objectManager postObject:driverInterestedRequest path:API_DRIVER_INTERESTED parameters:nil
                      success:success failure:failure];
}
@end
