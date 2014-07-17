//
//  VCCommuterPass.h
//  Voco
//
//  Created by Matthew Shultz on 7/17/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCFillCommuterPass : NSObject

@property(nonatomic, strong) NSNumber * amountCents;

+ (RKObjectMapping *) getMapping;

@end
