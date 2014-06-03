//
//  VCCoreData.m
//  Voco
//
//  Created by Matthew Shultz on 6/2/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCoreData.h"
#import <CoreData.h>
#import "VCAppDelegate.h"

@implementation VCCoreData


+ (NSManagedObjectContext *) managedObjectContext {
    return [((VCAppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectContext];
}

+ (NSManagedObjectModel *) managedObjectModel {
    return [((VCAppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectModel];
}

+ (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    return [((VCAppDelegate *) [[UIApplication sharedApplication] delegate]) persistentStoreCoordinator];
}

+ (RKManagedObjectStore *) managedObjectStore{
    return [((VCAppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectStore];
}



@end
