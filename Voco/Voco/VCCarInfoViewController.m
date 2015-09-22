//
//  VCCarInfoViewController.m
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCCarInfoViewController.h"
#import <MBProgressHUD.h>
#import "VCUserStateManager.h"
#import "VCUsersApi.h"
#import "Car.h"
#import "VCStyle.h"
#import "VCNotifications.h"

@interface VCCarInfoViewController ()
@property (strong, nonatomic) IBOutlet UITextField *licensePlateField;
@property (strong, nonatomic) IBOutlet UITextField *carInfoField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

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

- (void) viewWillAppear:(BOOL)animated {
    if(_delegate != nil){
        _cancelButton.hidden = NO;
    } else {
        _cancelButton.hidden = YES;
    }
}


- (IBAction)liscencePlateFieldDidEndOnExit:(id)sender {
    [_licensePlateField resignFirstResponder];
    [_carInfoField becomeFirstResponder];
}

- (IBAction)carInfoFieldDidEndOnExit:(id)sender {
    [_carInfoField resignFirstResponder];
    [self save];
}

- (IBAction)didTapSave:(id)sender {
    [self save];
}

- (void) save {
    if(_licensePlateField.text == nil
       || [_licensePlateField.text isEqualToString:@""]
       ){
        [UIAlertView showWithTitle:@"Error" message:@"You must enter the license plate" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    if(_carInfoField.text == nil
       || [_carInfoField.text isEqualToString:@""]
       ){
        [UIAlertView showWithTitle:@"Error" message:@"You must enter car info" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    //
    // Very sloppy handling of Cars here and in api
    // needs a refactor
    //
    _car = [Car new];
    _car.licensePlate = _licensePlateField.text;
    NSArray * carInfo = [_carInfoField.text componentsSeparatedByString:@","];
    @try {
        _car.make = carInfo[0];
        _car.model = carInfo[1];
        _car.color = carInfo[2];
    }
    @catch (NSException *exception) {
        [UIAlertView showWithTitle:@"Error" message:@"Car info should be formatted as 'Make, Model, Color'" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    @finally {
        //
    }
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[VCUserStateManager instance] updateDefaultCar:_car
                                            success:^() {
                                                [[VCCoreData managedObjectContext] deleteObject:_car]; // we aren't actually saving this one, just for mappping
                                                hud.hidden = YES;
                                                if(_delegate != nil){
                                                    [_delegate VCCarInfoViewControllerDidUpdateDetails:self];
                                                }

                                            }
                                            failure:^(NSString * errorMessage) {
                                                [[VCCoreData managedObjectContext] deleteObject:_car]; // we aren't actually saving this one, just for mapping
                                                [UIAlertView showWithTitle:@"Whoops" message:@"errorMessage" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                                hud.hidden = YES;
                                            }];
    
    
}

- (IBAction)didTapCancelButton:(id)sender {
    if(_delegate != nil){
        [_delegate VCCarInfoViewControllerDidCancel:self];
    }
}
@end
