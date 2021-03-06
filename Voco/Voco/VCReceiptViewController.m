//
//  VCReceiptsView.m
//  Voco
//
//  Created by snacks on 8/5/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCReceiptViewController.h"
#import <MBProgressHUD.h>
#import "VCRidesApi.h"
#import "VCUsersApi.h"
#import "VCStyle.h"
#import "VCReceiptsTableViewCell.h"
#import "Receipt.h"
#import "NSDate+Pretty.h"


@interface VCReceiptViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *receiptTableView;

@property(strong, nonatomic) NSFetchedResultsController * fetchedResultsController;
@end

@implementation VCReceiptViewController



- (void) setGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [VCStyle gradientColors];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.view.layer insertSublayer:gradient atIndex:0];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Receipt"];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSSortDescriptor * sort2 = [NSSortDescriptor sortDescriptorWithKey:@"receiptId" ascending:YES];
    [request setSortDescriptors:@[sort, sort2]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                managedObjectContext:[VCCoreData managedObjectContext]
                                sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    if(error != nil){
        [WRUtilities criticalError:error];
    }

  
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setGradient];
    
    [VCRidesApi refreshReceiptsWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Refreshed Receipts");       
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    }];
}


- (IBAction)didTouchPrintReceipts:(id)sender {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi printReceiptsToEmailWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        hud.hidden = YES;
        [UIAlertView showWithTitle:@"Submitted" message:@"You will receive full receipts via email" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        hud.hidden = YES;
        [UIAlertView showWithTitle:@"Errors" message:@"There was a problem submitting your request" cancelButtonTitle:@"I'll try again" otherButtonTitles:nil tapBlock:nil];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VCReceiptsTableViewCell * cell = [WRUtilities getViewFromNib:@"VCReceiptsTableViewCell" class:[VCReceiptsTableViewCell class]];
    Receipt * receipt = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.receiptDate.text = [receipt.date monthAndDay];
    cell.receiptTripType.text = receipt.type;
    cell.receiptTripTotalFare.text = [NSString stringWithFormat:@"%.2f", [receipt.amount doubleValue] / 100.0f];
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.receiptTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.receiptTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell != nil) {
                [tableView reloadRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
            }}
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.receiptTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.receiptTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.receiptTableView endUpdates];
}

@end
