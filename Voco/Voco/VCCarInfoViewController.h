//
//  VCCarInfoViewController.h
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCCarInfoViewController : UIView

@property (strong, nonatomic) IBOutlet UITextField *liscencePlateField;
@property (strong, nonatomic) IBOutlet UITextField *carInfoField;



- (IBAction)liscencePlateFieldDidEndOnExit:(id)sender;
- (IBAction)carInfoFieldDidEndOnExit:(id)sender;

@end
