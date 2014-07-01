//
//  Transport.h
//  Voco
//
//  Created by Matthew Shultz on 5/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCTransport.h"

@interface Drive : VCTransport

@property (nonatomic, retain) NSNumber * car_id;


+ (void)createMappings:(RKObjectManager *)objectManager;

@end
