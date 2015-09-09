//
//  VCCarInfoViewController.m
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCCarInfoViewController.h"
#import <MBProgressHUD.h>
#import "VCStyle.h"
#import "VCUserStateManager.h"
#import "Car.h"
#import "VCDriverApi.h"

@interface VCCarInfoViewController ()
@property (strong, nonatomic) IBOutlet UITextField *licensePlateField;
@property (strong, nonatomic) IBOutlet UITextField *carInfoField;

@property (strong, nonatomic) Car * car;


- (IBAction)liscencePlateFieldDidEndOnExit:(id)sender;
- (IBAction)carInfoFieldDidEndOnExit:(id)sender;
- (IBAction)didTapSave:(id)sender;



@end

@implementation VCCarInfoViewController



- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self setGradient];

    NSNumber * carId = [VCUserStateManager instance].profile.carId;
    if(carId != nil){
        NSFetchRequest * fetch = [NSFetchRequest fetchRequestWithEntityName:@"Car"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id = %@", carId];
        [fetch setPredicate:predicate];
        NSError * error;
        NSArray * results = [[VCCoreData managedObjectContext] executeFetchRequest:fetch error:&error];
        if(results == nil){
            [WRUtilities criticalError:error];
        } else if ([results count] > 0){
            _car = [results objectAtIndex:0];
            
            _licensePlateField.text = _car.licensePlate;
            @try {
                _carInfoField.text = [NSString stringWithFormat:@"%@, %@, %@", _car.make, _car.model, _car.color ];
            }
            @catch (NSException *exception) {
                //
            }
            @finally {
                //
            }

        }
 
    }
    
    
    
}


- (IBAction)liscencePlateFieldDidEndOnExit:(id)sender {
}

- (IBAction)carInfoFieldDidEndOnExit:(id)sender {
}

- (IBAction)didTapSave:(id)sender {
    _car.licensePlate = _licensePlateField.text;
    NSArray * carInfo = [_carInfoField.text componentsSeparatedByString:@","];
    @try {
        _car.make = carInfo[0];
        _car.model = carInfo[1];
        _car.color = carInfo[2];
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        //
    }
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCDriverApi updateDefaultCar:_car success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        hud.hidden = YES;
        [VCCoreData saveContext];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [UIAlertView showWithTitle:@"Whoops" message:@"We had a problem.  Please try again" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        hud.hidden = YES;
    }];
    
    
    
}
@end
