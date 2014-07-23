//
//  VCObjectRequestOperation.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCObjectRequestOperation.h"
#import "VCUserState.h"
#import "VCApiError.h"

@implementation VCObjectRequestOperation

- (id)initWithRequest:(NSURLRequest *)request responseDescriptors:(NSArray *)responseDescriptors {
    
    return [super initWithRequest:request responseDescriptors:responseDescriptors];
}


- (void)setCompletionBlockWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure
{
    [super setCompletionBlockWithSuccess:^void(RKObjectRequestOperation *operation , RKMappingResult *mappingResult) {
        if (success) {
            success(operation, mappingResult);
        }
        
    }failure:^void(RKObjectRequestOperation *operation , NSError *error) {
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"connectionFailure" object:operation];
        
        NSInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        
        switch (statusCode) {
            case 0: // No internet connection
            {
                // Notify user there is an internet connectivity problem
                // UI should be locked by reachability
                [WRUtilities showNetworkUnavailableMessage];
                 
              
            }
                break;
                
            case 400:
            {
                VCApiError * apiError =  [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey][0];
                if(apiError != nil){
                    [UIAlertView showWithTitle:@"Error" message:apiError.error cancelButtonTitle:@"Oh, ok" otherButtonTitles:nil tapBlock:nil];
                } else {
                    [UIAlertView showWithTitle:@"Error" message:@"Unspecified Error" cancelButtonTitle:@"Ok, I'll try that again I guess" otherButtonTitles:nil tapBlock:nil];
                }
            }
                break;

            case 401: // not authenticated
            {
                [UIAlertView showWithTitle:@"Invalid Login" message:@"You are no longer logged into Voco.  Please log back in"
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      // Call logout and Bump the user back out to the login screen
                                      [[VCUserState instance] finalizeLogout];
                                  }];
            }
                break;
            case 406:
            {
                [UIAlertView showWithTitle:@"Bad Request"
                                   message:[error debugDescription]
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil tapBlock:nil];
            }
                
            default:
            {
                if(statusCode >= 500) {
                    [WRUtilities criticalError:error];
                }
            }
                break;
        }
        if (failure) {
            failure(operation, error);
        }
        
   
        
    }];
}
@end
