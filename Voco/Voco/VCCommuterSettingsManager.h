//
//  VCCommuterSettingsManager.h
//  Voco
//
//  Created by Matthew Shultz on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface VCCommuterSettingsManager : NSObject

@property (nonatomic, strong) CLLocation * origin;
@property (nonatomic, strong) CLLocation * destination;
@property (nonatomic, strong) NSString * pickupTime;
@property (nonatomic, strong) NSString * returnTime;
@property (nonatomic) BOOL driving;

+ (VCCommuterSettingsManager *) instance;

- (void) save;
- (void) reset;
- (BOOL) hasSettings;

@end
