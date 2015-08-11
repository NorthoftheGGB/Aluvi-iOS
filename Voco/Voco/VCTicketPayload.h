//
//  VCTicketPayload.h
//  Voco
//
//  Created by matthewxi on 8/11/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCTicketPayload : NSObject


@property (nonatomic, strong) NSNumber * ticketId;

+ (RKObjectMapping*) getMapping;


@end
