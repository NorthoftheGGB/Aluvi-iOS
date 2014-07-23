//
//  VCDriverEarningsViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/15/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriverEarningsViewController.h"
#import <MBProgressHUD.h>
#import "VCBankAccountTextField.h"
#import "VCRoutingNumberTextField.h"
#import "VCTextField.h"
#import "VCTextField.h"
#import "VCLabel.h"
#import "VCLabelBold.h"
#import "VCButtonStandardStyle.h"
#import "VCDriverApi.h"
#import "VCUsersApi.h"
#import "VCDriverRecieptDetailViewController.h"
#import "Earning.h"
#import "VCUtilities.h"
#import "NSDate+Pretty.h"
#import "Fare.h"

@interface VCDriverEarningsViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet VCTextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet VCBankAccountTextField *accountNumberTextField;
@property (weak, nonatomic) IBOutlet VCRoutingNumberTextField *routingNumberTextField;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *changeBankInfoButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)didTapChangeBankInfo:(id)sender;


@end

@implementation VCDriverEarningsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    
        // Custom initialization
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Earning"];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"createdAt" ascending:YES];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Earnings";
    
    // Fire off the earnings reload
    [VCDriverApi earnings:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // no need to do anything
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // nothing to do
    }];
    
    
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi getProfile:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        hud.hidden = YES;
     
        VCProfile * profile = mappingResult.firstObject;
        if(profile.bankAccountName != nil){
            _accountNameTextField.text = profile.bankAccountName;
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        hud.hidden = YES;
        
    }];
    
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
}


- (void) dismissKeyboard:(id) sender{
    [self.view endEditing:YES];
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

- (IBAction)didTapChangeBankInfo:(id)sender {
    [UIAlertView showWithTitle:@"Contact Us" message:@"Updating Bank Account Information is not currently supported through the mobile app.  Please contact us to update your information" cancelButtonTitle:@"Ok, will do" otherButtonTitles:nil tapBlock:nil];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    NSInteger numberOfRows = [sectionInfo numberOfObjects];
    return numberOfRows;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Earning *earning = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [VCUtilities formatCurrencyFromCents:earning.amountCents];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", [earning.createdAt formatted], [earning.fare routeDescription]  ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Earning *earning = [_fetchedResultsController objectAtIndexPath:indexPath];
    VCDriverRecieptDetailViewController * vc = [[VCDriverRecieptDetailViewController alloc] init];
    vc.earning = earning;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
