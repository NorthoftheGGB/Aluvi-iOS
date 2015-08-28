//
//  Receipt.m
//  
//
//  Created by matthewxi on 8/27/15.
//
//

#import "Receipt.h"


@implementation Receipt

@dynamic ticketId;
@dynamic receiptId;
@dynamic type;
@dynamic amount;
@dynamic date;


+ (RKEntityMapping * )createMappings:(RKObjectManager *)objectManager{
    RKEntityMapping * entityMapping = [RKEntityMapping mappingForEntityForName:@"Receipt"
                                                          inManagedObjectStore: [VCCoreData managedObjectStore]];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"receipt_id" : @"receiptId",
                                                        @"ride_id" : @"ticketId",
                                                        @"type" : @"type",
                                                        @"amount" : @"amount",
                                                        @"date" : @"date"
                                                        }];
    
    entityMapping.identificationAttributes = @[ @"receiptId" ];
    
    return entityMapping;
}

@end
