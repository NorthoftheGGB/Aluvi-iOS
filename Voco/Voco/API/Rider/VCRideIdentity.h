//
//  VCRideIdentity.h
//  Voco
//
//  Created by Matthew Shultz on 6/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCRideIdentity : NSObject

@property(nonatomic, strong) NSNumber * ticketId;

+ (RKObjectMapping *) getMapping;

@end
