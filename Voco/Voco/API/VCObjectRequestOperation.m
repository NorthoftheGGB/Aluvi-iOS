//
//  VCObjectRequestOperation.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCObjectRequestOperation.h"

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
        
      //  [self connectionFailedWithOperation:operation];
        
        NSInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        
        switch (statusCode) {
            case 0: // No internet connection
            {
                // Notify user there is an internet connectivity problem
                // UI should be locked by reachability
                [UIAlertView showWithTitle:@"Network Unavailable" message:@"This application requires internet connectivity" cancelButtonTitle:@"OK'" otherButtonTitles:nil tapBlock:nil];
            }
                break;
            case  401: // not authenticated
            {
                [UIAlertView showWithTitle:@"Invalid Login" message:@"You are no longer logged into Voco.  Please log back in"
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      // Bump the user back out to the login screen
                                  }];
            }
                break;
                
            default:
            {
            }
                break;
        }

        
        if (failure) {
            failure(operation, error);
        }
        
    }];
}

- (void)connectionFailedWithOperation:(RKObjectRequestOperation *)operation
{
    //RKObjectRequestOperation *operation = (RKObjectRequestOperation *)notification.object;
    if (operation) {
        
        NSInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        
        switch (statusCode) {
            case 0: // No internet connection
            {
                // Notify user there is an internet connectivity problem
                // UI should be locked by reachability
                [UIAlertView showWithTitle:@"Network Unavailable" message:@"This application requires internet connectivity" cancelButtonTitle:@"OK'" otherButtonTitles:nil tapBlock:nil];
            }
                break;
            case  401: // not authenticated
            {
                [UIAlertView showWithTitle:@"Invalid Login" message:@"You are no longer logged into Voco.  Please log back in"
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      // Bump the user back out to the login screen
                                    }];
            }
                break;
                
            default:
            {
            }
                break;
        }
    }
}

@end
