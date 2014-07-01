//
//  VCDriveIdentity.m
//  Voco
//
//  Created by Matthew Shultz on 6/30/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriveIdentity.h"
#import "VCApi.h"

@implementation VCDriveIdentity

+ (void)createMappings:(RKObjectManager *)objectManager {

    //Drive Request
    [objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[VCDriveIdentity class] pathPattern:API_GET_DRIVER_RIDE_PATH_PATTERN method:RKRequestMethodGET]];
}
@end
