//
//  SGBSubMasterViewController.m
//  SGBusRouter
//
//  Created by Eddy on 17/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import "SGBSubMasterViewController.h"
#import "SGBDetailViewController.h"
#import "AFJSONRequestOperation.h"
#import "BusAndStopStore.h"
#import "Stop.h"
#import "RoutePoint.h"

@implementation SGBSubMasterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Add segmented control for Route 1 and 2
        NSArray *r = [NSArray arrayWithObjects:@"Route 1", @"Route 2", nil];
        segmentedControl = [[UISegmentedControl alloc] initWithItems:r];
        [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmentedControl setSelectedSegmentIndex:0];
        [segmentedControl addTarget:self action:@selector(segmentedControlClick:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setTintColor:[UIColor colorWithRed:27.0f/255.0f green:126.0f/255.0f blue:184.0f/255.0f alpha:1]];
        self.navigationItem.titleView = segmentedControl;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Subscribe to pin callout click so that we can highlight cell
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightCell:) name:@"highlightCell" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prevNextCell:) name:@"prevNextCell" object:nil];
    
    // SUbscribe to prevNext button click so that we can traverse them, highlight and callout using it
}
- (void)prevNextCell:(NSNotification *)notification
{
    NSNumber *prevNextKey = [[notification userInfo] objectForKey:@"prevNextKey"];
    NSIndexPath *prevNextIndexPath = [[self tableView] indexPathForSelectedRow];
    
    // Todo: fix higlighting of filtered result
    NSLog(@"%@", prevNextIndexPath);

    // If prev button is clicked
    if(prevNextIndexPath && [prevNextKey isEqualToNumber:[NSNumber numberWithInt:0]] && [prevNextIndexPath row] >= 1)
    {
        NSLog(@"Prev clicked");
        
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:([prevNextIndexPath row] - 1) inSection:0];
        [[self tableView] selectRowAtIndexPath:nextIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        Stop *s;
        if([self tableView] == self.searchDisplayController.searchResultsTableView){
            s = [[BusAndStopStore sharedStore] getStop:filteredStopsSelectedBusPasThrough[nextIndexPath.row]];
        }else{
            s = [[BusAndStopStore sharedStore] getStop:stopsSelectedBusPassThrough[nextIndexPath.row]];
        }
        
        CLLocationCoordinate2D lc = CLLocationCoordinate2DMake([s latitude], [s longitude]);
        RoutePoint *r = [[RoutePoint alloc] initWithCoordinate:lc title:[NSString stringWithFormat:@"%@ : %@", [s number], [s name]] identifier:[s number]];
        [self.detailViewController setSelectedRoutePoint:r];
        
    // If next button is clicked
    }else if(prevNextIndexPath && [prevNextKey isEqualToNumber:[NSNumber numberWithInt:1]] && [prevNextIndexPath row] <= [[self tableView] numberOfRowsInSection:0] - 2){
        
        NSLog(@"Next clicked");
        
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:([prevNextIndexPath row] + 1) inSection:0];
        [[self tableView] selectRowAtIndexPath:nextIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        Stop *s;
        if([self tableView] == self.searchDisplayController.searchResultsTableView){
            s = [[BusAndStopStore sharedStore] getStop:filteredStopsSelectedBusPasThrough[nextIndexPath.row]];
        }else{
            s = [[BusAndStopStore sharedStore] getStop:stopsSelectedBusPassThrough[nextIndexPath.row]];
        }
        
        CLLocationCoordinate2D lc = CLLocationCoordinate2DMake([s latitude], [s longitude]);
        RoutePoint *r = [[RoutePoint alloc] initWithCoordinate:lc title:[NSString stringWithFormat:@"%@ : %@", [s number], [s name]] identifier:[s number]];
        [self.detailViewController setSelectedRoutePoint:r];
    }else{
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [[self tableView] selectRowAtIndexPath:nextIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        Stop *s;
        if([self tableView] == self.searchDisplayController.searchResultsTableView){
            s = [[BusAndStopStore sharedStore] getStop:filteredStopsSelectedBusPasThrough[nextIndexPath.row]];
        }else{
            s = [[BusAndStopStore sharedStore] getStop:stopsSelectedBusPassThrough[nextIndexPath.row]];
        }
        
        CLLocationCoordinate2D lc = CLLocationCoordinate2DMake([s latitude], [s longitude]);
        RoutePoint *r = [[RoutePoint alloc] initWithCoordinate:lc title:[NSString stringWithFormat:@"%@ : %@", [s number], [s name]] identifier:[s number]];
        [self.detailViewController setSelectedRoutePoint:r];
    }
}

- (void)highlightCell:(NSNotification *)notification
{
     // Possible alternative : use identifier
    // NSUInteger selectedCellIndex = [[[notification userInfo] objectForKey:@"busstop"] integerValue];
    NSUInteger selectedCellIndex;
    if([self tableView] == self.searchDisplayController.searchResultsTableView){
        selectedCellIndex = [filteredStopsSelectedBusPasThrough indexOfObject:[[notification userInfo] objectForKey:@"busstop"]];
    }else{
        selectedCellIndex = [stopsSelectedBusPassThrough indexOfObject:[[notification userInfo] objectForKey:@"busstop"]];
    }
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedCellIndex inSection:0];
    
    // Highlight and scroll if only we clicked on annotation pin
    // If we clicked on cell, do not scroll to middle position
    if(![selectedIndexPath isEqual:[[self tableView] indexPathForSelectedRow]])
        [[self tableView] selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    // Determine if back button is being clicked.
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self.detailViewController removeSelectedRoutePoint];
        
        // Hide prev/next on master view
        [self.detailViewController hidePrevNext];
    }
    [super viewWillDisappear:animated];
}

