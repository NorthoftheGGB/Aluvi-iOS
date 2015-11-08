//
//  AccelerationDetector.m
//  GyrosAndAccelerometers
//
//  Created by Matthew Shultz on 3/7/15.
//  Copyright (c) 2015 Joe Hoffman. All rights reserved.
//

#import "AccelerationDetector.h"
#import <CoreMotion/CoreMotion.h>

@interface AccelerationDetector ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

AccelerationDetector * accelerationDetector;

static float x[1000];
static float y[1000];
static float z[1000];

@interface AccelerationDetector ()

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (nonatomic) double gravityX;
@property (nonatomic) double gravityY;
@property (nonatomic) double gravityZ;


@property (nonatomic) int index;

@property NSUserDefaults * defaults;

@end

@implementation AccelerationDetector

+ (AccelerationDetector *) instance {
    if(accelerationDetector == nil) {
        accelerationDetector = [[AccelerationDetector alloc] init];
    }
    return accelerationDetector;
}

- (AccelerationDetector *) init {
    self = [super init];
    if(self != nil){
        
        _defaults = [NSUserDefaults standardUserDefaults];
        
        _index = 0;
      
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = .2;
        
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                    _gravityX = motion.gravity.x;
                                                    _gravityY = motion.gravity.y;
                                                    _gravityZ = motion.gravity.z;
                                                }];
    }
    return self;
}


- (void) startAccelerometerUpdates:(id) obj {
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}


-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    
    // get device acceleration
    double deviceAcceleration[3] = {acceleration.x - _gravityX, acceleration.y - _gravityY, acceleration.z  - _gravityZ};
    double dot;
    double phi;
    
    // drop all accelleration in the direction of gravity
    dot = (deviceAcceleration[0]* _gravityX + deviceAcceleration[1] * _gravityY + deviceAcceleration[2] * _gravityZ);
    phi = dot / (_gravityX*_gravityX + _gravityY*_gravityY + _gravityZ*_gravityZ);
    double projOntoG[3] = {phi * _gravityX, phi * _gravityY, phi*_gravityZ};
    double deviceAccelerationXY[3] = {deviceAcceleration[0] - projOntoG[0],
        deviceAcceleration[1] - projOntoG[1],
        deviceAcceleration[2] - projOntoG[2]};
    
    // store for delayed upload
    x[_index] = deviceAccelerationXY[0];
    y[_index] = deviceAccelerationXY[1];
    z[_index] = deviceAccelerationXY[2];
    _index++;
    if(_index >= 1000){
        _index = 0;
        
    }
    
}

- (double) computeMagnitude:(double *) vector{
    double mag = sqrt( vector[0]*vector[0] +
                                        vector[1]*vector[1] +
                                        vector[2]*vector[2] );
    return mag;
}


//
// Set up Core Data for Storing Blocks
//


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy: [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicy]];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LoggingData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    
    // Find the fetched properties, and make them sorted...
    for (NSEntityDescription *entity in [_managedObjectModel entities]) {
        for (NSPropertyDescription *property in [entity properties]) {
            if ([property isKindOfClass:[NSFetchedPropertyDescription class]]) {
                NSFetchedPropertyDescription *fetchedProperty = (NSFetchedPropertyDescription *)property;
                NSFetchRequest *fetchRequest = [fetchedProperty fetchRequest];
                
                // Only sort by date if the destination entity actually has a "date" field
                if ([[[[fetchRequest entity] propertiesByName] allKeys] containsObject:@"date"]) {
                    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
                    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDate]];
                }
            }
        }
    }
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *userStoreURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"mobilelog.sqlite"];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:userStoreURL
                                                         options:@{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                                                   NSInferMappingModelAutomaticallyOption: @YES} error:&error]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Critical Error : User Data" message:@"Application has been updated, but database has not migrated.  Please contact support.  You may also delete and reinstall this application, but this will result in loss of data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
        [alert show];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self managedObjectContext];
    
    return _persistentStoreCoordinator;
}


- (NSURL *)applicationLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}





@end
