//
//  Receipt.h
//  
//
//  Created by matthewxi on 8/27/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Receipt : NSManagedObject

@property (nonatomic, retain) NSNumber * ticketId;
@property (nonatomic, retain) NSNumber * receiptId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * date;

+ (RKEntityMapping * )createMappings:(RKObjectManager *)objectManager;

@end
