//
//  VCUsersApi.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCUsersApi.h"
#import "VCUserStateManager.h"
#import "VCNewUser.h"
#import "VCLoginResponse.h"
#import "VCDriverInterestedRequest.h"
#import "VCDriverStateResponse.h"
#import "VCUserStateResponse.h"
#import "VCFillCommuterPass.h"
#import "VCApiError.h"
#import "VCApi.h"
#import "Car.h"

@implementation VCUsersApi
+ (void) setup: (RKObjectManager *) objectManager {
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[VCLoginResponse getMapping]
                                                                                             method:RKRequestMethodPOST
                                                                                        pathPattern:API_LOGIN
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKObjectMapping * profileMapping = [VCProfile getMapping];
    RKObjectMapping * profileUpdateMapping = [profileMapping inverseMapping];
    profileUpdateMapping.assignsDefaultValueForMissingAttributes = NO;
    RKRequestDescriptor * profileRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:profileUpdateMapping objectClass:[VCProfile class] rootKeyPath:nil method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:profileRequestDescriptor];
    
    
    {
        RKObjectMapping * newUserMapping = [VCNewUser getMapping];
        RKObjectMapping * newUserRequestMapping = [newUserMapping inverseMapping];
        RKRequestDescriptor *newUserRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:newUserRequestMapping objectClass:[VCNewUser class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:newUserRequestDescriptor];
    }
    
    {
        RKResponseDescriptor * newUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[VCLoginResponse getMapping]
                                                                                                        method:RKRequestMethodPOST
                                                                                                   pathPattern:API_USERS
                                                                                                       keyPath:nil
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:newUserResponseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor2 = [RKResponseDescriptor responseDescriptorWithMapping:[VCApiError getMapping]                                                                                             method:RKRequestMethodPOST
                                                                                             pathPattern:API_USERS
                                                                                                 keyPath:nil
                                                                                             statusCodes:[NSIndexSet indexSetWithIndex:400]];
        [objectManager addResponseDescriptor:responseDescriptor2];
    }
    
    {
        RKResponseDescriptor * forgotPasswordResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSObject class]]
                                                                                                               method:RKRequestMethodPOST
                                                                                                          pathPattern:API_FORGOT_PASSWORD
                                                                                                              keyPath:nil
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:forgotPasswordResponseDescriptor];
    }
    
    {
        RKRequestDescriptor * driverInterestedRequestDescriptor =
        [RKRequestDescriptor requestDescriptorWithMapping:[[VCDriverInterestedRequest getMapping] inverseMapping]
                                              objectClass:[VCDriverInterestedRequest class]
                                              rootKeyPath:nil
                                                   method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:driverInterestedRequestDescriptor];
    }
    
    {
        RKResponseDescriptor * driverInterestedResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[VCDriverStateResponse getMapping]
                                                     method:RKRequestMethodPOST
                                                pathPattern:API_DRIVER_INTERESTED
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:driverInterestedResponseDescriptor];
    }
    
    {
        RKResponseDescriptor * responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[VCUserStateResponse getMapping]
                                                     method:RKRequestMethodGET
                                                pathPattern:API_USER_STATE
                                                    keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    
    {
        RKObjectMapping * fillCommuterPassMapping = [VCFillCommuterPass getMapping];
        RKObjectMapping * fillCommuterPassRequestMapping =  [fillCommuterPassMapping inverseMapping];
        RKRequestDescriptor * requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:fillCommuterPassRequestMapping objectClass:[VCFillCommuterPass class] rootKeyPath:nil method:RKRequestMethodPOST];
        [objectManager addRequestDescriptor:requestDescriptor];
    }
    
    {
        RKObjectMapping * mapping = [VCProfile getMapping];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:API_USER_PROFILE keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKObjectMapping * mapping = [Car createMappings:objectManager];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:API_USER_PROFILE keyPath:@"car" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    
    {
        RKObjectMapping * mapping = [VCProfile getMapping];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:API_USER_PROFILE keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKObjectMapping * mapping = [Car createMappings:objectManager];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:API_USER_PROFILE keyPath:@"car" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKObjectMapping * mapping = [VCProfile getMapping];
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:API_FILL_COMMUTER_PASS keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
        
    }
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSNull class]] method:RKRequestMethodPOST pathPattern:API_CREATE_SUPPORT_REQUEST keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSNull class]] method:RKRequestMethodPOST pathPattern:API_CREATE_SUPPORT_REQUEST keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    {
        RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKObjectMapping mappingForClass:[NSNull class]] method:RKRequestMethodPOST pathPattern:API_PAYOUT_REQUESTED keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        [objectManager addResponseDescriptor:responseDescriptor];
    }
    
}