- (void)segmentedControlClick:(id)sender
{
    // Hide all callout
    [self.detailViewController removeSelectedRoutePoint];
    
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            [self setStopsAlongPath:selectedBus withDirection:@"1"];
            break;
            
        case 1:
            [self setStopsAlongPath:selectedBus withDirection:@"2"];
            break;
            
        default:
            break;
    }
}

- (void)setStopsAlongPath:(NSString *)bus withDirection:(NSString *)dir
{
    // If selected bus and direction are same as before, do nothing and just return
    if ([selectedBus isEqual:bus] && [selectedDirection isEqual:dir]) {
        return;
    }
    
    // Else set selected bus and direction to new values
    selectedBus = bus;
    selectedDirection = dir;

    // Check if selected bus file exists
    NSString *selectedFile = [[NSBundle mainBundle] pathForResource:selectedBus ofType:@"json"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:selectedFile]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Bus detail not available." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [av show];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Get the routes and stops that the bus pass through from file
        NSURL *busUrl = [[NSBundle mainBundle] URLForResource:selectedBus withExtension:@"json"];
        NSURLRequest *busRequest = [NSURLRequest requestWithURL:busUrl];

        // Load routes and stop the draw unto map
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:busRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            // Get list of route. It is on 2nd level deep.
            NSDictionary *busInfo = [JSON objectForKey:selectedDirection];
            NSArray *busRoutes = [busInfo objectForKey:@"route"];

            if([busRoutes count] < 1){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Bus %@ only has 1 direction/route.", selectedBus] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [av show];
                
                return;
            }
            
            // Loop through busRoutes
            // CLLocationCoordinate2D coordinates[busRoutes.count]; // Replaced by following
            CLLocationCoordinate2D *coordinates = malloc([busRoutes count] * sizeof(CLLocationCoordinate2D));
            int index = 0;
            for(NSString *route in busRoutes){
                NSArray *longlat = [route componentsSeparatedByString:@","];
                CLLocationDegrees latitude  = [[longlat objectAtIndex:1] doubleValue];
                CLLocationDegrees longitude = [[longlat objectAtIndex:0] doubleValue];

                // Add current route CLLocation to points
                // CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                
                // Array of coordinates for polylines
                // CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                coordinates[index] = CLLocationCoordinate2DMake((double)latitude, (double)longitude);
                index++;
            }
            
            // Send routePolylines to detailView
            MKPolyline *routePolylines = [MKPolyline polylineWithCoordinates:coordinates count:busRoutes.count];
            free(coordinates);
            
//            NSLog(@"%@", [routePolylines points]);
            
            [[self navigationController] setTitle:[NSString stringWithFormat:@"%@ %@", @"Route For Bus No.", selectedBus]];
            [self.detailViewController setRoutePolylines:routePolylines];
            
            // Get all stops that the bus pass through
            NSArray *stopsBusPassThrough = [busInfo objectForKey:@"stops"];
            NSMutableArray *routePoints = [[NSMutableArray alloc] init];
            int i = 0;
            for(NSString *stopNumber in stopsBusPassThrough){
                
                Stop *stopInfo = [[BusAndStopStore sharedStore] getStop:stopNumber];
                
                // Add each stop as annotation
                CLLocationCoordinate2D lc = CLLocationCoordinate2DMake([stopInfo latitude], [stopInfo longitude]);
                RoutePoint *rp = [[RoutePoint alloc] initWithCoordinate:lc title:[NSString stringWithFormat:@"%@ : %@", [stopInfo number], [stopInfo name]] identifier:[stopInfo number]];
                [rp setIdentifier:[NSString stringWithFormat:@"%i", i]];
                [routePoints addObject:rp];
                i++;
            }
            
            // Pass routepoints to detailView
            [self.detailViewController setRoutePoints:routePoints];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            NSLog(@"%@", error);
        }];
        
        [operation start];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // Stop activity indicator
        });
    });
    
    // Load list of stops that selected bus pass through and put it as datasource
    NSURL *selectedBusUrl = [[NSBundle mainBundle] URLForResource:selectedBus withExtension:@"json"];
    NSURLRequest *selectedBusRequest = [NSURLRequest requestWithURL:selectedBusUrl];
    
    AFJSONRequestOperation *selectedBusOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:selectedBusRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        // List of stops that selected bus pass through is at 2nd level deep
        NSDictionary *selectedBusInfo = [JSON objectForKey:selectedDirection];
        stopsSelectedBusPassThrough = [selectedBusInfo objectForKey:@"stops"];
        
        [[self tableView] reloadData];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"%@", error);
    }];
    
    [selectedBusOperation start];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    filteredStopsSelectedBusPasThrough = [stopsSelectedBusPassThrough filteredArrayUsingPredicate:resultPredicate];
}

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    [self.detailViewController hidePrevNext];
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    [self.detailViewController showPrevNext];
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    // Todo: need to fix this. Hide on searchResultTableView but show on normal tableView
//    
////    if([self tableView] != [[self searchDisplayController] searchResultsTableView]){
////        [self.detailViewController showPrevNext];
////    }
//    
//    NSLog(@"%@", [searchBar text]);
//}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];

    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [filteredStopsSelectedBusPasThrough count];
    }else{
        return [stopsSelectedBusPassThrough count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    Stop *s;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        s = [[BusAndStopStore sharedStore] getStop:filteredStopsSelectedBusPasThrough[indexPath.row]];
    }else{
        s = [[BusAndStopStore sharedStore] getStop:stopsSelectedBusPassThrough[indexPath.row]];
    }
    cell.textLabel.text = [s number];
    cell.detailTextLabel.text = [s name];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(96/255.0) blue:(130/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If we select a cell, dismiss search bar
    [self.view endEditing:YES];
    
    Stop *s;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        s = [[BusAndStopStore sharedStore] getStop:filteredStopsSelectedBusPasThrough[indexPath.row]];
    }else{
        s = [[BusAndStopStore sharedStore] getStop:stopsSelectedBusPassThrough[indexPath.row]];
    }
    
    CLLocationCoordinate2D lc = CLLocationCoordinate2DMake([s latitude], [s longitude]);
    RoutePoint *r = [[RoutePoint alloc] initWithCoordinate:lc title:[NSString stringWithFormat:@"%@ : %@", [s number], [s name]] identifier:[s number]];
    [self.detailViewController setSelectedRoutePoint:r];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
