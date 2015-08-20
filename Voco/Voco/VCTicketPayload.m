//
//  VCTicketPayload.m
//  Voco
//
//  Created by matthewxi on 8/11/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCTicketPayload.h"

@implementation VCTicketPayload

+ (RKObjectMapping*) getMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[VCTicketPayload class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"ride_id" : @"ticketId"
                                                  }];
    return mapping;
}

@end
