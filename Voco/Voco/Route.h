//
//  Route.h
//  Voco
//
//  Created by Matthew Shultz on 10/26/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface Route : NSObject <NSCopying>

@property (nonatomic, strong) CLLocation * home;
@property (nonatomic, strong) CLLocation * work;
@property (nonatomic, strong) NSString * homePlaceName;
@property (nonatomic, strong) NSString * workPlaceName;
@property (nonatomic, strong) NSString * pickupTime;
@property (nonatomic, strong) NSString * returnTime;
@property (nonatomic) BOOL driving;


+ (RKObjectMapping *) getMapping;
+ (RKObjectMapping *) getInverseMapping;


@end
