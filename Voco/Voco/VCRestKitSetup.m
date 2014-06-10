//
//  VCRestKitSetup.m
//  Voco
//
//  Created by Matthew Shultz on 6/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRestKitSetup.h"
#import "RestKit.h"
#import "VCApi.h"
#import "VCRiderApi.h"
#import "VCDriverApi.h"
#import "VCUsersApi.h"
#import "VCObjectRequestOperation.h"
#import "VCAppDelegate.h"

@implementation VCRestKitSetup

+ (void) setup {
    RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
    [objectManager registerRequestOperationClass:[VCObjectRequestOperation class]];

    [VCRiderApi setup: objectManager];
    [VCDriverApi setup: objectManager];
    [VCUsersApi setup: objectManager];
    
    objectManager.managedObjectStore = [((VCAppDelegate*)[UIApplication sharedApplication].delegate) managedObjectStore];

}

@end
