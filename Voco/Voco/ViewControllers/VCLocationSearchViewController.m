//
//  VCLocationSearchControllerViewController.m
//  Voco
//
//  Created by Matthew Shultz on 7/1/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCLocationSearchViewController.h"
@import AddressBookUI;

@interface VCLocationSearchViewController ()

@property (strong, nonatomic) NSArray * searchItems;
@property (strong, nonatomic) MKLocalSearch * localSearch;


@end

@implementation VCLocationSearchViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didEditSearchText:(NSString*) text {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = text;
 
    // Marin
    MKCoordinateRegion region = MKCoordinateRegionMake(
                           CLLocationCoordinate2DMake(38.05513, -122.7488),
                           MKCoordinateSpanMake(.379098360649, .2504746164691)
    );
    request.region = region;
    if(_localSearch != nil){
        [_localSearch cancel];
    }
    _localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [_localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        _searchItems = response.mapItems;
        [self.tableView reloadData];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_searchItems != nil) {
        return [_searchItems count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *mapItem = [_searchItems objectAtIndex:[indexPath row]];
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
    cell.textLabel.text = mapItem.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
                                 [mapItem.placemark.addressDictionary objectForKey:@"City"],
                                 [mapItem.placemark.addressDictionary objectForKey:@"State"]
                                 ];
    
    ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, NO);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_delegate != nil){
        MKMapItem * mapItem = [_searchItems objectAtIndex:[indexPath row]];
        [_delegate locationSearchViewController:self didSelectLocation: mapItem ];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
