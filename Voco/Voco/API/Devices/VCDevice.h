//
//  VCDevice.h
//  Voco
//
//  Created by Matthew Shultz on 5/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCDevice : NSObject

@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSString * pushToken;
@property (nonatomic, strong) NSString * appVersion;
@property (nonatomic, strong) NSString * appIdentifier;



+ (RKObjectMapping*) getMapping;

@end
