//
//  SGBDetailViewController.m
//  SGBusRouter
//
//  Created by Eddy on 17/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import "SGBDetailViewController.h"
#import "RoutePoint.h"

@interface SGBDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation SGBDetailViewController

@synthesize mapView, routePolylines, routePoints;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        
        // locationManager = [[CLLocationManager alloc] init];
        // [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        // [locationManager startUpdatingLocation];
        // [locationManager setDelegate:self];
    }
    return self;
}

- (void)hidePrevNext
{
    [[self navigationItem] setRightBarButtonItem:nil];
}

- (void)showPrevNext
{
    nextPrevSC = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Prev", @"Next", nil]];
    [nextPrevSC setMomentary:YES];
    [nextPrevSC setSegmentedControlStyle:UISegmentedControlStyleBar];
    [nextPrevSC addTarget:self action:@selector(nextPrevClick:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *nextPrevBBI = [[UIBarButtonItem alloc] initWithCustomView:nextPrevSC];
    [[self navigationItem] setRightBarButtonItem:nextPrevBBI];
}

- (void)nextPrevClick:(id)sender
{
    
    // Send prev/next to SubMasterView so we can traverse the cell and callout
    // 0 is prev, 1 is next
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[sender selectedSegmentIndex]] forKey:@"prevNextKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"prevNextCell" object:nil userInfo:userInfo];
}

- (void)refresh:(id)sender
{
    NSLog(@"Refresh");
    
    // Remove polylines
    [mapView removeOverlays:mapView.overlays];
    
    // Remove annotation
    for (id annotation in mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            [mapView removeAnnotation:annotation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Could not find location." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [av show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self zoomIntoSingapore];
    [mapView setShowsUserLocation:YES];
    
//    NSLog (@"%@," self );
}

- (void)viewWillAppear:(BOOL)animated
{
    // Set navbar to blue color
    [[[super navigationController] navigationBar] setTintColor:[UIColor colorWithRed:27.0f/255.0f green:126.0f/255.0f blue:184.0f/255.0f alpha:1]
     ];
}

- (void)zoomIntoSingapore
{
    // Start and zoom into Singapore
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 1.360117;
    newRegion.center.longitude = 103.803635;
    newRegion.span.latitudeDelta = 0.2;
    newRegion.span.longitudeDelta = 0.2;
    [mapView setRegion:newRegion animated:YES];
    [mapView setDelegate:self];
}

-(void)setRoutePolylines:(MKPolyline *)polylines
{
    // Remove previous routePolylines
    [mapView removeOverlays:mapView.overlays];
    
    // Update routePolylines with new data
    routePolylines = polylines;
    [mapView addOverlay:routePolylines];
    
    // Zoom to fit in routePolylines (commented out, use zoom to visible pin instead)
    // [self zoomToPolyLine:mapView polyLine:polylines animated:YES];
}

- (void)setRoutePoints:(NSMutableArray *)rpoints
{
    routePoints = rpoints;
    
    // Remove previous annotation pins
    for (id annotation in mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            [mapView removeAnnotation:annotation];
        }
    }
    
    // Show new annotation pins
    MKMapRect zoomRect = MKMapRectNull;
    for (RoutePoint *pin in routePoints) {
        [mapView addAnnotation:pin];
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(pin.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    // Zoom into to fit visible pins
    [mapView setVisibleMapRect:zoomRect animated:YES];
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Buses", @"Buses");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 8.0;
    
    return polylineView;
}

-(void)zoomToPolyLine: (MKMapView*)map polyLine: (MKPolyline*)polyLine animated: (BOOL)animated
{
    MKPolygon* polygon =
    [MKPolygon polygonWithPoints:polyLine.points count:polyLine.pointCount];
    [map setRegion:MKCoordinateRegionForMapRect([polygon boundingMapRect])
          animated:animated];
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.eddyyanto.pin";
        pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
     
        RoutePoint *r = annotation;
        
        if([[r identifier] isEqual:[NSString stringWithFormat:@"%i", 0]]){
            pinView.image = [UIImage imageNamed:@"red-pin-a.png"];
        }else if([[r identifier] isEqual:[NSString stringWithFormat:@"%i", [routePoints count] - 1]]){
            pinView.image = [UIImage imageNamed:@"red-pin-b.png"];
        }else{
//            pinView.image = [UIImage imageNamed:@"red-circle-dot.png"];
            pinView.image = [UIImage imageNamed:@"red-pin-dot.png"];
        }
        pinView.canShowCallout = YES;
        pinView.opaque = YES;
    }
    else {
        [mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}

- (void)removeSelectedRoutePoint
{
    if (selectedRoutePoint) {
        [mapView removeAnnotation:selectedRoutePoint];
    }
    
    for (id currentAnnotation in mapView.annotations) {
        [self.mapView deselectAnnotation:currentAnnotation animated:YES];
    }
}

- (void)setSelectedRoutePoint:(RoutePoint *)r
{
    // Remove previous callout if exists
    if(selectedRoutePoint)
        [mapView removeAnnotation:selectedRoutePoint];
    
    // Update new routepoint and add it to map
    selectedRoutePoint = r;
    [mapView addAnnotation:selectedRoutePoint];

    // selectAnnotation works okay on iOS Simulator (without delay)
    // But on ipad (iOS 5.1), we need a bit of delay for the annotation to show
    // Need to adjust the timing, for now put 0.2 or 0.3
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [mapView selectAnnotation:r animated:YES];
    });
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // Pass pinID to subMasterView to highlight the table cell
    // RoutePoint *r =  view.annotation; // get id with [r identifier]
    
    // view.image = [UIImage imageNamed:@"red-pin-dot.png"];
    
    NSArray *pinID = [[[view annotation] title] componentsSeparatedByString:@" : "];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithString:[pinID objectAtIndex:0]] forKey:@"busstop"];
    // NSString *pinID = [[view annotation] title];
    // NSDictionary *userInfo = [NSDictionary dictionaryWithObject:pinID forKey:@"busstop"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"highlightCell" object:nil userInfo:userInfo];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
//    view.image = [UIImage imageNamed:@"red-circle-dot.png"];
}

// Since we're using custom images for annotation, animateDrop doesn't work
// Use following delegate method for animation instead
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
//    for (MKAnnotationView *annView in annotationViews)
//    {
//        CGRect endFrame = annView.frame;
//        annView.frame = CGRectOffset(endFrame, 0, -100);
//
//        [UIView animateWithDuration:0.75
//                              delay:(0.0 + [annotationViews indexOfObject:annView]/10.0)
//                            options:UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             [annView setFrame:endFrame];
//                             // animate the shadow subview's center point
//                         }
//                         completion:^ (BOOL finished) {
//                             if (finished) {
//                                 // do something here when the animation finished
//                             }
//                         }];
//        
//    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
