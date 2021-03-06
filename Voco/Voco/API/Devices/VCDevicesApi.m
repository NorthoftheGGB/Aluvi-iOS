//
//  VCDevicesApi.m
//  Voco
//
//  Created by Matthew Shultz on 6/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDevicesApi.h"
#import "VCApi.h"

@implementation VCDevicesApi
+ (void) setup: (RKObjectManager *) objectManager {
    RKObjectMapping * mapping = [VCDevice getMapping];
    RKObjectMapping * transmitDeviceMapping = [mapping inverseMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:transmitDeviceMapping objectClass:[VCDevice class] rootKeyPath:nil method:RKRequestMethodPATCH];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                             method:RKRequestMethodPATCH
                                                                                        pathPattern:[VCApi devicesObjectPathPattern]
                                                                                            keyPath:nil
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

}

+ (void) updatePushToken: (NSString *) pushToken
                 success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure  {
    VCDevice * device = [[VCDevice alloc] init];
    device.pushToken = pushToken;

    [self patchDevice:device success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Push token accepted by server!");
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

// Send an empty device, the API token will identify and update the user of this device
+ (void) updateUserWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure  {
    [self patchDevice:[[VCDevice alloc] init] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

+ (void) patchDevice: (VCDevice *) device
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure  {
    
    // update device registration
    // NSUUID *uuidForVendor = [[UIDevice currentDevice] identifierForVendor];
    // NSString *uuid = [uuidForVendor UUIDString];
    
    NSString * uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    if(uuid == nil){
        uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"UUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // TODO once user logs in, need to update this as well
    [[RKObjectManager sharedManager] patchObject:device
                                        path: [NSString stringWithFormat:@"%@%@", API_DEVICES, uuid]
                                  parameters:nil
                                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                         NSLog(@"Device update accepted by server!");
                                         success(operation, mappingResult);
                                     }
                                     failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failed send request %@", error);
                                         failure(operation, error);
                                         // TODO Re-transmit push token later
                                     }];

}

@end
