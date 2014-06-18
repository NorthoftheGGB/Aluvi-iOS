//
//  VCDevicesApi.h
//  Voco
//
//  Created by Matthew Shultz on 6/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCDevice.h"

@interface VCDevicesApi : NSObject

+ (void) updatePushToken: (NSString *) pushToken
                 success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                 failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) updateUserWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
                       failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

+ (void) patchDevice: (VCDevice *) device
             success:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success
             failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure;

@end
