//
//  VCCommuterSettingsManager.h
//  Voco
//
//  Created by Matthew Shultz on 8/9/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface VCCommuteManager : NSObject

@property (nonatomic, strong) CLLocation * home;
@property (nonatomic, strong) CLLocation * work;
@property (nonatomic, strong) NSString * homePlaceName;
@property (nonatomic, strong) NSString * workPlaceName;
@property (nonatomic, strong) NSString * pickupTime;
@property (nonatomic, strong) NSString * returnTime;
@property (nonatomic) BOOL driving;

+ (VCCommuteManager *) instance;

- (void) save;
- (void) reset;
- (BOOL) hasSettings;

- (void) requestRidesFor:(NSDate *) tomorrow;

@end
