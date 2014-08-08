//
//  VCRiderPaymentsViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/3/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCRiderPaymentsViewController.h"
#import <Stripe.h>
#import <STPView.h>
#import <MBProgressHUD.h>
#import <UIAlertView+Blocks.h>
#import "VCTextField.h"
#import "VCButtonStandardStyle.h"
#import "VCUsersApi.h"
#import "VCRiderApi.h"
#import "Payment.h"
#import "VCUtilities.h"
#import "VCRiderRecieptDetailViewController.h"

#define kChangeCardText @"Change Card"
#define kUpdateCardText @"Update Card"
#define kInterfaceStateDisplayCard 1
#define kInterfaceStateUpdateCard 2

@interface VCRiderPaymentsViewController () <STPViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *STPViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *recieptListTableView;
@property (weak, nonatomic) IBOutlet VCButtonStandardStyle *updateCardButton;
@property (weak, nonatomic) IBOutlet UILabel *cardInfoLabel;
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (strong, nonatomic) STPView * cardView;
@property (nonatomic) NSInteger state;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)didTapUpdate:(id)sender;

@end

@implementation VCRiderPaymentsViewController

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
    
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Payment"];
    
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
    self.title = @"Payments";
    _updateCardButton.enabled = YES;
    _updateCardButton.titleLabel.text = kChangeCardText;
    _state = kInterfaceStateDisplayCard;
    
    // Fire off the payments reload
    [VCRiderApi payments:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // no need to do anything
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // nothing to do
    }];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [VCUsersApi getProfile:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        hud.hidden = YES;
        VCProfile * profile = mappingResult.firstObject;
        if(profile.cardLastFour != nil && profile.cardBrand != nil){
            _cardInfoLabel.text = [NSString stringWithFormat:@"%@ XXXX-XXXX-XXXX-%@", profile.cardBrand, profile.cardLastFour];
        } else {
            _cardInfoLabel.text = @"No Credit Card Assigned";
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        hud.hidden = YES;
        
    }];

    
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

- (IBAction)didTapUpdate:(id)sender {
    
    if( _state == kInterfaceStateDisplayCard) {
        
        _state = kInterfaceStateUpdateCard;
        [_updateCardButton setTitle:kUpdateCardText forState:UIControlStateNormal];
        _updateCardButton.enabled = FALSE;
        _cardView = [[STPView alloc] initWithFrame:CGRectMake(15,20,290,55) andKey:@"pk_test_4Gt6M02YRqmpk7yoBud7y5Ah"];
        _cardView.delegate = self;
        [_STPViewContainer addSubview:_cardView];
        _cardInfoLabel.hidden = YES;
        
        
    } else {
        
        MBProgressHUD * progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.labelText = @"Saving Card";
        [_cardView createToken:^(STPToken *token, NSError *error) {
            if (error == nil) {
                [VCUsersApi updateDefaultCard:[RKObjectManager sharedManager]
                                    cardToken:token.tokenId
                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                          progressHUD.hidden = YES;
                                          [UIAlertView showWithTitle:@"Card Updated" message:@"Your card has been saved" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                          _updateCardButton.titleLabel.text = @"Change Card";
                                          [_cardView removeFromSuperview];
                                          _cardView = nil;
                                          _updateCardButton.titleLabel.text = kChangeCardText;
                                          _state = kInterfaceStateDisplayCard;

                                          VCProfile * profile = mappingResult.firstObject;
                                          _cardInfoLabel.text = [NSString stringWithFormat:@"%@ XXXX-XXXX-XXXX-%@", profile.cardBrand, profile.cardLastFour];
                                          _cardInfoLabel.hidden = NO;

                                      }
                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                          progressHUD.hidden = YES;
                                          [UIAlertView showWithTitle:@"Error" message:@"There was a problem saving your card.  Please try again." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                                      }];
            } else {
                progressHUD.hidden = YES;
                [WRUtilities criticalError:error];
            }
        }];
        
    }
    
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    // Enable the "save" button only if the card form is complete.
    if(valid){
        _updateCardButton.enabled = YES;
    } else {
        _updateCardButton.enabled = NO;
        
    }
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
    Payment *payment = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [VCUtilities formatCurrencyFromCents:payment.amountCents];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", payment.stripeChargeStatus, payment.motive];
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
    Payment *payment = [_fetchedResultsController objectAtIndexPath:indexPath];
    VCRiderRecieptDetailViewController * vc = [[VCRiderRecieptDetailViewController alloc] init];
    vc.payment = payment;
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
