//
//  VCObjectRequestOperation.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCObjectRequestOperation.h"
#import "VCUserStateManager.h"
#import "VCApiError.h"

@implementation VCObjectRequestOperation

- (id)initWithRequest:(NSURLRequest *)request responseDescriptors:(NSArray *)responseDescriptors {
    
    self = [super initWithRequest:request responseDescriptors:responseDescriptors];
    self.deletesOrphanedObjects = YES;
    return self;
}


- (void)setCompletionBlockWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure
{
    [super setCompletionBlockWithSuccess:^void(RKObjectRequestOperation *operation , RKMappingResult *mappingResult) {
        if (success) {
            success(operation, mappingResult);
        }
        
    }failure:^void(RKObjectRequestOperation *operation , NSError *error) {
        
        NSInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        switch (statusCode) {
            case 0: // No internet connection
            {
                // Notify user there is an internet connectivity problem
                // UI should be locked by reachability
                [WRUtilities showNetworkUnavailableMessage];
                [WRUtilities criticalError:error];
                error = nil;
            }
                break;
                
            case 400:
            {
                if([error.domain isEqualToString:@"org.restkit.RestKit.ErrorDomain"]
                   && error.code == -1011) {
                    
                    NSString * message;
                    
                    NSError * jsonError;
                    NSData *objectData = [ [error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey] dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonError];
                    if(json == nil){
                        message = @"No Message Available";
                    } else {
                        message = [json objectForKey:@"error"];
                    }
                     [UIAlertView showWithTitle:@"Error" message:message cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
                    error = nil;
                }

                
            }
                break;

            case 401: // not authenticated
            {
                [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
                [UIAlertView showWithTitle:@"Invalid Login" message:@"You are no longer logged into Voco.  Please log back in"
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      // Call logout and Bump the user back out to the login screen
                                      [[VCUserStateManager instance] clearUser];
                                  }];
                error = nil; // mark error as handled
            }
                break;
                
            case 402:
                // Handled by
                break;
                
            case 405:
                break;
                
            case 406:
            {
                
                [UIAlertView showWithTitle:@"Bad Request"
                                   message:[error debugDescription]
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil tapBlock:nil];
                
                [WRUtilities criticalError:error];
                error = nil;

            }
                break;
                
            default:
            {
                if(error != nil) {
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
