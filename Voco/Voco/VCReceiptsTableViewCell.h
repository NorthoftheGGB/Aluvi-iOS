//
//  VCReceiptsTableViewCell.h
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCReceiptsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *receiptDate;

@property (strong, nonatomic) IBOutlet UILabel *receiptTripType;

@property (strong, nonatomic) IBOutlet UILabel *receiptTripTotalFare;

@end
