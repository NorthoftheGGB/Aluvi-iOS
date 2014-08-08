//
//  VCApiError.h
//  Voco
//
//  Created by Matthew Shultz on 7/22/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCApiError : NSObject

@property (nonatomic, strong) NSString * error;

+ (RKObjectMapping *) getMapping;

@end
