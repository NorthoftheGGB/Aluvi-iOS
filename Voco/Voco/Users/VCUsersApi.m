//
//  VCUsersApi.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUsersApi.h"
#import "VCUserState.h"
#import "VCLogin.h"
#import "VCNewUser.h"
#import "VCForgotPasswordRequest.h"
#import "VCLoginResponse.h"
#import "VCDriverInterestedRequest.h"
#import "VCDriverStateResponse.h"
#import "VCUserStateResponse.h"

@implementation VCUsersApi
+ (void) setup: (RKObjectManager *) objectManager {
    
    RKObjectMapping * loginMapping = [VCLogin getMapping];
    RKObjectMapping * loginRequestMapping = [loginMapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:loginRequestMapping objectClass:[VCLogin class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[VCLoginResponse getMapping]
                                                                                             method:RKRequestMethodPOST
                                                                                        pathPattern:API_LOGIN
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKObjectMapping * newUserMapping = [VCNewUser getMapping];
    RKObjectMapping * newUserRequestMapping = [newUserMapping inverseMapping];
    RKRequestDescriptor *newUserRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:newUserRequestMapping objectClass:[VCNewUser class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:newUserRequestDescriptor];
    
    
    RKResponseDescriptor * newUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                    method:RKRequestMethodPOST
                                                                                               pathPattern:API_USERS
                                                                                                   keyPath:nil
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:newUserResponseDescriptor];
    
    RKRequestDescriptor *forgotPasswordRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[VCForgotPasswordRequest getMapping] inverseMapping] objectClass:[VCForgotPasswordRequest class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:forgotPasswordRequestDescriptor];
    RKResponseDescriptor * forgotPasswordResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                           method:RKRequestMethodPOST
                                                                                                      pathPattern:API_FORGOT_PASSWORD
                                                                                                          keyPath:nil
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:forgotPasswordResponseDescriptor];
    
    
    RKRequestDescriptor * driverInterestedRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[VCDriverInterestedRequest getMapping] inverseMapping]
                                          objectClass:[VCDriverInterestedRequest class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:driverInterestedRequestDescriptor];
    
    RKResponseDescriptor * driverInterestedResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[VCDriverStateResponse getMapping]
                                                 method:RKRequestMethodPOST
                                            pathPattern:API_DRIVER_INTERESTED
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:driverInterestedResponseDescriptor];
    

    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[VCUserStateResponse getMapping]
                                                     method:RKRequestMethodGET
                                                pathPattern:API_USER_STATE
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    
    
}

+ (void) login:( RKObjectManager *) objectManager phone:(NSString*) phone password: (NSString *) password
       success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    VCLogin * login = [[VCLogin alloc] init];
    login.phone = phone;
    login.password = password;
    [objectManager postObject:login path:API_LOGIN parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          
                          VCLoginResponse * tokenResponse = mappingResult.firstObject;
                          [VCApi setApiToken: tokenResponse.token];
                          
                          success(operation, mappingResult);
                      }
                      failure:failure];
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
                      success:^( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ) {
                          VCDriverStateResponse * response = mappingResult.firstObject;
                          [VCUserState instance].driverState = response.state;
                          success(operation, mappingResult);
                      }failure:failure];
}

+ (void) getUserState:( RKObjectManager *) objectManager
              success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
              failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [objectManager getObject:nil path:API_USER_STATE parameters:nil
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}
@end
