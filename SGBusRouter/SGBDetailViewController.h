//
//  SGBDetailViewController.h
//  SGBusRouter
//
//  Created by Eddy on 17/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RoutePoint.h"

@interface SGBDetailViewController : UIViewController <UISplitViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet MKMapView *mapView;
    RoutePoint *selectedRoutePoint;
    UIPopoverController *pc;
    CLLocationManager *locationManager;
    UISegmentedControl *nextPrevSC;
}

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKPolyline *routePolylines;
@property (strong, nonatomic) NSMutableArray *routePoints;

- (void)zoomIntoSingapore;
- (void)setSelectedRoutePoint: (RoutePoint *)r;
- (void)removeSelectedRoutePoint;
- (void)hidePrevNext;
- (void)showPrevNext;

@end
