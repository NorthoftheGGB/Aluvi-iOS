//
//  VCGeolocation.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;


@interface VCGeolocation : NSObject

+ (VCGeolocation *) sharedGeolocation;
+ (CLLocation *) location;

- (id) init;
- (CLLocation *) location;
- (void) startSendingDriverLocation;

@end
