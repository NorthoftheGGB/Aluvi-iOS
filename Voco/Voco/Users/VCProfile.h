//
//  VCProfile.h
//  Voco
//
//  Created by Matthew Shultz on 7/16/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCProfile : NSObject

@property(nonatomic, strong) NSString * defaultCardToken;


+ (RKObjectMapping *) getMapping;
@end
