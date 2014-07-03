//
//  VCCommuterHud.h
//  Voco
//
//  Created by Matthew Shultz on 7/2/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCCommuterHud : UIView
@property (weak, nonatomic) IBOutlet UILabel *meetingPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *meetingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropOffPointLabel;

- (IBAction)didTapOk:(id)sender;
@end
