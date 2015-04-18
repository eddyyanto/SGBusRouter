//
//  SGBMasterViewController.m
//  SGBusRouter
//
//  Created by Eddy on 17/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import "SGBMasterViewController.h"

#import "SGBDetailViewController.h"
#import "AFJSONRequestOperation.h"
#import "BusAndStopStore.h"
#import "Stop.h"
#import "Bus.h"

@implementation SGBMasterViewController

@synthesize busesKeys, filteredBusesKeys;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"Buses", @"Buses");
        self.clearsSelectionOnViewWillAppear = NO;
        [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        // Load all buses / list
        NSURL *busesJsonUrl = [[NSBundle mainBundle] URLForResource:@"bus-services" withExtension:@"json"];
        NSURLRequest *busesJsonRequest = [NSURLRequest requestWithURL:busesJsonUrl];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
        
        AFJSONRequestOperation *busesJSONOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:busesJsonRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSArray *trunkBuses = [JSON objectForKey:@"Trunk Bus Services"];
            for (NSDictionary *b in trunkBuses) {
                [[BusAndStopStore sharedStore] addBus:[b objectForKey:@"no"] withDirection:[b objectForKey:@"dir"] withProvider:[b objectForKey:@"provider"] withType:@"Trunk Bus Services"];
            }

            NSArray *feederBuses = [JSON objectForKey:@"Feeder Bus Services"];
            for (NSDictionary *b in feederBuses) {
                [[BusAndStopStore sharedStore] addBus:[b objectForKey:@"no"] withDirection:[b objectForKey:@"dir"] withProvider:[b objectForKey:@"provider"] withType:@"Feeder Bus Services"];            
            }
            
            NSArray *niteBuses = [JSON objectForKey:@"Nite Bus Services"];
            for (NSDictionary *b in niteBuses) {
                [[BusAndStopStore sharedStore] addBus:[b objectForKey:@"no"] withDirection:[b objectForKey:@"dir"] withProvider:[b objectForKey:@"provider"] withType:@"Nite Bus Services"];
            }
            
            // We can't get dictionary with index so we pull all the key into busesKeys
            NSArray *unorderedBusesKeys = [[[BusAndStopStore sharedStore] allBuses] allKeys];
            busesKeys = [unorderedBusesKeys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
                return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
            }];
            
            // We have data now so reload
            [[self tableView] reloadData];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            NSLog(@"%@", error);
        }];
        [busesJSONOperation start];
        
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create blue tinted search bar
    // searchBar.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:129.0f/255.0f blue:185.0f/255.0f alpha:0];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    filteredBusesKeys = [busesKeys filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Set navbar to blue color
    [[[super navigationController] navigationBar] setTintColor:[UIColor colorWithRed:27.0f/255.0f green:126.0f/255.0f blue:184.0f/255.0f alpha:1]
     ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [filteredBusesKeys count];
    }else{
        return [busesKeys count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Bus *b;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        b = [[BusAndStopStore sharedStore] getBus:[filteredBusesKeys objectAtIndex:indexPath.row]];
    }else{
        b = [[BusAndStopStore sharedStore] getBus:[busesKeys objectAtIndex:indexPath.row]];
    }

    cell.textLabel.text = [b number];
    cell.detailTextLabel.text = [[b provider] uppercaseString];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(96/255.0) blue:(130/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SGBSubMasterViewController *subMasterViewController = [[SGBSubMasterViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        [subMasterViewController setStopsAlongPath:filteredBusesKeys[indexPath.row] withDirection:@"1"];
        [subMasterViewController setDetailViewController:self.detailViewController];
        self.detailViewController.title = [NSString stringWithFormat:@"Route for bus no: %@", filteredBusesKeys[indexPath.row]];
    }else{
        [subMasterViewController setStopsAlongPath:busesKeys[indexPath.row] withDirection:@"1"];
        [subMasterViewController setDetailViewController:self.detailViewController];
        self.detailViewController.title = [NSString stringWithFormat:@"Route for bus no: %@", busesKeys[indexPath.row]];
    }
    [[self navigationController] pushViewController:subMasterViewController animated:YES];
    
    // Show prev/next on submaster view
    [self.detailViewController showPrevNext];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
