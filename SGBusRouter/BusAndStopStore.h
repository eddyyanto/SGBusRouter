//
//  StopStore.h
//  SGBusRouter
//
//  Created by Eddy on 20/5/13.
//  Copyright (c) 2013 Eddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Stop;
@class Bus;

@interface BusAndStopStore : NSObject
{
    NSMutableDictionary *allStops;
    NSMutableDictionary *allBuses;
}

// Class method
+ (BusAndStopStore *)sharedStore;

// Stops
- (NSDictionary *)allStops;
- (Stop *)addStop: (NSString *)number withName: (NSString *)name withLat:(CLLocationDegrees)latitude withLong:(CLLocationDegrees)longitude;
- (Stop *)getStop: (NSString *)number;


// Buses
- (NSDictionary *)allBuses;
- (Bus *)addBus: (NSString *)number withDirection:(NSString *)direction withProvider:(NSString *)provider withType:(NSString *)type;
- (Bus *)getBus: (NSString *)number;


@end
