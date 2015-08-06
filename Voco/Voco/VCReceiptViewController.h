//
//  VCReceiptsView.h
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCReceiptViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *receiptViewTable;


- (IBAction)didTouchPrintReceipts:(id)sender;



@end
