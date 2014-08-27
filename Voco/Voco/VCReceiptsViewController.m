//
//  VCReceiptsViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 8/20/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCReceiptsViewController.h"
#import "HVTableView.h"
#import "VCUtilities.h"
#import "Payment.h"
#import "Ticket.h"
#import "Driver.h"
#import "VCReceiptTableViewCell.h"
#import "VCReceiptExpandedTableViewCell.h"
#import "NSDate+Pretty.h"

@interface VCReceiptsViewController () <HVTableViewDataSource, HVTableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet HVTableView *hvTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation VCReceiptsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _hvTableView.HVTableViewDelegate = self;
    _hvTableView.HVTableViewDataSource = self;
    _hvTableView.expandOnlyOneCell = YES;
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		[WRUtilities criticalError:error];
	}
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Payment"];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"createdAt" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[VCCoreData managedObjectContext] sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    NSInteger numberOfRows = [sectionInfo numberOfObjects];
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isExpanded {
    if(isExpanded){
        return 369;
    } else {
        return 61;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isExpanded {
    
    Payment *payment = [_fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell;
    VCReceiptExpandedTableViewCell * receiptCell = [WRUtilities getViewFromNib:@"VCReceiptExpandedTableViewCell" class:[VCReceiptExpandedTableViewCell class]];
    receiptCell.dateTopLabel.text =  [payment.createdAt typicalDate];
    receiptCell.dateDetailLabel.text =  [payment.createdAt typicalDate];
    receiptCell.totalFareAmountLabel.text = [NSString stringWithFormat:@"%.1f", [payment.amountCents doubleValue] / 100];
    receiptCell.rideNumberLabel.text = [payment.ticket.ride_id stringValue];
    receiptCell.driverNameLabel.text = [payment.ticket.driver fullName];
    receiptCell.directionLabel.text = [payment.ticket shortRouteDescription];
    receiptCell.distanceLabel.text = @"";
    
    [receiptCell.contentView addSubview:receiptCell.collapsed];
    
    CGRect frame = receiptCell.frame;
    if(isExpanded) {
        frame.size.height = 369;
    } else {
        frame.size.height = 61;
    }
    receiptCell.frame = frame;
    [receiptCell.contentView setFrame:frame];
    //receiptCell.contentView.bounds = frame;

    cell = receiptCell;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView collapseCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    VCReceiptExpandedTableViewCell * receiptCell = (VCReceiptExpandedTableViewCell * ) cell;
    [receiptCell.expanded removeFromSuperview];
    [receiptCell.contentView addSubview:receiptCell.collapsed];

}

- (void)tableView:(UITableView *)tableView expandCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    VCReceiptExpandedTableViewCell * receiptCell = (VCReceiptExpandedTableViewCell * ) cell;
    [receiptCell.collapsed removeFromSuperview];
    [receiptCell.contentView addSubview:receiptCell.expanded];

}

/*
 - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath expanded:(BOOL)expanded {
 Payment *payment = [_fetchedResultsController objectAtIndexPath:indexPath];
 cell.textLabel.text = [VCUtilities formatCurrencyFromCents:payment.amountCents];
 cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", payment.stripeChargeStatus, payment.motive];
 }
 */


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.hvTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.hvTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.hvTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.hvTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.hvTableView endUpdates];
}


@end