+ (void) login:( RKObjectManager *) objectManager email:(NSString*) email password: (NSString *) password
       success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[VCDebug sharedInstance] apiLog:@"API: Login"];
    
    [objectManager postObject:nil path:API_LOGIN parameters:@{ @"email" : email, @"password" : password }
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          
                          
                          success(operation, mappingResult);
                      }
                      failure:^( RKObjectRequestOperation *operation , NSError *error ) {
                          [[VCDebug sharedInstance] apiLog:@"API: Login failure"];
                          failure(operation, error);
                      }];
}

+ (void) createUser:( RKObjectManager *) objectManager
          firstName:(NSString*) firstName
           lastName:(NSString*) lastName
              email:(NSString*) email
           password:(NSString*) password
              phone:(NSString*) phone
       referralCode:(NSString*) referralCode
             driver:(NSNumber*) driver

            success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    
    VCNewUser * newUser = [[VCNewUser alloc] init];
    newUser.firstName = firstName;
    newUser.lastName = lastName;
    newUser.email = email;
    newUser.password = password;
    newUser.phone = phone;
    newUser.referralCode = referralCode;
    newUser.driver = driver;
    [objectManager postObject:newUser path:API_USERS parameters:nil success:success failure:failure];
}

+ (void) forgotPassword:( RKObjectManager *) objectManager email:(NSString*) email
                success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [objectManager postObject:nil path:API_FORGOT_PASSWORD parameters:@{ @"email" : email }
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
                          [VCUserStateManager instance].driverState = response.state;
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

+ (void) updateDefaultCard: ( RKObjectManager *) objectManager
                 cardToken: (NSString *) token
                   success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                   failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    VCProfile * profile = [[VCProfile alloc] init];
    profile.defaultCardToken = token;
    [objectManager postObject:profile path:API_USER_PROFILE parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
        
    }];
}

+ (void) updateProfile: (VCProfile *) profile
               success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
               failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [[RKObjectManager sharedManager] postObject:profile path:API_USER_PROFILE parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
        
    }];
}

+ (void) getProfile: (void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [[RKObjectManager sharedManager] getObject:nil path:API_USER_PROFILE parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}


+ (void) fillCommuterPass:(NSNumber *) centsToAdd
                  success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                  failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    VCFillCommuterPass * fillCommuterPassObject = [[VCFillCommuterPass alloc] init];
    fillCommuterPassObject.amountCents = centsToAdd;
    
    [[RKObjectManager sharedManager] postObject:fillCommuterPassObject
                                           path:API_FILL_COMMUTER_PASS
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            success(operation, mappingResult);
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            failure(operation, error);
                                        }];
}

+ (void) updateRecipientCard: ( RKObjectManager *) objectManager
                   cardToken: (NSString *) token
                     success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                     failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    [objectManager postObject:nil path:API_USER_PROFILE parameters:@{@"default_recipient_debit_card_token" : token}
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          success(operation, mappingResult);
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          failure(operation, error);
                          
                      }];
    
}


+ (void) updateProfileImage:(UIImage *)image success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                    failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    NSMutableURLRequest *request =
    [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                             method:RKRequestMethodPOST
                                                               path:API_USER_PROFILE
                                                         parameters:nil
                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                              [formData appendPartWithFileData:UIImageJPEGRepresentation(image, .9)
                                                                          name:@"image"
                                                                      fileName:@"image.jpg"
                                                                      mimeType:@"image/jpg"];
                                          }];
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager]
                                           objectRequestOperationWithRequest:request
                                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                               success(operation, mappingResult);
                                               
                                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                               failure(operation, error);
                                           }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
    
}


+ (void) createSupportRequest:(NSString*) messageText
                      success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                      failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    NSDictionary * params = @{@"message" : messageText};
    [[RKObjectManager sharedManager] postObject:nil
                                           path:API_CREATE_SUPPORT_REQUEST
                                     parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                         success(operation, mappingResult);
                                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                         failure(operation, error);
                                     }];
    
    
}

+ (void) printReceiptsToEmailWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure  {
    
    [[RKObjectManager sharedManager] postObject:nil
                                           path:API_PRINT_RECEIPTS_TO_EMAIL
                                     parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                         success(operation, mappingResult);
                                         
                                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                         [WRUtilities criticalError:error];
                                         failure(operation, error);
                                     }];
    

}

+ (void) payoutRequestedWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                            failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure {
    
    [[RKObjectManager sharedManager] postObject:nil
                                           path:API_PAYOUT_REQUESTED
                                     parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                         success(operation, mappingResult);
                                         
                                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                         [WRUtilities criticalError:error];
                                         failure(operation, error);
                                     }];
}

@end
