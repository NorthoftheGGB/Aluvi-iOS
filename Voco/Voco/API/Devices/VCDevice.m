//
//  VCDevice.m
//  Voco
//
//  Created by Matthew Shultz on 5/28/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDevice.h"

@implementation VCDevice

- (id) init {
    self = [super init];
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    self.appVersion = [NSString stringWithFormat:@"v%@b%@", version, build];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    self.appIdentifier = appID;
    return self;
}

+ (RKObjectMapping*) getMapping {
    RKObjectMapping * deviceMapping = [RKObjectMapping mappingForClass:[VCDevice class]];
    [deviceMapping addAttributeMappingsFromDictionary:@{
                                                        @"user_id" : @"userId",
                                                        @"push_token" : @"pushToken",
                                                        @"app_version" : @"appVersion",
                                                        @"app_identifier" : @"appIdentifier"
                                                        }];
    return deviceMapping;

    
}

@end
